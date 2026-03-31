//
//  CustomTabBar.swift
//  Amber
//
//  Instagram-style liquid glass 5-tab navigation.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            // People (Contacts)
            TabBarItem(
                icon: "person.2.fill",
                iconInactive: "person.2",
                label: "People",
                isSelected: selectedTab == 0,
                namespace: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedTab = 0
                }
            }

            // Messages
            TabBarItem(
                icon: "bubble.left.and.bubble.right.fill",
                iconInactive: "bubble.left.and.bubble.right",
                label: "Messages",
                isSelected: selectedTab == 1,
                badgeCount: 7,
                namespace: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedTab = 1
                }
            }

            // Amber AI (center)
            TabBarItem(
                icon: "hexagon.fill",
                iconInactive: "hexagon",
                label: "Amber",
                isSelected: selectedTab == 2,
                isCenter: true,
                namespace: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedTab = 2
                }
            }

            // Daily Snapshot
            TabBarItem(
                icon: "square.stack.3d.up.fill",
                iconInactive: "square.stack.3d.up",
                label: "Today",
                isSelected: selectedTab == 3,
                namespace: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedTab = 3
                }
            }

        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 2)
        .background {
            // Instagram-style frosted glass
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    // Top hairline separator
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 0.33)
                }
                .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let iconInactive: String
    let label: String
    let isSelected: Bool
    var isCenter: Bool = false
    var badgeCount: Int = 0
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    if isCenter && isSelected {
                        // Subtle glow for center amber tab
                        Circle()
                            .fill(Color.amberWarm.opacity(0.1))
                            .frame(width: 36, height: 36)
                            .blur(radius: 6)
                    }

                    Image(systemName: isSelected ? icon : iconInactive)
                        .font(.system(size: isCenter ? 24 : 21))
                        .foregroundStyle(
                            isSelected
                                ? (isCenter ? AnyShapeStyle(Color.amberBrandGradient) : AnyShapeStyle(Color.amberText))
                                : AnyShapeStyle(Color.amberSecondaryText.opacity(0.5))
                        )
                        .frame(width: 28, height: 28)

                    // Badge
                    if badgeCount > 0 && !isSelected {
                        Text("\(badgeCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Color.amberWarm, in: Circle())
                            .offset(x: 8, y: -4)
                    }
                }

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(
                        isSelected
                            ? (isCenter ? Color.amberWarm : Color.amberText)
                            : Color.amberSecondaryText.opacity(0.5)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
    }
}
