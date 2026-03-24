//
//  LoginView.swift
//  AmberApp
//
//  Created on 2026-03-04.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEmailFlow = false
    @State private var email = ""
    @State private var otpCode = ""

    var body: some View {
        ZStack {
            Color.amberBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo and app name
                VStack(spacing: 16) {
                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.amberBlue, .amberGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Amber")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)

                    Text("Your Health Network")
                        .font(.amberBody)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Sign in section
                VStack(spacing: 20) {
                    if authViewModel.isAwaitingOTP {
                        Text("Enter Code")
                            .font(.amberHeadline)
                            .foregroundColor(.white)
                    } else if showEmailFlow {
                        Text("Sign in with Email")
                            .font(.amberHeadline)
                            .foregroundColor(.white)
                    } else {
                        Text("Sign in to Amber")
                            .font(.amberHeadline)
                            .foregroundColor(.white)
                    }

                    // Error message
                    if let error = authViewModel.error, !error.isEmpty {
                        Text(error)
                            .font(.amberCaption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    if authViewModel.isAwaitingOTP {
                        otpEntryView
                    } else if showEmailFlow {
                        emailEntryView
                    } else {
                        loginButtonsView
                    }

                    // Loading indicator
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.amberBlue)
                            .padding(.top, 8)
                    }
                }

                Spacer()

                // Footer
                Text("By continuing, you agree to Amber's Terms of Service and Privacy Policy.")
                    .font(.amberCaption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Login Buttons (matches original main layout)

    private var loginButtonsView: some View {
        VStack(spacing: 12) {
            // Continue with Google
            Button(action: { authViewModel.loginWithGoogle() }) {
                HStack(spacing: 12) {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 20))
                    Text("Continue with Google")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
            }
            .disabled(authViewModel.isLoading)

            // Continue with Apple
            Button(action: { authViewModel.loginWithApple() }) {
                HStack(spacing: 12) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20))
                    Text("Continue with Apple")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
            }
            .disabled(authViewModel.isLoading)

            // Divider
            HStack {
                Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
                Text("or").font(.amberCaption).foregroundColor(.gray)
                Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
            }

            // Continue with Email
            Button(action: { withAnimation(.spring(response: 0.3)) { showEmailFlow = true } }) {
                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 20))
                    Text("Continue with Email")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.amberBlue)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
            }
            .disabled(authViewModel.isLoading)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Email Entry

    private var emailEntryView: some View {
        VStack(spacing: 12) {
            TextField("Email address", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)

            Button(action: { authViewModel.sendEmailCode(to: email) }) {
                Text("Send Code")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.amberBlue)
                    )
            }
            .disabled(email.isEmpty || authViewModel.isLoading)

            Button("Back to sign in options") {
                withAnimation(.spring(response: 0.3)) {
                    showEmailFlow = false
                    email = ""
                    authViewModel.error = nil
                }
            }
            .font(.amberCaption)
            .foregroundColor(.amberBlue)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - OTP Entry

    private var otpEntryView: some View {
        VStack(spacing: 12) {
            if let email = authViewModel.pendingEmail {
                Text("Code sent to \(email)")
                    .font(.amberCaption)
                    .foregroundColor(.gray)
            }

            TextField("Enter 6-digit code", text: $otpCode)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)

            Button(action: { authViewModel.verifyEmailCode(otpCode) }) {
                Text("Verify")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.amberBlue)
                    )
            }
            .disabled(otpCode.count < 6 || authViewModel.isLoading)

            Button("Use a different method") {
                authViewModel.isAwaitingOTP = false
                authViewModel.pendingEmail = nil
                authViewModel.error = nil
                otpCode = ""
                showEmailFlow = false
            }
            .font(.amberCaption)
            .foregroundColor(.amberBlue)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
