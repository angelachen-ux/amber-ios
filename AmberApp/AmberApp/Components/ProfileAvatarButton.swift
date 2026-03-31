//
//  ProfileAvatarButton.swift
//  Amber
//
//  Reusable toolbar avatar that opens AmberIDView as a sheet.
//

import SwiftUI

struct ProfileAvatarButton: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showProfile = false

    var body: some View {
        Button {
            showProfile = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.amberCard)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.amberBlue.opacity(0.9), .amberBlue.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                Text("S")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.amberText)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showProfile) {
            AmberIDView()
                .environmentObject(authViewModel)
        }
    }
}
