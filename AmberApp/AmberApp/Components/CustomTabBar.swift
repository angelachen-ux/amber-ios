//
//  CustomTabBar.swift
//  Amber
//
//  Created on 2026-01-18.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var searchText: String
    @Namespace private var animation

    var body: some View {
        VStack(spacing: 0) {
            // Search bar extension - only shows when on Contacts tab
            if selectedTab == 1 {
                LiquidGlassSearchBar(searchText: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // iOS-style liquid glass tab bar
            HStack(spacing: 0) {
                // Messages
                TabBarButton(
                    icon: "bubble.left.and.bubble.right.fill",
                    label: "Messages",
                    isSelected: selectedTab == 0,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 0
                    }
                }

                // Contacts
                TabBarButton(
                    icon: "person.2.fill",
                    label: "Contacts",
                    isSelected: selectedTab == 1,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 1
                    }
                }

                // Network
                TabBarButton(
                    icon: "sparkles",
                    label: "Network",
                    isSelected: selectedTab == 2,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 2
                    }
                }

                // Profile
                TabBarButton(
                    icon: "person.circle.fill",
                    label: "Profile",
                    isSelected: selectedTab == 3,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 3
                    }
                }

                // Feed
                TabBarButton(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Feed",
                    isSelected: selectedTab == 4,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 4
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 36, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.amberBlue : Color.primary.opacity(0.5))
                    .frame(height: 24)

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.amberBlue : Color.primary.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.amberBlue.opacity(0.12))
                        .matchedGeometryEffect(id: "TAB_BACKGROUND", in: namespace)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
