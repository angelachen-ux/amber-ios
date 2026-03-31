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
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            Color.amberBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.amberWarm.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .blur(radius: 30)
                        .scaleEffect(glowPulse ? 1.3 : 0.8)

                    Image("AmberLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                }

                ProgressView()
                    .tint(.amberWarm)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - Content View (5-tab Instagram-style layout)

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 2 // Start on Amber AI (center)
    @State private var networkInputText = ""
    @FocusState private var isNetworkInputFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.amberBackground.ignoresSafeArea()

            // Content views
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

            // Bottom stack: input bar + tab bar
            VStack(spacing: 0) {
                // Network input bar — only on Amber AI tab
                if selectedTab == 2 {
                    NetworkInputBar(inputText: $networkInputText, isInputFocused: $isNetworkInputFocused)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 6)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
        .preferredColorScheme(.dark)
        .environmentObject(authViewModel)
    }
}
