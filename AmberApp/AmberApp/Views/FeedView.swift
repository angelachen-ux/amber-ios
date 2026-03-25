//
//  FeedView.swift
//  AmberApp
//
//  Created on 2026-03-24.
//

import SwiftUI

// MARK: - Data Models

enum FeedEventType {
    case coffeeChat
    case birthday
    case newConnection
    case milestone
    case healthWin
    case sharedExperience

    var icon: String {
        switch self {
        case .coffeeChat: return "cup.and.saucer.fill"
        case .birthday: return "birthday.cake.fill"
        case .newConnection: return "person.badge.plus"
        case .milestone: return "star.fill"
        case .healthWin: return "heart.fill"
        case .sharedExperience: return "figure.2.arms.open"
        }
    }

    var color: Color {
        switch self {
        case .coffeeChat: return .healthIntellectual
        case .birthday: return .healthEmotional
        case .newConnection: return .healthSocial
        case .milestone: return .amberGold
        case .healthWin: return .healthPhysical
        case .sharedExperience: return .healthSpiritual
        }
    }

    var label: String {
        switch self {
        case .coffeeChat: return "Coffee Chat"
        case .birthday: return "Birthday"
        case .newConnection: return "New Connection"
        case .milestone: return "Milestone"
        case .healthWin: return "Health Win"
        case .sharedExperience: return "Shared Moment"
        }
    }
}

struct FeedEvent: Identifiable {
    let id = UUID()
    let type: FeedEventType
    let headline: String
    let detail: String
    let people: [FeedPerson]
    let timeAgo: String
    let reactions: Int
    let comments: Int
}

struct FeedPerson: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
}

// MARK: - Feed View

struct FeedView: View {
    @State private var selectedFilter: FeedFilter = .all

    enum FeedFilter: String, CaseIterable {
        case all = "All"
        case friends = "Friends"
        case family = "Family"
        case milestones = "Milestones"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Filter chips
                        filterBar
                            .padding(.top, 4)

                        // Today section
                        sectionHeader("Today")
                        ForEach(todayEvents) { event in
                            FeedCard(event: event)
                        }

                        // Earlier section
                        sectionHeader("Earlier This Week")
                        ForEach(earlierEvents) { event in
                            FeedCard(event: event)
                        }

