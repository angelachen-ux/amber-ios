//
//  ContactsView.swift
//  Amber
//
//  Liquid glass contacts list with grouped sections.
//

import SwiftUI

// MARK: - Data Models

enum ConnectionCadence: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case none = "No reminder"

    var shortLabel: String {
        switch self {
        case .weekly: return "1w"
        case .monthly: return "1mo"
        case .quarterly: return "3mo"
        case .none: return ""
        }
    }

    var days: Int {
        switch self {
        case .weekly: return 7
        case .monthly: return 30
        case .quarterly: return 90
        case .none: return Int.max
        }
    }
}

struct AmberContact: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let isOnAmber: Bool
    let avatarColor: Color
    let groups: [String]
    let cadence: ConnectionCadence
    let daysSinceContact: Int

    var firstLetter: String {
        String(name.prefix(1)).uppercased()
    }

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }

    var firstName: String {
        String(name.split(separator: " ").first ?? Substring(name))
    }

    var isOverdue: Bool {
        cadence != .none && daysSinceContact > cadence.days
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AmberContact, rhs: AmberContact) -> Bool {
        lhs.id == rhs.id
    }
}

struct ContactGroup: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let members: [String]
}

// MARK: - ContactsView

struct ContactsView: View {
    @State private var searchText: String = ""
    @State private var showAddContact: Bool = false

    // MARK: - Sample Data

    private let contactGroups: [ContactGroup] = [
        ContactGroup(name: "USC", icon: "building.columns.fill", members: ["Angela Chen", "Arjun Patel", "Michelle Wong"]),
        ContactGroup(name: "Amber Team", icon: "hexagon.fill", members: ["Angela Chen", "Dev Kapoor", "Kaitlyn Rivera", "Victor Huang"]),
        ContactGroup(name: "BMA", icon: "briefcase.fill", members: ["Rohan Mehta"]),
        ContactGroup(name: "Family", icon: "heart.fill", members: ["Chetna Tiwari", "Sindhu Tiwari", "Umesh Tiwari"]),
        ContactGroup(name: "Other", icon: "person.fill", members: ["Priya Sharma"]),
    ]

    private let sampleContacts: [AmberContact] = [
        AmberContact(name: "Angela Chen", subtitle: "Design Lead, Amber", isOnAmber: true, avatarColor: .healthEmotional, groups: ["USC", "Amber Team"], cadence: .weekly, daysSinceContact: 3),
        AmberContact(name: "Arjun Patel", subtitle: "USC '29", isOnAmber: false, avatarColor: .amberGold, groups: ["USC"], cadence: .monthly, daysSinceContact: 8),
        AmberContact(name: "Chetna Tiwari", subtitle: "Mom", isOnAmber: false, avatarColor: .healthSpiritual, groups: ["Family"], cadence: .weekly, daysSinceContact: 2),
        AmberContact(name: "Dev Kapoor", subtitle: "MAYA Biotech", isOnAmber: true, avatarColor: .healthPhysical, groups: ["Amber Team"], cadence: .monthly, daysSinceContact: 14),
        AmberContact(name: "Kaitlyn Rivera", subtitle: "Product, Amber", isOnAmber: true, avatarColor: .healthSocial, groups: ["Amber Team"], cadence: .weekly, daysSinceContact: 5),
        AmberContact(name: "Michelle Wong", subtitle: "USC Volleyball", isOnAmber: false, avatarColor: .healthEmotional, groups: ["USC"], cadence: .quarterly, daysSinceContact: 10),
        AmberContact(name: "Priya Sharma", subtitle: "Engineer", isOnAmber: true, avatarColor: .healthFinancial, groups: ["Other"], cadence: .monthly, daysSinceContact: 25),
        AmberContact(name: "Rohan Mehta", subtitle: "BMA Team", isOnAmber: false, avatarColor: .amberWarm, groups: ["BMA"], cadence: .monthly, daysSinceContact: 18),
        AmberContact(name: "Sindhu Tiwari", subtitle: "Sister", isOnAmber: false, avatarColor: .healthSpiritual, groups: ["Family"], cadence: .weekly, daysSinceContact: 4),
        AmberContact(name: "Umesh Tiwari", subtitle: "Dad", isOnAmber: false, avatarColor: .amberPrimary, groups: ["Family"], cadence: .weekly, daysSinceContact: 2),
        AmberContact(name: "Victor Huang", subtitle: "Product Strategy", isOnAmber: true, avatarColor: .healthIntellectual, groups: ["Amber Team"], cadence: .quarterly, daysSinceContact: 21),
    ]

