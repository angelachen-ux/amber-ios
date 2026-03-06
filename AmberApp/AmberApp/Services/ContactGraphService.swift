// DATA-01: iMessage Contact Graph Extraction
// Reads CNContacts, computes relationship scores, feeds SIGNAL-01 (birthday signals)

import Foundation
import Contacts
import SwiftData

@MainActor
final class ContactGraphService: ObservableObject {
    @Published var status: GraphStatus = .idle
    @Published var contactCount: Int = 0

    enum GraphStatus {
        case idle, requesting, building, done, failed(String)
    }

    private let store = CNContactStore()

    // MARK: - Permission

    func requestAccess() async -> Bool {
        let current = CNContactStore.authorizationStatus(for: .contacts)
        switch current {
        case .authorized: return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                store.requestAccess(for: .contacts) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        default: return false
        }
    }

    // MARK: - Graph Build

    /// Fetches all contacts, scores relationships, upserts into SwiftData.
    /// Returns the contact array for optional cloud sync (PRIVACY-01 enforced by caller).
    func buildGraph(context: ModelContext) async throws -> [Contact] {
        status = .requesting
        guard await requestAccess() else {
            status = .failed("Contacts permission denied")
            throw ContactError.permissionDenied
        }

        status = .building

        let keys: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
        ]

        let request = CNFetchRequest(entityType: CNContact.self)
        request.keysToFetch = keys

        var results: [Contact] = []
        let now = Date()

        try store.enumerateContacts(with: request) { cnContact, _ in
            let name = "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { return }

            let phones = cnContact.phoneNumbers.map { $0.value.stringValue }
            let emails = cnContact.emailAddresses.map { $0.value as String }
            var birthday: Date?
            if let bday = cnContact.birthday {
                birthday = Calendar.current.date(from: bday)
            }

            // Relationship score: base 10 + bonus for having phone/email/birthday
            var score = 10
            if !phones.isEmpty { score += 20 }
            if !emails.isEmpty { score += 10 }
            if birthday != nil  { score += 15 }
            score = min(score, 100)

            let contact = Contact(
                externalId: cnContact.identifier,
                name: name,
                phoneNumbers: phones,
                emails: emails,
                birthday: birthday,
                messageFrequency: 0, // iOS doesn't expose iMessage metadata via public API
                lastContactedAt: nil,
                relationshipScore: score
            )
            results.append(contact)
        }

        // Upsert into SwiftData
        for contact in results {
            let extId = contact.externalId
            let existing = try context.fetch(
                FetchDescriptor<Contact>(predicate: #Predicate { $0.externalId == extId })
            ).first

            if let existing {
                existing.name = contact.name
                existing.phoneNumbers = contact.phoneNumbers
                existing.emails = contact.emails
                existing.birthday = contact.birthday
                existing.relationshipScore = contact.relationshipScore
                existing.updatedAt = now
            } else {
                context.insert(contact)
            }
        }

        try context.save()
        contactCount = results.count
        status = .done
        return results
    }

    // MARK: - Birthday Signal Generation (SIGNAL-01, on-device for local_only users)

    /// Generates local Signal rows for upcoming birthdays. No network required.
    func generateBirthdaySignals(contacts: [Contact], context: ModelContext) throws {
        let calendar = Calendar.current
        let now = Date()
        let thisYear = calendar.component(.year, from: now)

        for contact in contacts {
            guard let birthday = contact.birthday else { continue }

            var bdayComponents = calendar.dateComponents([.month, .day], from: birthday)
            bdayComponents.year = thisYear

            guard let bdayThisYear = calendar.date(from: bdayComponents) else { continue }

            let offsets: [(Int, SignalType)] = [(-3, .birthday3Day), (-1, .birthday1Day), (0, .birthdayToday)]
            for (offset, type) in offsets {
                guard let triggerDate = calendar.date(byAdding: .day, value: offset, to: bdayThisYear),
                      triggerDate >= now else { continue }

                let dk = "\(contact.externalId):\(type.rawValue):\(thisYear)"
                let existingSignals = try context.fetch(
                    FetchDescriptor<Signal>(predicate: #Predicate { $0.dedupeKey == dk })
                )
                if !existingSignals.isEmpty { continue }

                let signal = Signal(
                    contactExternalId: contact.externalId,
                    contactName: contact.name,
                    signalType: type,
                    triggerDate: triggerDate,
                    payload: ["contactName": contact.name],
                    dedupeKey: dk
                )
                context.insert(signal)
            }
        }
        try context.save()
    }
}

enum ContactError: Error {
    case permissionDenied
    case fetchFailed(Error)
}