                        // Last Week section
                        sectionHeader("Last Week")
                        ForEach(lastWeekEvents) { event in
                            FeedCard(event: event)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 140)
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.amberBlue)
                            .overlay(alignment: .topTrailing) {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                    }
                }
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FeedFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }) {
                        Text(filter.rawValue)
                            .font(.system(size: 14, weight: selectedFilter == filter ? .semibold : .regular))
                            .foregroundColor(selectedFilter == filter ? .amberBlue : .primary.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter
                                    ? AnyShapeStyle(Color.amberBlue.opacity(0.12))
                                    : AnyShapeStyle(.regularMaterial),
                                in: Capsule()
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        selectedFilter == filter
                                            ? Color.amberBlue.opacity(0.3)
                                            : Color.white.opacity(0.15),
                                        lineWidth: 0.5
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Sample Data

    private var todayEvents: [FeedEvent] {
        [
            FeedEvent(
                type: .coffeeChat,
                headline: "Rohan had a coffee chat with Priya",
                detail: "They met up at Intelligentsia on Randolph and talked about the healthcare AI space. Rohan mentioned you should join next time.",
                people: [FeedPerson(name: "Rohan", emoji: "🧑"), FeedPerson(name: "Priya", emoji: "👩‍💻")],
                timeAgo: "2h ago",
                reactions: 4,
                comments: 1
            ),
            FeedEvent(
                type: .birthday,
                headline: "Sindhu's birthday is tomorrow!",
                detail: "Your sister turns 24 tomorrow. Don't forget to call her!",
                people: [FeedPerson(name: "Sindhu", emoji: "👩")],
                timeAgo: "5h ago",
                reactions: 12,
                comments: 3
            ),
            FeedEvent(
                type: .healthWin,
                headline: "You hit a 7-day meditation streak",
                detail: "Your spiritual health score moved up to 78. Keep it going — you're in the top 15% of your network.",
                people: [FeedPerson(name: "You", emoji: "🧘")],
                timeAgo: "6h ago",
                reactions: 8,
                comments: 0
            ),
        ]
    }

    private var earlierEvents: [FeedEvent] {
        [
            FeedEvent(
                type: .newConnection,
                headline: "Anika joined Amber",
                detail: "She's connected to 3 people in your network: Rohan, Priya, and Dev. You might know her from Northwestern.",
                people: [FeedPerson(name: "Anika", emoji: "👩‍🎓")],
                timeAgo: "1d ago",
                reactions: 6,
                comments: 2
            ),
            FeedEvent(
                type: .sharedExperience,
                headline: "Dev and Arjun ran the Lakefront 10K",
                detail: "They finished in 48 and 52 minutes respectively. Dev's physical health score is now 85.",
                people: [FeedPerson(name: "Dev", emoji: "🏃"), FeedPerson(name: "Arjun", emoji: "🏃‍♂️")],
                timeAgo: "2d ago",
                reactions: 15,
                comments: 4
            ),
            FeedEvent(
                type: .coffeeChat,
                headline: "Chetna caught up with Umesh over chai",
                detail: "Mom and dad's weekly chai session. They talked about the family trip to India next month.",
                people: [FeedPerson(name: "Chetna", emoji: "👩‍🦰"), FeedPerson(name: "Umesh", emoji: "👨")],
                timeAgo: "2d ago",
                reactions: 7,
                comments: 1
            ),
        ]
    }

    private var lastWeekEvents: [FeedEvent] {
        [
            FeedEvent(
                type: .milestone,
                headline: "Priya got promoted to Senior Engineer",
                detail: "She's been at the company for 2 years. Her intellectual health score jumped to 91.",
                people: [FeedPerson(name: "Priya", emoji: "👩‍💻")],
                timeAgo: "5d ago",
                reactions: 23,
                comments: 8
            ),
            FeedEvent(
                type: .newConnection,
                headline: "Rohan connected with 5 new people",
                detail: "His network grew by 12% this month. Most new connections are in fintech.",
                people: [FeedPerson(name: "Rohan", emoji: "🧑")],
                timeAgo: "6d ago",
                reactions: 3,
                comments: 0
            ),
            FeedEvent(
                type: .healthWin,
                headline: "Your social health score hit an all-time high",
                detail: "Score: 88. You've had meaningful interactions with 12 people this week, up from 8 last week.",
                people: [FeedPerson(name: "You", emoji: "⭐")],
                timeAgo: "7d ago",
                reactions: 11,
                comments: 2
            ),
        ]
    }
}

// MARK: - Feed Card

struct FeedCard: View {
    let event: FeedEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: icon + type label + time
            HStack(spacing: 8) {
                Image(systemName: event.type.icon)
                    .font(.system(size: 14))
                    .foregroundColor(event.type.color)
                    .frame(width: 28, height: 28)
                    .background(event.type.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text(event.type.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(event.type.color)

                Spacer()

                Text(event.timeAgo)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            // Headline
            Text(event.headline)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Detail
            Text(event.detail)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)

            // People avatars
            HStack(spacing: -6) {
                ForEach(event.people) { person in
                    Text(person.emoji)
                        .font(.system(size: 16))
                        .frame(width: 28, height: 28)
                        .background(Color.amberBlue.opacity(0.08), in: Circle())
                        .overlay(Circle().stroke(Color(UIColor.secondarySystemGroupedBackground), lineWidth: 2))
                }

                Spacer()

                // Reactions
                HStack(spacing: 12) {
                    if event.reactions > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "heart")
                                .font(.system(size: 13))
                            Text("\(event.reactions)")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(.secondary)
                    }
                    if event.comments > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 13))
                            Text("\(event.comments)")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    FeedView()
}
