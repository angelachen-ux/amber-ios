//
//  ContactsView.swift
//  Amber
//
//  Premium contacts list with 2-tier search:
//  Tier 1: Local Apple Contacts (instant)
//  Tier 2: Exa.ai people discovery (auto-search)
//

import SwiftUI

// MARK: - Data Models

struct AmberContact: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let isOnAmber: Bool
    let avatarColor: Color

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

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AmberContact, rhs: AmberContact) -> Bool {
        lhs.id == rhs.id
    }
}

struct ReconnectPerson: Identifiable {
    let id = UUID()
    let name: String
    let context: String
    let ringColor: Color

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }
}

// MARK: - ContactsView

struct ContactsView: View {
    @State private var searchText: String = ""
    @State private var isSearchFocused: Bool = false
    @State private var showAddContact: Bool = false
    @StateObject private var exaSearch = ExaSearchService()

    private let reconnectPeople: [ReconnectPerson] = [
        ReconnectPerson(name: "Dev", context: "14 days", ringColor: .healthPhysical),
        ReconnectPerson(name: "Priya", context: "21 days", ringColor: .healthFinancial),
        ReconnectPerson(name: "Mom", context: "8 days", ringColor: .healthSpiritual),
        ReconnectPerson(name: "Arjun", context: "birthday!", ringColor: .amberGold),
        ReconnectPerson(name: "Michelle", context: "10 days", ringColor: .healthEmotional),
    ]

    private let sampleContacts: [AmberContact] = [
        AmberContact(name: "Angela Chen", subtitle: "Design Lead, Amber", isOnAmber: true, avatarColor: .healthEmotional),
        AmberContact(name: "Arjun Patel", subtitle: "USC '29", isOnAmber: false, avatarColor: .amberGold),
        AmberContact(name: "Chetna Tiwari", subtitle: "Mom", isOnAmber: false, avatarColor: .healthSpiritual),
        AmberContact(name: "Dev Kapoor", subtitle: "MAYA Biotech", isOnAmber: true, avatarColor: .healthPhysical),
        AmberContact(name: "Kaitlyn Rivera", subtitle: "Product, Amber", isOnAmber: true, avatarColor: .healthSocial),
        AmberContact(name: "Michelle Wong", subtitle: "USC Volleyball", isOnAmber: false, avatarColor: .healthEmotional),
        AmberContact(name: "Priya Sharma", subtitle: "Engineer", isOnAmber: true, avatarColor: .healthFinancial),
        AmberContact(name: "Rohan Mehta", subtitle: "BMA Team", isOnAmber: false, avatarColor: .amberWarm),
        AmberContact(name: "Sindhu Tiwari", subtitle: "Sister", isOnAmber: false, avatarColor: .healthSpiritual),
        AmberContact(name: "Umesh Tiwari", subtitle: "Dad", isOnAmber: false, avatarColor: .amberPrimary),
        AmberContact(name: "Victor Huang", subtitle: "Product Strategy", isOnAmber: true, avatarColor: .healthIntellectual),
    ]

    private var filteredContacts: [AmberContact] {
        if searchText.isEmpty { return sampleContacts }
        return sampleContacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedContacts: [(String, [AmberContact])] {
        let grouped = Dictionary(grouping: filteredContacts) { $0.firstLetter }
        return grouped.sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.amberBackground
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        // Search bar
                        searchBar
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 12)

                        // Reconnect section (hidden when searching)
                        if searchText.isEmpty {
                            reconnectSection
                                .padding(.bottom, 20)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Tier 1: Local contacts
                        if !filteredContacts.isEmpty {
                            if !searchText.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.crop.circle")
                                        .foregroundStyle(Color.amberSecondaryText)
                                    Text("YOUR CONTACTS")
                                }
                                .amberSectionHeader()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 8)
                            }

