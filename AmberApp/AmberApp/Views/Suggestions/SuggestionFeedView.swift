// SIGNAL-03: Suggestion feed — the main surface for Amber nudges

import SwiftUI
import SwiftData

struct SuggestionFeedView: View {
    @Query(
        filter: #Predicate<Signal> {
            $0.status == "pending" || $0.status == "sent" || $0.status == "viewed"
        },
        sort: \Signal.triggerDate
    )
    private var signals: [Signal]

    @Environment(\.modelContext) private var context
    @State private var selectedSignal: Signal?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.amberBackground.ignoresSafeArea()

                if signals.isEmpty {
                    EmptyFeedView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(signals, id: \.dedupeKey) { signal in
                                SuggestionCard(signal: signal) {
                                    selectedSignal = signal
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("For You")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedSignal) { signal in
                SuggestionDetailView(signal: signal)
            }
        }
    }
}

// MARK: - Suggestion Card (collapsed)

struct SuggestionCard: View {
    let signal: Signal
    let onTap: () -> Void

    @Environment(\.modelContext) private var context

    private var accentColor: Color {
        switch signal.type {
        case .birthdayToday:        return .amberGold
        case .birthday1Day, .birthday3Day: return .orange
        case .sharedCalendarEvent:  return .blue
        case .questionnaireMatch:   return .purple
        }
    }

    private var icon: String {
        switch signal.type {
        case .birthdayToday, .birthday1Day, .birthday3Day: return "gift.fill"
        case .sharedCalendarEvent:  return "calendar.badge.clock"
        case .questionnaireMatch:   return "person.2.fill"
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(signal.notificationTitle)
                        .font(.amberBody.weight(.semibold))
                        .foregroundColor(.amberText)
                        .multilineTextAlignment(.leading)

                    Text(signal.triggerDate, style: .relative)
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
        .contextMenu {
            Button(role: .destructive) {
                dismissSignal()
            } label: {
                Label("Dismiss", systemImage: "xmark.circle")
            }
        }
    }

    private func dismissSignal() {
        signal.status = SignalStatus.dismissed.rawValue
        try? context.save()
    }
}

// MARK: - Empty state

private struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(.amberGold.opacity(0.5))
            Text("All caught up")
                .font(.amberTitle2)
                .foregroundColor(.amberText)
            Text("Amber will surface suggestions as events and occasions come up.")
                .font(.amberBody)
                .foregroundColor(.amberSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
