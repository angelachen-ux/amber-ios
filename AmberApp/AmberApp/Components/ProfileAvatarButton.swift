//
//  ProfileAvatarButton.swift
//  AmberApp
//
//  Reusable 32pt toolbar avatar that opens AmberIDView as a draggable full-height sheet.
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
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.amberBlue, lineWidth: 1.5)
                    )

                Text("S")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.amberText)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showProfile) {
            AmberIDView()
                .environmentObject(authViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
