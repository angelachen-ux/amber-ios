//
//  MessagingView.swift
//  AmberApp
//
//  Liquid glass messaging view — minimal, dark, zero clutter.
//

import SwiftUI

// MARK: - Data Models (CircleType defined in Models/Circle.swift)

struct ClosestPerson: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let isOnline: Bool
    let isActive: Bool
}

struct CircleConversation: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let type: CircleType
    let lastMessage: String
    let timeAgo: String
    let unreadCount: Int
    let hasAmberAgent: Bool
}

// MARK: - MessagingView

struct MessagingView: View {
    @State private var showCreateCircle = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    circlesSection
                    otherSection
                }
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showCreateCircle = true } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.amberText)
                    }
                }
            }
            .sheet(isPresented: $showCreateCircle) {
                createCirclePlaceholder
            }
        }
    }

    // MARK: - Circles Section

    private var circlesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Circles")
                .amberSectionHeader()
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(Array(circleConversations.enumerated()), id: \.element.id) { index, circle in
                    conversationRow(circle)

                    if index < circleConversations.count - 1 {
                        Divider()
                            .background(Color.glassStroke)
                            .padding(.leading, 72)
                    }
                }
            }
            .liquidGlassCard()
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Other Section

    private var otherSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Other")
                .amberSectionHeader()
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(Array(otherConversations.enumerated()), id: \.element.id) { index, circle in
                    conversationRow(circle)

                    if index < otherConversations.count - 1 {
                        Divider()
                            .background(Color.glassStroke)
                            .padding(.leading, 72)
                    }
                }
            }
            .liquidGlassCard()
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Conversation Row

    private func conversationRow(_ circle: CircleConversation) -> some View {
        HStack(spacing: 12) {
            // Icon container
            Circle()
                .fill(.regularMaterial)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: circle.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.amberSecondaryText)
                )

            // Content
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(circle.name)
                        .font(.amberBody)
                        .foregroundColor(.amberText)

                    if circle.hasAmberAgent {
                        Image(systemName: "hexagon.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.amberWarm)
                    }

                    Spacer()

                    Text(circle.timeAgo)
                        .font(.amberCaption)
                        .foregroundColor(.amberSecondaryText)
                }

                HStack {
                    Text(circle.lastMessage)
                        .font(.amberCaption)
                        .foregroundColor(.amberSecondaryText)
                        .lineLimit(1)

                    Spacer()

                    if circle.unreadCount > 0 {
                        Text("\(circle.unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(Color.amberBlue, in: Circle())
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    // MARK: - Create Circle Sheet

    private var createCirclePlaceholder: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.amberWarm)

                    Text("Create a Circle")
                        .font(.amberTitle2)
                        .foregroundColor(.amberText)

                    Text("Coming soon")
                        .font(.amberFootnote)
                        .foregroundColor(.amberSecondaryText)
                }

                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Sample Data

    private var closestPeople: [ClosestPerson] {
        [
            ClosestPerson(name: "Angela Chen", initials: "AC", isOnline: true, isActive: true),
            ClosestPerson(name: "Kaitlyn Lee", initials: "KL", isOnline: true, isActive: true),
            ClosestPerson(name: "Victor Reyes", initials: "VR", isOnline: false, isActive: true),
            ClosestPerson(name: "Michelle Park", initials: "MP", isOnline: true, isActive: false),
            ClosestPerson(name: "Rohan Mehta", initials: "RM", isOnline: false, isActive: true),
            ClosestPerson(name: "Priya Sharma", initials: "PS", isOnline: false, isActive: false),
            ClosestPerson(name: "Dev Patel", initials: "DP", isOnline: true, isActive: false),
            ClosestPerson(name: "Sindhu Tiwari", initials: "ST", isOnline: false, isActive: true),
        ]
    }

    private var circleConversations: [CircleConversation] {
        [
            CircleConversation(
                name: "MAYA Biotech",
                icon: "flask.fill",
                type: .manyToMany,
                lastMessage: "lab results came back — let's debrief tmrw",
                timeAgo: "4m",
                unreadCount: 3,
                hasAmberAgent: true
            ),
            CircleConversation(
                name: "Delta Gamma Chapter",
                icon: "triangle.fill",
                type: .manyToMany,
                lastMessage: "philanthropy event sign-ups due friday",
                timeAgo: "12m",
                unreadCount: 7,
                hasAmberAgent: false
            ),
            CircleConversation(
                name: "CS 270 Study Group",
                icon: "chevron.left.forwardslash.chevron.right",
                type: .manyToMany,
                lastMessage: "anyone free to review proofs tonight?",
                timeAgo: "28m",
                unreadCount: 2,
                hasAmberAgent: false
            ),
            CircleConversation(
                name: "Angela & Me",
                icon: "person.fill",
                type: .oneToOne,
                lastMessage: "omg yes that sounds perfect",
                timeAgo: "35m",
                unreadCount: 1,
                hasAmberAgent: true
            ),
            CircleConversation(
                name: "Victor & Me",
                icon: "person.fill",
                type: .oneToOne,
                lastMessage: "see you at the gym at 6",
                timeAgo: "1h",
                unreadCount: 0,
                hasAmberAgent: false
            ),
            CircleConversation(
                name: "Club Announcements",
                icon: "megaphone.fill",
                type: .oneToMany,
                lastMessage: "meeting moved to THH 301 this week",
                timeAgo: "2h",
                unreadCount: 0,
                hasAmberAgent: true
            ),
            CircleConversation(
                name: "Family",
                icon: "heart.fill",
                type: .manyToMany,
                lastMessage: "call me when you can beta",
                timeAgo: "3h",
                unreadCount: 1,
                hasAmberAgent: false
            ),
            CircleConversation(
                name: "Roommates",
                icon: "house.fill",
                type: .manyToMany,
                lastMessage: "who took my oat milk",
                timeAgo: "5h",
                unreadCount: 0,
                hasAmberAgent: false
            ),
        ]
    }

    private var otherConversations: [CircleConversation] {
        [
            CircleConversation(
                name: "USC Housing",
                icon: "building.2.fill",
                type: .oneToMany,
                lastMessage: "room selection opens April 1",
                timeAgo: "1d",
                unreadCount: 0,
                hasAmberAgent: false
            ),
            CircleConversation(
                name: "Intramural Soccer",
                icon: "figure.soccer",
                type: .manyToMany,
                lastMessage: "game rescheduled to wednesday",
                timeAgo: "2d",
                unreadCount: 0,
                hasAmberAgent: false
            ),
            CircleConversation(
                name: "Orientation Group 14",
                icon: "person.3.fill",
                type: .manyToMany,
                lastMessage: "throwback to week 1 lol",
                timeAgo: "5d",
                unreadCount: 0,
                hasAmberAgent: false
            ),
        ]
    }
}

// MARK: - Preview

#Preview {
    MessagingView()
        .preferredColorScheme(.dark)
}