                            contactsList
                        }

                        // Tier 2: Exa people discovery
                        if !searchText.isEmpty {
                            exaResultsSection
                                .padding(.top, 16)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("People")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.amberBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showAddContact = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.amberWarm)
                        }

                        ProfileAvatarButton()
                    }
                }
            }
            .sheet(isPresented: $showAddContact) {
                AddContactView()
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: searchText)
        .onChange(of: searchText) { _, newValue in
            exaSearch.search(query: newValue)
        }
    }

    // MARK: - Exa Discovery Results

    private var exaResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .foregroundStyle(Color.amberWarm)
                Text("DISCOVER PEOPLE")
                if exaSearch.isSearching {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(.amberWarm)
                }
            }
            .amberSectionHeader()
            .padding(.horizontal, 20)

            if let error = exaSearch.error {
                Text(error)
                    .font(.amberCaption)
                    .foregroundStyle(Color.amberTertiaryText)
                    .padding(.horizontal, 20)
            } else if exaSearch.results.isEmpty && !exaSearch.isSearching {
                Text("Type to discover people beyond your contacts")
                    .font(.amberCaption)
                    .foregroundStyle(Color.amberTertiaryText)
                    .padding(.horizontal, 20)
            } else {
                ForEach(exaSearch.results) { person in
                    ExaPersonRow(person: person)
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.amberSecondaryText)

            TextField("Search people...", text: $searchText)
                .font(.amberCallout)
                .foregroundStyle(Color.amberText)
                .tint(Color.amberWarm)

            if !searchText.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.amberSecondaryText)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.amberCard, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
        )
    }

    // MARK: - Reconnect Section

    private var reconnectSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.amberGold)
                Text("RECONNECT")
            }
            .amberSectionHeader()
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(reconnectPeople) { person in
                        NavigationLink(value: person.id) {
                            reconnectCard(person: person)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func reconnectCard(person: ReconnectPerson) -> some View {
        VStack(spacing: 8) {
            // Avatar with colored ring
            ZStack {
                Circle()
                    .stroke(person.ringColor, lineWidth: 2.5)
                    .frame(width: 48, height: 48)

                Circle()
                    .fill(person.ringColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Text(person.initials)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(person.ringColor)
            }

            Text(person.name)
                .font(.amberCaption)
                .foregroundStyle(Color.amberText)
                .lineLimit(1)

            Text(person.context)
                .font(.amberCaption2)
                .foregroundStyle(person.context == "birthday!" ? Color.amberGold : Color.amberSecondaryText)
                .lineLimit(1)
        }
        .frame(width: 76)
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color.amberCard.opacity(0.6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.04), lineWidth: 0.5)
        )
    }

    // MARK: - Contacts List

    private var contactsList: some View {
        ForEach(groupedContacts, id: \.0) { letter, contacts in
            Section {
                ForEach(contacts) { contact in
                    NavigationLink(value: contact) {
                        ContactRow(contact: contact)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                sectionHeader(letter: letter)
            }
        }
        .navigationDestination(for: AmberContact.self) { contact in
            ContactDetailCard(contact: contact)
        }
    }

    private func sectionHeader(letter: String) -> some View {
        HStack {
            Text(letter)
                .amberSectionHeader()
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .background(Color.amberBackground)
    }
}

// MARK: - Contact Row

private struct ContactRow: View {
    let contact: AmberContact

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(contact.avatarColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Text(contact.initials)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(contact.avatarColor)
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

            if contact.isOnAmber {
                Circle()
                    .fill(Color.amberWarm)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

// MARK: - Contact Detail Card

struct ContactDetailCard: View {
    let contact: AmberContact
    @State private var notes: String = ""
    @Environment(\.dismiss) private var dismiss

    private var howYouMet: String {
        switch contact.name {
        case "Angela Chen": return "Joined Amber as Design Lead in November"
        case "Arjun Patel": return "Met at USC freshman orientation"
        case "Chetna Tiwari": return "Family"
        case "Dev Kapoor": return "Met through MAYA Biotech in January"
        case "Kaitlyn Rivera": return "Amber product team, started in December"
        case "Michelle Wong": return "USC Volleyball, met at a game in September"
        case "Priya Sharma": return "Connected through a hackathon last spring"
        case "Rohan Mehta": return "BMA Team member since launch"
        case "Sindhu Tiwari": return "Family"
        case "Umesh Tiwari": return "Family"
        case "Victor Huang": return "Introduced by a mutual friend at a product meetup"
        default: return "Met recently"
        }
    }

    private var daysKnown: Int {
        switch contact.name {
        case "Angela Chen": return 142
        case "Arjun Patel": return 210
        case "Chetna Tiwari": return 9125
        case "Dev Kapoor": return 87
        case "Kaitlyn Rivera": return 118
        case "Michelle Wong": return 195
        case "Priya Sharma": return 310
        case "Rohan Mehta": return 260
        case "Sindhu Tiwari": return 7300
        case "Umesh Tiwari": return 9125
        case "Victor Huang": return 64
        default: return 30
        }
    }

    private var sharedCircles: [String] {
        switch contact.name {
        case "Angela Chen": return ["Amber Team"]
        case "Arjun Patel": return ["USC '29", "TIZZY GHINDIS"]
        case "Chetna Tiwari": return ["Tiwari Family", "bonnie fan club"]
        case "Dev Kapoor": return ["MAYA Biotech", "Ambitious bros"]
        case "Kaitlyn Rivera": return ["Amber Team"]
        case "Michelle Wong": return ["USC Volleyball", "SSBD -> LIB and beyond"]
        case "Priya Sharma": return ["Ambitious bros"]
        case "Rohan Mehta": return ["BMA Team"]
        case "Sindhu Tiwari": return ["Tiwari Family", "bonnie fan club"]
        case "Umesh Tiwari": return ["Tiwari Family", "bonnie fan club"]
        case "Victor Huang": return ["Product Leaders"]
        default: return []
        }
    }

    var body: some View {
        ZStack {
            Color.amberBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Avatar with gradient ring
                    headerSection

                    // How you met
                    infoCard(title: "HOW YOU MET", content: howYouMet)

                    // Days known
                    daysKnownBadge

                    // Quick actions
                    quickActionsRow

                    // Shared circles
                    if !sharedCircles.isEmpty {
                        sharedCirclesSection
                    }

                    // Notes
                    notesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.amberBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [contact.avatarColor, contact.avatarColor.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 86, height: 86)

                Circle()
                    .fill(contact.avatarColor.opacity(0.15))
                    .frame(width: 80, height: 80)

                Text(contact.initials)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(contact.avatarColor)
            }

            VStack(spacing: 4) {
                Text(contact.name)
                    .font(.amberTitle2)
                    .foregroundStyle(Color.amberText)

                Text(contact.subtitle)
                    .font(.amberSubheadline)
                    .foregroundStyle(Color.amberSecondaryText)
            }

            if contact.isOnAmber {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.amberWarm)
                        .frame(width: 6, height: 6)
                    Text("on Amber")
                        .font(.amberCaption2)
                        .foregroundStyle(Color.amberWarm)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Info Card

    private func infoCard(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .amberSectionHeader()

            Text(content)
                .font(.amberBody)
                .foregroundStyle(Color.amberText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .amberCardStyle()
    }

    // MARK: - Days Known

    private var daysKnownBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.system(size: 13))
                .foregroundStyle(Color.amberGold)

            Text("Known for \(daysKnown) days")
                .font(.amberFootnote)
                .foregroundStyle(Color.amberSecondaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.amberGold.opacity(0.08), in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.amberGold.opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Quick Actions

    private var quickActionsRow: some View {
        HStack(spacing: 24) {
            quickActionButton(icon: "message.fill", label: "Message", color: .amberWarm)
            quickActionButton(icon: "phone.fill", label: "Call", color: .healthPhysical)
            quickActionButton(icon: "envelope.fill", label: "Email", color: .healthSocial)
        }
        .frame(maxWidth: .infinity)
    }

    private func quickActionButton(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
            }

            Text(label)
                .font(.amberCaption2)
                .foregroundStyle(Color.amberSecondaryText)
        }
    }

    // MARK: - Shared Circles

    private var sharedCirclesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SHARED CIRCLES")
                .amberSectionHeader()

            VStack(spacing: 0) {
                ForEach(sharedCircles, id: \.self) { circle in
                    HStack(spacing: 12) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.amberWarm)
                            .frame(width: 20)

                        Text(circle)
                            .font(.amberCallout)
                            .foregroundStyle(Color.amberText)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.amberTertiaryText)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)

                    if circle != sharedCircles.last {
                        Divider()
                            .background(Color.white.opacity(0.04))
                            .padding(.leading, 48)
                    }
                }
            }
            .amberCardStyle()
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NOTES")
                .amberSectionHeader()

            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Add a personal note...")
                        .font(.amberCallout)
                        .foregroundStyle(Color.amberTertiaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $notes)
                    .font(.amberCallout)
                    .foregroundStyle(Color.amberText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 80)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .amberCardStyle()
        }
    }
}

// MARK: - Exa Person Row

private struct ExaPersonRow: View {
    let person: ExaPerson

    private var sourceIcon: String {
        switch person.source {
        case "linkedin": return "link.circle.fill"
        case "twitter": return "at.circle.fill"
        default: return "globe"
        }
    }

    private var sourceColor: Color {
        switch person.source {
        case "linkedin": return .healthSocial
        case "twitter": return .amberText
        default: return .amberSecondaryText
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Avatar with globe indicator
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.amberWarm.opacity(0.1))
                    .frame(width: 40, height: 40)

                Text(String(person.name.prefix(1)).uppercased())
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.amberWarm)
                    .frame(width: 40, height: 40)

                // Source badge
                Image(systemName: sourceIcon)
                    .font(.system(size: 12))
                    .foregroundStyle(sourceColor)
                    .background(Color.amberBackground, in: Circle())
                    .offset(x: 3, y: 3)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(person.name)
                    .font(.amberBody)
                    .foregroundStyle(Color.amberText)
                    .lineLimit(1)

                if !person.title.isEmpty {
                    Text(person.title)
                        .font(.amberCaption)
                        .foregroundStyle(Color.amberSecondaryText)
                        .lineLimit(1)
                } else if !person.snippet.isEmpty {
                    Text(person.snippet)
                        .font(.amberCaption)
                        .foregroundStyle(Color.amberTertiaryText)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Add to contacts button
            Button {
                // TODO: Add to Amber contacts
            } label: {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.amberWarm)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    ContactsView()
        .preferredColorScheme(.dark)
}
