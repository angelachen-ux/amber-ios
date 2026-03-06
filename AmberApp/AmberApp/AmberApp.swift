//
//  AmberApp.swift
//  AmberApp
//
//  Created on 2026-01-17.
//

import SwiftUI
import SwiftData

@main
struct AmberApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [UserProfile.self, Contact.self, Signal.self, Circle.self])
    }
}

// MARK: - Root View (handles onboarding gate)

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]

    private var isOnboarded: Bool {
        profiles.first?.onboardingComplete == true
    }

    var body: some View {
        if isOnboarded {
            MainTabView()
        } else {
            OnboardingView {
                // onComplete — SwiftData @Query will update automatically
            }
        }
    }
}

// MARK: - Main Tab View (post-onboarding)

struct MainTabView: View {
    @State private var selectedTab = 1

    var body: some View {
        ZStack {
            Group {
                if selectedTab == 0 {
                    ConnectionsView(searchText: .constant(""))
                } else if selectedTab == 1 {
                    SuggestionFeedView()
                } else {
                    AmberIDView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab, searchText: .constant(""))
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}
