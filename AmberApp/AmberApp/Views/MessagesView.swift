//
//  MessagesView.swift
//  AmberApp
//
//  Created on 2026-03-24.
//

import SwiftUI

// MARK: - Data Models

struct Organization: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let channels: [Channel]
    let unreadCount: Int

    var totalUnread: Int {
        channels.reduce(0) { $0 + $1.unreadCount }
    }
}

struct Channel: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let lastMessage: String
    let lastMessageTime: String
    let unreadCount: Int
    let isPinned: Bool
}

struct DirectMessage: Identifiable {
    let id = UUID()
    let name: String
    let avatarEmoji: String
    let lastMessage: String
    let lastMessageTime: String
    let unreadCount: Int
    let isOnline: Bool
}

// MARK: - Messages View

struct MessagesView: View {
    @State private var searchText = ""
    @State private var selectedOrg: Organization?
    @State private var showOrgList = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Direct Messages
                        dmSection

                        // Organizations
                        ForEach(sampleOrgs) { org in
                            orgSection(org)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 140)
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.amberBlue)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search messages")
        }
    }

    // MARK: - Direct Messages

    private var dmSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.amberBlue)
                Text("Direct Messages")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(sampleDMs.filter { $0.unreadCount > 0 }.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.amberBlue, in: Capsule())
                    .opacity(sampleDMs.contains { $0.unreadCount > 0 } ? 1 : 0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(sampleDMs.enumerated()), id: \.element.id) { index, dm in
                    dmRow(dm)
                    if index < sampleDMs.count - 1 {
                        Divider().padding(.leading, 72)
                    }
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    private func dmRow(_ dm: DirectMessage) -> some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Text(dm.avatarEmoji)
                    .font(.system(size: 24))
                    .frame(width: 48, height: 48)
                    .background(Color.amberBlue.opacity(0.1), in: Circle())

                if dm.isOnline {
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color(UIColor.systemGroupedBackground), lineWidth: 2))
                        .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(dm.name)
                        .font(.system(size: 16, weight: dm.unreadCount > 0 ? .semibold : .regular))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(dm.lastMessageTime)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(dm.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Spacer()
                    if dm.unreadCount > 0 {
                        Text("\(dm.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.amberBlue, in: Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    // MARK: - Organization Section

    private func orgSection(_ org: Organization) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Org header
            HStack(spacing: 10) {
                Image(systemName: org.icon)
                    .font(.system(size: 14))
                    .foregroundColor(org.color)
                Text(org.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                if org.totalUnread > 0 {
                    Text("\(org.totalUnread)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(org.color, in: Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(org.channels.enumerated()), id: \.element.id) { index, channel in
                    channelRow(channel, color: org.color)
                    if index < org.channels.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    private func channelRow(_ channel: Channel, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: channel.icon)
                .font(.system(size: 16))
                .foregroundColor(color.opacity(0.8))
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    if channel.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.amberGold)
                    }
                    Text(channel.name)
                        .font(.system(size: 15, weight: channel.unreadCount > 0 ? .semibold : .regular))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(channel.lastMessageTime)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(channel.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Spacer()
                    if channel.unreadCount > 0 {
                        Text("\(channel.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(color, in: Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    // MARK: - Sample Data

    private var sampleDMs: [DirectMessage] {
        [
            DirectMessage(name: "Sindhu Tiwari", avatarEmoji: "👩", lastMessage: "sounds good, see you sunday!", lastMessageTime: "2m", unreadCount: 1, isOnline: true),
            DirectMessage(name: "Rohan Mehta", avatarEmoji: "🧑", lastMessage: "let me know when you're free", lastMessageTime: "15m", unreadCount: 2, isOnline: true),
            DirectMessage(name: "Priya Sharma", avatarEmoji: "👩‍💻", lastMessage: "the deck looks great", lastMessageTime: "1h", unreadCount: 0, isOnline: false),
            DirectMessage(name: "Chetna Tiwari", avatarEmoji: "👩‍🦰", lastMessage: "call me when you can beta", lastMessageTime: "3h", unreadCount: 1, isOnline: false),
        ]
    }

    private var sampleOrgs: [Organization] {
        [
            Organization(
                name: "Amber Health",
                icon: "building.2.fill",
                color: .amberBlue,
                channels: [
                    Channel(name: "general", icon: "number", lastMessage: "Sprint review at 3pm", lastMessageTime: "10m", unreadCount: 3, isPinned: true),
                    Channel(name: "engineering", icon: "chevron.left.forwardslash.chevron.right", lastMessage: "PR merged — Privy auth migration", lastMessageTime: "25m", unreadCount: 1, isPinned: true),
                    Channel(name: "design", icon: "paintbrush.fill", lastMessage: "new mockups in Figma", lastMessageTime: "1h", unreadCount: 0, isPinned: false),
                    Channel(name: "standup", icon: "clock.fill", lastMessage: "blocker: need API keys from ops", lastMessageTime: "2h", unreadCount: 0, isPinned: false),
                ],
                unreadCount: 4
            ),
            Organization(
                name: "BMA Team",
                icon: "briefcase.fill",
                color: .healthFinancial,
                channels: [
                    Channel(name: "deals", icon: "dollarsign.circle.fill", lastMessage: "new lead from Chicago — healthcare system", lastMessageTime: "30m", unreadCount: 2, isPinned: true),
                    Channel(name: "strategy", icon: "lightbulb.fill", lastMessage: "Q2 pricing update finalized", lastMessageTime: "4h", unreadCount: 0, isPinned: false),
                    Channel(name: "content", icon: "doc.text.fill", lastMessage: "blog post draft ready for review", lastMessageTime: "1d", unreadCount: 0, isPinned: false),
                ],
                unreadCount: 2
            ),
            Organization(
                name: "TIZZY GHINDIS",
                icon: "flame.fill",
                color: .healthEmotional,
                channels: [
                    Channel(name: "hangouts", icon: "party.popper.fill", lastMessage: "who's down for friday?", lastMessageTime: "45m", unreadCount: 5, isPinned: true),
                    Channel(name: "sports", icon: "figure.run", lastMessage: "bulls game tickets secured", lastMessageTime: "2h", unreadCount: 0, isPinned: false),
                    Channel(name: "food", icon: "fork.knife", lastMessage: "new ramen spot on Clark", lastMessageTime: "5h", unreadCount: 0, isPinned: false),
                ],
                unreadCount: 5
            ),
            Organization(
                name: "Family",
                icon: "heart.fill",
                color: .healthSpiritual,
                channels: [
                    Channel(name: "tiwari-clan", icon: "house.fill", lastMessage: "dinner at 7 on Saturday?", lastMessageTime: "1h", unreadCount: 1, isPinned: true),
                    Channel(name: "photos", icon: "photo.fill", lastMessage: "Chetna shared 3 photos", lastMessageTime: "3h", unreadCount: 0, isPinned: false),
                ],
                unreadCount: 1
            ),
        ]
    }
}

#Preview {
    MessagesView()
}
