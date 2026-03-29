//
//  ProfileView.swift
//  AmberApp
//
//  Created on 2026-03-26.
//

import SwiftUI

// MARK: - Todo Item Model

struct TodoItem: Identifiable {
    let id = UUID()
    let title: String
    let context: String
    let linkedInitials: String?
    var isCompleted: Bool
}

// MARK: - Profile Tab

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: ProfileContentTab = .moments
    @Namespace private var tabNamespace

    // Sample to-do items
    @State private var todos: [TodoItem] = [
        TodoItem(title: "Reply to Angela about design review",      context: "Overdue by 2 days",    linkedInitials: "AC", isCompleted: false),
        TodoItem(title: "Call Mom",                                  context: "Weekly check-in",      linkedInitials: "CT", isCompleted: false),
        TodoItem(title: "Follow up with Rohan on BMA deck",         context: "Sent 3 days ago",      linkedInitials: "RM", isCompleted: false),
        TodoItem(title: "Send birthday message to Dev",             context: "Birthday is tomorrow",  linkedInitials: "DK", isCompleted: false),
        TodoItem(title: "Review Kaitlyn's product spec",            context: "Shared yesterday",      linkedInitials: "KR", isCompleted: true),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    contentTabSelector
                    contentBody
                }
                .padding(.bottom, 120)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("sagartiwari")
                        .font(.amberHeadline)
                        .foregroundStyle(Color.amberText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.amberText)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.glassStroke, lineWidth: 1)
                    )

                Text("ST")
                    .font(.amberTitle2)
                    .foregroundStyle(Color.amberText)
            }

            // Name and bio
            VStack(spacing: 4) {
                Text("Sagar Tiwari")
                    .font(.amberHeadline)
                    .foregroundStyle(Color.amberText)

                Text("Building the future of relationships")
                    .font(.amberCaption)
                    .foregroundStyle(Color.amberSecondaryText)
            }

            // Stats row
            HStack(spacing: 0) {
                profileStat(value: "127", label: "Contacts")
                profileStat(value: "12", label: "Circles")
                profileStat(value: "4", label: "Groups")
            }
            .padding(.top, 4)

            // Edit Profile button
            Button(action: {}) {
                Text("Edit Profile")
                    .font(.amberBody)
                    .foregroundStyle(Color.amberText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .padding(.top, 16)
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.amberTitle3)
                .foregroundStyle(Color.amberText)
            Text(label)
                .font(.amberCaption)
                .foregroundStyle(Color.amberSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Content Tab Selector

    private var contentTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ProfileContentTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(selectedTab == tab ? Color.amberText : Color.amberSecondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)

                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 2)

                            if selectedTab == tab {
                                Rectangle()
                                    .fill(Color.amberText)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "tab_indicator", in: tabNamespace)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Content Body

    @ViewBuilder
    private var contentBody: some View {
        switch selectedTab {
        case .moments:
            momentsGrid
        case .todos:
            todosView
        case .about:
            aboutView
        }
    }

    // MARK: - Moments Grid

    private var momentsGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(0..<9, id: \.self) { index in
                let icons = ["camera.fill", "heart.fill", "star.fill", "leaf.fill", "sun.max.fill",
                             "moon.fill", "figure.run", "music.note", "book.fill"]
                Color.amberSurface
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: icons[index % icons.count])
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(Color.amberTertiaryText)
                    )
            }
        }
        .padding(.top, 2)
    }

    // MARK: - Todos View

    private var todosView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Actions")
                .font(.amberHeadline)
                .foregroundStyle(Color.amberText)
                .padding(.horizontal, 16)

            ForEach(Array(todos.enumerated()), id: \.element.id) { index, item in
                todoRow(item: item, index: index)
            }

            // Add action button
            Button(action: {}) {
                HStack(spacing: 10) {
                    Circle()
                        .strokeBorder(Color.amberSecondaryText, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .frame(width: 22, height: 22)

                    Text("Add")
                        .font(.amberBody)
                        .foregroundStyle(Color.amberSecondaryText)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .amberCardStyle()
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 16)
    }

    private func todoRow(item: TodoItem, index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    todos[index].isCompleted.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(item.isCompleted ? Color.amberWarm : Color.amberSecondaryText, lineWidth: 1.5)
                        .frame(width: 22, height: 22)

                    if item.isCompleted {
                        Circle()
                            .fill(Color.amberWarm)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            // Title and context
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.amberBody)
                    .foregroundStyle(item.isCompleted ? Color.amberSecondaryText : Color.amberText)
                    .strikethrough(item.isCompleted, color: Color.amberSecondaryText)

                Text(item.context)
                    .font(.amberCaption)
                    .foregroundStyle(Color.amberSecondaryText)
            }

            Spacer()

            // Linked person avatar
            if let initials = item.linkedInitials {
                ZStack {
                    Circle()
                        .fill(Color.amberSurface)
                        .frame(width: 28, height: 28)

                    Text(initials)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.amberSecondaryText)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .amberCardStyle()
        .padding(.horizontal, 16)
    }

    // MARK: - About

    private var aboutView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Personal")
                    .amberSectionHeader()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    aboutRow(label: "Birthday", value: "Jun 15")
                    aboutDivider()
                    aboutRow(label: "Zodiac", value: "Gemini \u{264A}")
                    aboutDivider()
                    aboutRow(label: "MBTI", value: "ENTJ")
                    aboutDivider()
                    aboutRow(label: "Enneagram", value: "Type 3")
                }
                .amberCardStyle()
                .padding(.horizontal, 16)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("Connected Apps")
                    .amberSectionHeader()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    connectedAppRow(name: "Apple Health", icon: "heart.fill", color: .healthPhysical, isConnected: true)
                    aboutDivider()
                    connectedAppRow(name: "Google Calendar", icon: "calendar", color: .amberBlue, isConnected: true)
                    aboutDivider()
                    connectedAppRow(name: "Instagram", icon: "camera.fill", color: .healthEmotional, isConnected: false)
                    aboutDivider()
                    connectedAppRow(name: "Spotify", icon: "music.note", color: .healthSpiritual, isConnected: false)
                }
                .amberCardStyle()
                .padding(.horizontal, 16)
            }

            Button {
                authViewModel.logout()
            } label: {
                Text("Sign Out")
                    .font(.amberHeadline)
                    .foregroundStyle(Color.amberError)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.amberCard, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.amberError.opacity(0.2), lineWidth: 0.5)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .padding(.top, 20)
    }

    private func aboutRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.amberSubheadline)
                .foregroundStyle(Color.amberSecondaryText)

            Spacer()

            Text(value)
                .font(.amberSubheadline)
                .foregroundStyle(Color.amberText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    private func connectedAppRow(name: String, icon: String, color: Color, isConnected: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)

            Text(name)
                .font(.amberSubheadline)
                .foregroundStyle(Color.amberText)

            Spacer()

            Toggle("", isOn: .constant(isConnected))
                .labelsHidden()
                .tint(.amberWarm)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func aboutDivider() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.04))
            .frame(height: 0.5)
            .padding(.leading, 16)
    }
}

