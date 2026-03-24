//
//  AuthViewModel.swift
//  AmberApp
//
//  Created on 2026-03-04.
//

import SwiftUI
import Combine
import PrivySDK

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = true
    @Published var error: String?
    @Published var accessToken: String?

    // Email OTP flow state
    @Published var isAwaitingOTP: Bool = false
    @Published var pendingEmail: String?

    private var privy: Privy?
    private var authStateTask: Task<Void, Never>?

    init() {
        let config = PrivyConfig(
            appId: AppConfig.privyAppId,
            appClientId: AppConfig.privyAppClientId
        )
        privy = PrivySdk.initialize(config: config)
        observeAuthState()
    }

    deinit {
        authStateTask?.cancel()
    }

    // MARK: - Auth State Observation

    private func observeAuthState() {
        guard let privy else { return }
        authStateTask = Task {
            for await authState in privy.authStateStream {
                switch authState {
                case .authenticated(let user):
                    do {
                        let token = try await user.getAccessToken()
                        self.accessToken = token
                        APIClient.shared.accessToken = token
                        self.isAuthenticated = true
                    } catch {
                        self.isAuthenticated = true // still authed, token refresh may retry
                    }
                    self.isLoading = false
                case .unauthenticated:
                    self.accessToken = nil
                    APIClient.shared.accessToken = nil
                    self.isAuthenticated = false
                    self.isLoading = false
                case .notReady:
                    self.isLoading = true
                case .authenticatedUnverified:
                    // Cached session, no network — treat as authenticated optimistically
                    self.isAuthenticated = true
                    self.isLoading = false
                @unknown default:
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Email OTP Login

    /// Step 1: Send OTP code to email
    func sendEmailCode(to email: String) {
        guard let privy else { return }
        isLoading = true
        error = nil
        Task {
            do {
                try await privy.email.sendCode(to: email)
                pendingEmail = email
                isAwaitingOTP = true
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }

    /// Step 2: Verify OTP and complete login
    func verifyEmailCode(_ code: String) {
        guard let privy, let email = pendingEmail else { return }
        isLoading = true
        error = nil
        Task {
            do {
                let user = try await privy.email.loginWithCode(code, sentTo: email)
                let token = try await user.getAccessToken()
                accessToken = token
                APIClient.shared.accessToken = token
                isAuthenticated = true
                isAwaitingOTP = false
                pendingEmail = nil
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }

    // MARK: - OAuth Login (Google, Apple)

    func loginWithGoogle() {
        guard let privy else { return }
        isLoading = true
        error = nil
        Task {
            do {
                let user = try await privy.oAuth.login(
                    with: .google,
                    appUrlScheme: AppConfig.urlScheme
                )
                let token = try await user.getAccessToken()
                accessToken = token
                APIClient.shared.accessToken = token
                isAuthenticated = true
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }

    func loginWithApple() {
        guard let privy else { return }
        isLoading = true
        error = nil
        Task {
            do {
                let user = try await privy.oAuth.login(
                    with: .apple,
                    appUrlScheme: AppConfig.urlScheme
                )
                let token = try await user.getAccessToken()
                accessToken = token
                APIClient.shared.accessToken = token
                isAuthenticated = true
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }

    // MARK: - Logout

    func logout() {
        Task {
            if let user = await privy?.getUser() {
                await user.logout()
            }
            accessToken = nil
            APIClient.shared.accessToken = nil
            isAuthenticated = false
        }
    }

    // MARK: - Session Check

    func checkSession() {
        // Auth state is observed via authStateStream — this is called on appear
        // to trigger initial state evaluation
        guard let privy else {
            isLoading = false
            return
        }
        Task {
            let state = await privy.getAuthState()
            switch state {
            case .authenticated(let user):
                do {
                    let token = try await user.getAccessToken()
                    accessToken = token
                    APIClient.shared.accessToken = token
                    isAuthenticated = true
                } catch {
                    isAuthenticated = false
                }
                isLoading = false
            case .unauthenticated:
                isAuthenticated = false
                isLoading = false
            case .notReady:
                break // stream will handle it
            case .authenticatedUnverified:
                isAuthenticated = true
                isLoading = false
            @unknown default:
                isLoading = false
            }
        }
    }
}

// MARK: - App Configuration

enum AppConfig {
    // TODO: Replace with your Privy Dashboard values
    static let privyAppId = "INSERT_PRIVY_APP_ID"
    static let privyAppClientId = "INSERT_PRIVY_APP_CLIENT_ID"
    static let urlScheme = "amberapp"

    // Backend
    #if DEBUG
    static let apiBaseURL = "http://localhost:8080"
    #else
    static let apiBaseURL = "https://amber-app-service-HASH.a.run.app" // TODO: Replace with Cloud Run URL
    #endif
}
