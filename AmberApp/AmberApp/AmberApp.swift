//
//  AmberApp.swift
//  AmberApp
//
//  Created on 2026-01-17.
//

import SwiftUI

@main
struct AmberApp: App {
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoading {
                    // Splash / session check
                    ZStack {
                        Color.amberBackground.ignoresSafeArea()
                        ProgressView()
                            .tint(.amberBlue)
                    }
                } else if !authViewModel.isAuthenticated {
                    LoginView()
                        .environmentObject(authViewModel)
                } else {
                    // TODO: Add onboarding check here
                    // if !onboarded { OnboardingContainerView() } else { ContentView() }
                    ContentView()
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                authViewModel.checkSession()
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 1 // Start on Network (center)
    @State private var searchText = ""
    @State private var networkInputText = ""
    @FocusState private var isNetworkInputFocused: Bool

    var body: some View {
        ZStack {
            // Content views
            Group {
                if selectedTab == 0 {
                    ConnectionsView(searchText: $searchText)
                } else if selectedTab == 1 {
                    DiscoverView()
                } else {
                    AmberIDView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Network input bar - only shows when on Network tab
            VStack {
                Spacer()
                if selectedTab == 1 {
                    NetworkInputBar(inputText: $networkInputText, isInputFocused: $isNetworkInputFocused)
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                CustomTabBar(selectedTab: $selectedTab, searchText: $searchText)
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}