// MARK: - Supporting Types

private enum ProfileContentTab: String, CaseIterable, Identifiable {
    case moments, todos, about

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .moments: return "square.grid.2x2.fill"
        case .todos:   return "checklist"
        case .about:   return "info.circle.fill"
        }
    }
}

private struct ProfileTimelineEvent: Identifiable {
    let id = UUID()
    let monthAbbrev: String
    let day: String
    let title: String
    let description: String
    let people: [String]
    let tags: [String]

    static let samples: [ProfileTimelineEvent] = [
        .init(monthAbbrev: "Mar", day: "24",
              title: "Coffee chat with Angela",
              description: "Talked about Amber product strategy at Verve",
              people: ["AT", "ST"],
              tags: ["product", "amber"]),
        .init(monthAbbrev: "Mar", day: "20",
              title: "MAYA Biotech meeting",
              description: "Sprint review, planned next release",
              people: ["ST", "JL", "MR"],
              tags: ["work", "sprint"]),
        .init(monthAbbrev: "Mar", day: "15",
              title: "Family video call",
              description: "Talked about India trip in May",
              people: ["CT", "UT", "SiT"],
              tags: ["family"]),
        .init(monthAbbrev: "Mar", day: "10",
              title: "USC volleyball",
              description: "Met Michelle, great match",
              people: ["ST", "MK"],
              tags: ["social", "usc"]),
        .init(monthAbbrev: "Mar", day: "5",
              title: "Trip to SF",
              description: "Class trip, visited Anthropic office",
              people: ["ST", "RK", "NP"],
              tags: ["travel", "usc"]),
    ]
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
