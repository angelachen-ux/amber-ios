// ONBOARD-01/02: Onboarding flow state management

import Foundation
import SwiftUI
import SwiftData

enum OnboardingStep: Int, CaseIterable {
    case name
    case birthday
    case almaMater
    case hometown
    case privacyTier
    case permissions
    case done
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var step: OnboardingStep = .name
    @Published var displayName: String = ""
    @Published var birthday: Date = Calendar.current.date(byAdding: .year, value: -22, to: Date()) ?? Date()
    @Published var birthdayLocation: String = ""
    @Published var almaMater: String = ""
    @Published var hometown: String = ""
    @Published var currentCity: String = ""
    @Published var selectedTier: PrivacyTier = .localOnly
    @Published var isLoading = false
    @Published var error: String?

    private let contactService = ContactGraphService()
    private let notificationService = NotificationService.shared

    var horoscopeSign: String { deriveHoroscope(from: birthday) }

    var canAdvance: Bool {
        switch step {
        case .name:        return !displayName.trimmingCharacters(in: .whitespaces).isEmpty
        case .birthday:    return true
        case .almaMater:   return true
        case .hometown:    return true
        case .privacyTier: return true
        case .permissions: return true
        case .done:        return false
        }
    }

    func advance() {
        guard let next = OnboardingStep(rawValue: step.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.3)) { step = next }
    }

    func saveProfile(context: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        let profile = UserProfile(
            displayName: displayName,
            birthday: birthday,
            birthdayLocation: birthdayLocation.isEmpty ? nil : birthdayLocation,
            horoscopeSign: horoscopeSign,
            almaMater: almaMater.isEmpty ? nil : almaMater,
            hometown: hometown.isEmpty ? nil : hometown,
            currentCity: currentCity.isEmpty ? nil : currentCity,
            privacyTier: selectedTier
        )
        context.insert(profile)
        try? context.save()
    }

    func requestPermissions(context: ModelContext) async {
        // Contacts
        let contacts = (try? await contactService.buildGraph(context: context)) ?? []
        try? contactService.generateBirthdaySignals(contacts: contacts, context: context)

        // Notifications
        _ = await notificationService.requestAuthorization()

        // Fetch pending signals and schedule local notifications
        let signals = (try? context.fetch(FetchDescriptor<Signal>())) ?? []
        await notificationService.scheduleLocalNotifications(for: signals)
    }

    // MARK: - Horoscope derivation

    private func deriveHoroscope(from date: Date) -> String {
        let cal = Calendar.current
        let m = cal.component(.month, from: date)
        let d = cal.component(.day, from: date)
        switch (m, d) {
        case (3, 21...), (4, ...19): return "Aries ♈"
        case (4, 20...), (5, ...20): return "Taurus ♉"
        case (5, 21...), (6, ...20): return "Gemini ♊"
        case (6, 21...), (7, ...22): return "Cancer ♋"
        case (7, 23...), (8, ...22): return "Leo ♌"
        case (8, 23...), (9, ...22): return "Virgo ♍"
        case (9, 23...), (10, ...22): return "Libra ♎"
        case (10, 23...), (11, ...21): return "Scorpio ♏"
        case (11, 22...), (12, ...21): return "Sagittarius ♐"
        case (12, 22...), (1, ...19): return "Capricorn ♑"
        case (1, 20...), (2, ...18): return "Aquarius ♒"
        case (2, 19...), (3, ...20): return "Pisces ♓"
        default: return "Capricorn ♑"
        }
    }
}
