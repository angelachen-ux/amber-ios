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
                    SplashView()
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

// MARK: - Splash

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Image("AmberLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)

                ProgressView()
                    .tint(.amberWarm)
            }
        }
    }
}

// MARK: - Content View (5-tab layout)

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 2

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            Group {
                switch selectedTab {
                case 0:
                    ContactsView()
                case 1:
                    MessagingView()
                case 2:
                    AmberAIView()
                case 3:
                    DailySnapshotView()
                default:
                    AmberAIView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedTab: $selectedTab)
                .ignoresSafeArea(.keyboard)
        }
        .preferredColorScheme(.dark)
        .environmentObject(authViewModel)
    }
}
