//
//  LoginView.swift
//  AmberApp
//
//  Created on 2026-03-04.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

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
                    Text("Sign in to Amber")
                        .font(.amberHeadline)
                        .foregroundColor(.white)

                    // Error message
                    if let error = authViewModel.error {
                        Text(error)
                            .font(.amberCaption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

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

                        // Continue with Email
                        Button(action: { authViewModel.login() }) {
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
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
