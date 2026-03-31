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
                    .fill(Color.amberSurface)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.amberBlue.opacity(0.7), lineWidth: 1.5)
                    )

                Text("S")
                    .font(.amberCaption)
                    .fontWeight(.semibold)
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
