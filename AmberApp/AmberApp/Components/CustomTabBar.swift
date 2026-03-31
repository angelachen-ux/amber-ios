//
//  CustomTabBar.swift
//  Amber
//
//  Apple News+ quality liquid glass tab bar with rounded corners.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(
                icon: "person.2.fill",
                iconInactive: "person.2",
                label: "People",
                isSelected: selectedTab == 0,
                accentColor: .amberWarm,
                namespace: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    selectedTab = 0
                }
            }

            TabBarItem(
                icon: "bubble.left.and.bubble.right.fill",
                iconInactive: "bubble.left.and.bubble.right",
                label: "Messages",
                isSelected: selectedTab == 1,
                accentColor: .healthSocial,
                badgeCount: 7,
                namespace: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    selectedTab = 1
                }
            }

            TabBarItem(
                icon: "hexagon.fill",
                iconInactive: "hexagon",
                label: "Amber",
                isSelected: selectedTab == 2,
                accentColor: .amberWarm,
                isCenter: true,
                namespace: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    selectedTab = 2
                }
            }

            TabBarItem(
                icon: "square.stack.3d.up.fill",
                iconInactive: "square.stack.3d.up",
                label: "Today",
                isSelected: selectedTab == 3,
                accentColor: .healthPhysical,
                namespace: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    selectedTab = 3
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background {
            // Apple News+ style: rounded corners, thick glass, floating feel
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, y: -4)
                .padding(.horizontal, 8)
                .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let iconInactive: String
    let label: String
    let isSelected: Bool
    let accentColor: Color
    var isCenter: Bool = false
    var badgeCount: Int = 0
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? icon : iconInactive)
                        .font(.system(size: isCenter ? 24 : 22))
                        .foregroundStyle(
                            isSelected ? accentColor : Color.amberSecondaryText.opacity(0.6)
                        )
                        .frame(width: 28, height: 28)

                    if badgeCount > 0 && !isSelected {
                        Text("\(badgeCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Color.amberError, in: Circle())
                            .offset(x: 8, y: -4)
                    }
                }

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(
                        isSelected ? accentColor : Color.amberSecondaryText.opacity(0.6)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
    }
}
