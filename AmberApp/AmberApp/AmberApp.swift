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
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

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
                } else if !hasCompletedOnboarding {
                    OnboardingContainerView {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            hasCompletedOnboarding = true
                        }
                    }
                    .environmentObject(authViewModel)
                } else {
                    ContentView()
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                #if DEBUG && targetEnvironment(simulator)
                authViewModel.devBypassLogin()
                #else
                authViewModel.checkSession()
                #endif
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 2 // Start on Network (center)
    @State private var searchText = ""
    @State private var networkInputText = ""
    @FocusState private var isNetworkInputFocused: Bool

    var body: some View {
        ZStack {
            // Content views
            Group {
                switch selectedTab {
                case 0:
                    MessagesView()
                case 1:
                    ConnectionsView(searchText: $searchText)
                case 2:
                    DiscoverView()
                case 3:
                    AmberIDView()
                case 4:
                    FeedView()
                default:
                    DiscoverView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Network input bar - only shows when on Network tab
            VStack {
                Spacer()
                if selectedTab == 2 {
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
