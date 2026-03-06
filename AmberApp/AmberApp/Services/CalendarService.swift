// DATA-03: Calendar (EventKit) Integration — SIGNAL-04 shared event detection

import Foundation
import EventKit
import SwiftData

@MainActor
final class CalendarService: ObservableObject {
    @Published var isAuthorized = false

    private let store = EKEventStore()

    // MARK: - Authorization

    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestFullAccessToEvents()
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    // MARK: - Event Fetch

    struct CalendarEventPayload {
        var eventId: String
        var title: String
        var startDate: Date
        var attendeeExternalIds: [String] // matched to CNContact identifiers
    }

    /// Fetches events in the next 30 days + last 30 days.
    /// Returns structured payloads ready for the signals API or local signal generation.
    func fetchRelevantEvents(contacts: [Contact]) -> [CalendarEventPayload] {
        let now = Date()
        let past = Calendar.current.date(byAdding: .day, value: -30, to: now)!
        let future = Calendar.current.date(byAdding: .day, value: 30, to: now)!

        let predicate = store.predicateForEvents(withStart: past, end: future, calendars: nil)
        let ekEvents = store.events(matching: predicate)

        // Build a lookup: phone/email → CNContact externalId
        var phoneToContactId: [String: String] = [:]
        var emailToContactId: [String: String] = [:]
        for contact in contacts {
            for phone in contact.phoneNumbers { phoneToContactId[phone.digitsOnly] = contact.externalId }
            for email in contact.emails { emailToContactId[email.lowercased()] = contact.externalId }
        }

        var results: [CalendarEventPayload] = []
        for event in ekEvents {
            guard let attendees = event.attendees, attendees.count > 1 else { continue }
            var matchedIds: [String] = []
            for attendee in attendees {
                if let url = attendee.url?.absoluteString {
                    let email = url.replacingOccurrences(of: "mailto:", with: "").lowercased()
                    if let id = emailToContactId[email] { matchedIds.append(id) }
                }
            }
            if matchedIds.isEmpty { continue }
            results.append(CalendarEventPayload(
                eventId: event.eventIdentifier ?? UUID().uuidString,
                title: event.title ?? "Event",
                startDate: event.startDate,
                attendeeExternalIds: matchedIds
            ))
        }
        return results
    }

    /// Generates local Signal rows for shared calendar events (on-device, for local_only users).
    func generateCalendarSignals(contacts: [Contact], context: ModelContext) throws {
        let events = fetchRelevantEvents(contacts: contacts)
        let now = Date()

        let contactById = Dictionary(uniqueKeysWithValues: contacts.map { ($0.externalId, $0) })

        for event in events where event.startDate >= now {
            for extId in event.attendeeExternalIds {
                guard let contact = contactById[extId] else { continue }
                let dk = "\(extId):shared_calendar_event:\(event.eventId)"
                let existing = try context.fetch(
                    FetchDescriptor<Signal>(predicate: #Predicate { $0.dedupeKey == dk })
                )
                if !existing.isEmpty { continue }

                let signal = Signal(
                    contactExternalId: extId,
                    contactName: contact.name,
                    signalType: .sharedCalendarEvent,
                    triggerDate: event.startDate,
                    payload: ["eventId": event.eventId, "eventTitle": event.title, "contactName": contact.name],
                    dedupeKey: dk
                )
                context.insert(signal)
            }
        }
        try context.save()
    }
}

private extension String {
    var digitsOnly: String { filter { $0.isNumber } }
}