    // MARK: - Computed Properties

    private var filteredContacts: [AmberContact] {
        guard !searchText.isEmpty else { return sampleContacts }
        return sampleContacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredGroups: [ContactGroup] {
        contactGroups.compactMap { group in
            let members = group.members.filter { memberName in
                filteredContacts.contains { $0.name == memberName }
            }
            guard !members.isEmpty else { return nil }
            return ContactGroup(name: group.name, icon: group.icon, members: members)
        }
    }

    private var overdueContacts: [AmberContact] {
        filteredContacts.filter { $0.isOverdue }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        LiquidGlassSearchBar(
                            searchText: $searchText,
                            placeholder: "Search contacts"
                        )
                        .padding(.horizontal, 16)

                        // Reconnection Stories Strip
                        if !overdueContacts.isEmpty {
                            reconnectionStrip
                        }

                        ForEach(filteredGroups) { group in
                            groupSection(group)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("People")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddContact = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.amberText)
                    }
                }
            }
            .sheet(isPresented: $showAddContact) {
                AddContactView()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Reconnection Stories Strip

    private var reconnectionStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reconnect")
                .amberSectionHeader()
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(overdueContacts) { contact in
                        storyBubble(contact)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func storyBubble(_ contact: AmberContact) -> some View {
        VStack(spacing: 4) {
            ZStack {
                // Gradient ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [contact.avatarColor, contact.avatarColor.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 64, height: 64)

                // Inner avatar
                Circle()
                    .fill(Color.amberSurface)
                    .frame(width: 48, height: 48)

                Text(contact.initials)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(contact.firstName)
                .font(.amberCaption2)
                .foregroundStyle(Color.amberText)
                .lineLimit(1)
                .frame(maxWidth: 64)
        }
    }

    // MARK: - Group Section

    private func groupSection(_ group: ContactGroup) -> some View {
        let groupContacts = group.members.compactMap { memberName in
            filteredContacts.first { $0.name == memberName }
        }

        return VStack(spacing: 0) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text(group.name)
                    .font(.amberHeadline)
                    .foregroundStyle(Color.amberText)

                Text("\(groupContacts.count)")
                    .font(.amberCaption)
                    .foregroundStyle(Color.amberSecondaryText)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Contact rows
            ForEach(Array(groupContacts.enumerated()), id: \.element.id) { index, contact in
                contactRow(contact)

                if index < groupContacts.count - 1 {
                    Color.glassStroke
                        .frame(height: 0.5)
                        .padding(.leading, 60)
                }
            }

            Spacer()
                .frame(height: 16)
        }
        .liquidGlassCard()
        .padding(.horizontal, 16)
    }

    // MARK: - Contact Row

    private func contactRow(_ contact: AmberContact) -> some View {
        HStack(spacing: 12) {
            // Colored initials avatar
            ZStack {
                Circle()
                    .fill(contact.avatarColor)
                    .frame(width: 44, height: 44)

                Text(contact.initials)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.amberBody)
                    .foregroundStyle(Color.amberText)

                Text(contact.subtitle)
                    .font(.amberCaption)
                    .foregroundStyle(Color.amberSecondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.amberTertiaryText)
        }
        .padding(.horizontal, 12)
        .frame(height: 56)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    ContactsView()
}
