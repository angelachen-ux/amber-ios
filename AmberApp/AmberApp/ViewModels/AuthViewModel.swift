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
    @Published var isLoading: Bool = false
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

    // MARK: - Dev Bypass (DEBUG only)

    #if DEBUG
    /// Skip auth entirely for development — lets you test onboarding + full app
    func devBypassLogin() {
        accessToken = "dev-bypass-token"
        APIClient.shared.accessToken = "dev-bypass-token"
        isAuthenticated = true
        error = nil
    }
    #endif

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
                    break // don't block UI on SDK warmup
                case .authenticatedUnverified:
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
        guard let privy else {
            self.error = "Authentication service unavailable. Please restart the app."
            return
        }
        isLoading = true
        error = nil
        Task {
            do {
                try await privy.email.sendCode(to: email)
                pendingEmail = email
                isAwaitingOTP = true
                isLoading = false
            } catch {
                self.error = friendlyError(error)
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
                self.error = friendlyError(error)
                isLoading = false
            }
        }
    }

    // MARK: - OAuth Login (Google, Apple)

    func loginWithGoogle() {
        guard let privy else {
            self.error = "Authentication service unavailable. Please restart the app."
            return
        }
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
                self.error = friendlyError(error)
                isLoading = false
            }
        }
    }

    func loginWithApple() {
        guard let privy else {
            self.error = "Authentication service unavailable. Please restart the app."
            return
        }
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
                self.error = friendlyError(error)
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
        guard let privy else {
            isAuthenticated = false
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
                // Give the stream a moment, then fall through
                try? await Task.sleep(for: .seconds(2))
                if isLoading {
                    isAuthenticated = false
                    isLoading = false
                }
            case .authenticatedUnverified:
                isAuthenticated = true
                isLoading = false
            @unknown default:
                isAuthenticated = false
                isLoading = false
            }
        }
    }

    // MARK: - Helpers

    private func friendlyError(_ error: Error) -> String {
        let msg = error.localizedDescription
        if msg.contains("invalid_native_app_id") {
            return "App not registered with auth provider. Use \"Skip Login\" below to continue in dev mode."
        }
        if msg.lowercased().contains("cancel") {
            return "" // user cancelled — no error
        }
        return msg
    }
}

// MARK: - App Configuration

enum AppConfig {
    static let privyAppId = "cmisgt8wr00enjj0dkasj2xsz"
    static let privyAppClientId = "client-WY6TPkpcdSAbJ5eBEM3jw6rkpaR2KycrefbJehufX6yXX"
    static let urlScheme = "amberapp"

    // Backend
    #if DEBUG
    static let apiBaseURL = "http://localhost:8080"
    #else
    static let apiBaseURL = "https://amber-app-service-HASH.a.run.app" // TODO: Replace with Cloud Run URL
    #endif
}
