// SIGNAL-02: Push Notification Delivery — APNs registration + local scheduling

import Foundation
import Combine
import UserNotifications
import SwiftData

@MainActor
final class NotificationService: ObservableObject {
    @Published var isAuthorized = false
    @Published var deviceToken: String?

    static let shared = NotificationService()
    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    /// Called from AppDelegate after APNs registration succeeds.
    func didRegisterForRemoteNotifications(deviceToken data: Data) {
        let token = data.map { String(format: "%02.2hhx", $0) }.joined()
        deviceToken = token
    }

    // MARK: - Local Notification Scheduling (SIGNAL-01, local_only tier)

    /// Schedules local notifications for a set of signals.
    /// Used when the user is in local_only mode and APNs can't be used.
    func scheduleLocalNotifications(for signals: [Signal]) async {
        let center = UNUserNotificationCenter.current()
        // Remove any previously scheduled signal notifications
        center.removePendingNotificationRequests(withIdentifiers: signals.map { $0.dedupeKey })

        for signal in signals where signal.currentStatus == .pending {
            let content = UNMutableNotificationContent()
            content.title = signal.notificationTitle
            content.body = "Tap to see your suggestion."
            content.sound = .default
            content.badge = 1
            content.userInfo = ["signalDedupeKey": signal.dedupeKey, "signalType": signal.signalType]

            let triggerDate = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: signal.triggerDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(
                identifier: signal.dedupeKey,
                content: content,
                trigger: trigger
            )

            try? await center.add(request)
        }
    }

    /// Cancels all pending signal notifications (e.g., after user acts on them)
    func cancelNotification(dedupeKey: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dedupeKey])
    }

    // MARK: - Notification Preferences

    var notificationSettings: UNNotificationSettings {
        get async {
            await UNUserNotificationCenter.current().notificationSettings()
        }
    }
}
