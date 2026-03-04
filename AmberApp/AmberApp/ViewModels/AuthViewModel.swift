//
//  AuthViewModel.swift
//  AmberApp
//
//  Created on 2026-03-04.
//

import SwiftUI
import Auth0

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var accessToken: String?

    private let credentialsManager = CredentialsManager(authentication: Auth0.authentication(
        clientId: "ytP3na2gIO9Wpsc4cEt1klmSbPF4ZAIe",
        domain: "dev-4prs757badfajpi5.us.auth0.com"
    ))

    private var webAuth: WebAuth {
        Auth0.webAuth(
            clientId: "ytP3na2gIO9Wpsc4cEt1klmSbPF4ZAIe",
            domain: "dev-4prs757badfajpi5.us.auth0.com"
        )
    }

    /// Log in via Auth0 Universal Login (supports email/password and social providers)
    func login() {
        isLoading = true
        error = nil

        Task {
            do {
                let credentials = try await webAuth
                    .scope("openid profile email offline_access")
                    .start()

                _ = credentialsManager.store(credentials: credentials)
                accessToken = credentials.accessToken
                isAuthenticated = true
                isLoading = false
            } catch WebAuthError.userCancelled {
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }

    /// Log in with Google connection specifically
    func loginWithGoogle() {
        isLoading = true
        error = nil

        Task {
            do {
                let credentials = try await webAuth
                    .connection("google-oauth2")
                    .scope("openid profile email offline_access")
                    .start()

                _ = credentialsManager.store(credentials: credentials)
                accessToken = credentials.accessToken
                isAuthenticated = true
                isLoading = false
            } catch WebAuthError.userCancelled {
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }

    /// Log out and clear stored credentials
    func logout() {
        isLoading = true
        error = nil

        Task {
            do {
                try await webAuth.clearSession()
                _ = credentialsManager.clear()
                accessToken = nil
                isAuthenticated = false
                isLoading = false
            } catch {
                // Clear local state even if remote logout fails
                _ = credentialsManager.clear()
                accessToken = nil
                isAuthenticated = false
                isLoading = false
            }
        }
    }

    /// Check for an existing valid session on app launch
    func checkSession() {
        guard credentialsManager.canRenew() else {
            isAuthenticated = false
            return
        }

        isLoading = true

        Task {
            do {
                let credentials = try await credentialsManager.credentials()
                accessToken = credentials.accessToken
                isAuthenticated = true
                isLoading = false
            } catch {
                _ = credentialsManager.clear()
                isAuthenticated = false
                isLoading = false
            }
        }
    }
}
