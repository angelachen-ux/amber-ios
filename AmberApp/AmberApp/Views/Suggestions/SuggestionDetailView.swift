// SIGNAL-03: Suggestion detail view — the "thoughtful friend" screen

import SwiftUI
import SwiftData
import MessageUI

struct SuggestionDetailView: View {
    let signal: Signal
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedStarter: String?
    @State private var showMessageCompose = false
    @State private var reminderSet = false

    private var accentColor: Color {
        switch signal.type {
        case .birthdayToday:        return .amberGold
        case .birthday1Day, .birthday3Day: return .orange
        case .sharedCalendarEvent:  return .blue
        case .questionnaireMatch:   return .purple
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.amberBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(accentColor.opacity(0.15))
                                    .frame(width: 88, height: 88)
                                Text(signal.contactName.prefix(1).uppercased())
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(accentColor)
                            }
                            .padding(.top, 32)

                            Text(signal.notificationTitle)
                                .font(.amberTitle2.weight(.bold))
                                .foregroundColor(.amberText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)

                            Text(contextSubtitle)
                                .font(.amberBody)
                                .foregroundColor(.amberSecondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 32)

                        // Conversation starters
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Conversation starters")
                                .font(.amberBody.weight(.semibold))
                                .foregroundColor(.amberSecondaryText)
                                .padding(.horizontal, 20)

                            ForEach(signal.conversationStarters, id: \.self) { starter in
                                StarterRow(
                                    text: starter,
                                    isSelected: selectedStarter == starter
                                ) {
                                    selectedStarter = starter == selectedStarter ? nil : starter
                                }
                            }
                        }
                        .padding(.bottom, 24)

                        // Actions
                        VStack(spacing: 12) {
                            // Send a text
                            ActionButton(
                                title: "Send a message",
                                subtitle: "Opens iMessage",
                                icon: "message.fill",
                                color: .green
                            ) {
                                openMessages()
                            }

                            // Set a reminder
                            ActionButton(
                                title: reminderSet ? "Reminder set ✓" : "Set a reminder",
                                subtitle: "Remind me closer to the date",
                                icon: "bell.fill",
                                color: .blue
                            ) {
                                setReminder()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                        // Dismiss
                        Button("Not now") {
                            dismissSignal()
                        }
                        .font(.amberCaption)
                        .foregroundColor(.amberSecondaryText)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.amberBody.weight(.semibold))
                        .foregroundColor(.amberGold)
                }
            }
        }
    }

    // MARK: - Context subtitle

    private var contextSubtitle: String {
        switch signal.type {
        case .birthdayToday:   return "Today's the day — a quick message means a lot."
        case .birthday1Day:    return "Tomorrow's their birthday. Get ahead of it."
        case .birthday3Day:    return "You've got a few days to plan something."
        case .sharedCalendarEvent:
            let event = signal.payloadDict["eventTitle"] ?? "the event"
            return "You're both going to \(event). Reach out before it happens."
        case .questionnaireMatch:
            let kind  = signal.payloadDict["matchType"] ?? "something"
            let value = signal.payloadDict["matchValue"] ?? ""
            return "You both listed \"\(value)\" as your \(kind). Small world."
        }
    }

    // MARK: - Actions

    private func openMessages() {
        markActed()
        let phone = signal.payloadDict["phone"] ?? ""
        let text = selectedStarter.map { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" } ?? ""
        let url: URL?
        if !phone.isEmpty {
            url = URL(string: "sms:\(phone)&body=\(text)")
        } else {
            url = URL(string: "sms:&body=\(text)")
        }
        if let url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func setReminder() {
        // Local notification as a reminder (1 day before trigger date)
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: signal.triggerDate) ?? signal.triggerDate
        let content = UNMutableNotificationContent()
        content.title = "Reminder: " + signal.notificationTitle
        content.body = "You set a reminder for this."
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "reminder-\(signal.dedupeKey)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        withAnimation { reminderSet = true }
    }

    private func markActed() {
        signal.status = SignalStatus.acted.rawValue
        signal.actedAt = Date()
        try? context.save()
    }

    private func dismissSignal() {
        signal.status = SignalStatus.dismissed.rawValue
        try? context.save()
        dismiss()
    }
}

// MARK: - Subviews

private struct StarterRow: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .font(.amberBody)
                    .foregroundColor(.amberText)
                    .multilineTextAlignment(.leading)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.amberGold)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.amberGold.opacity(0.12) : Color.amberCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.amberGold : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }
}

private struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.amberBody.weight(.semibold))
                        .foregroundColor(.amberText)
                    Text(subtitle)
                        .font(.amberCaption)
                        .foregroundColor(.amberSecondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.amberSecondaryText)
            }
            .padding(16)
            .background(Color.amberCardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// Needed for UNUserNotificationCenter inline call
import UserNotifications
