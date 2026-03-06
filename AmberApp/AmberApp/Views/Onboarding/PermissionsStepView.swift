// ONBOARD-02: Permissions request flow — contextual "why" screens before each system prompt

import SwiftUI
import SwiftData

struct PermissionsStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    @Environment(\.modelContext) private var context
    @State private var isRequesting = false
    @State private var done = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text("A few things to make Amber work")
                    .font(.amberTitle)
                    .foregroundColor(.amberText)

                Text("Amber needs access to your contacts and notifications to surface suggestions. Your data never leaves your device unless you chose a cloud tier.")
                    .font(.amberBody)
                    .foregroundColor(.amberSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)

            VStack(spacing: 0) {
                PermissionRow(
                    icon: "person.crop.circle.fill",
                    color: .blue,
                    title: "Contacts",
                    description: "Amber reads your contact list to find the people you care about and remind you when they need you."
                )
                Divider().padding(.leading, 64)
                PermissionRow(
                    icon: "bell.badge.fill",
                    color: .amberGold,
                    title: "Notifications",
                    description: "Amber notifies you at the right moment — never at 3am, never more than you want."
                )
                Divider().padding(.leading, 64)
                PermissionRow(
                    icon: "calendar",
                    color: .green,
                    title: "Calendar",
                    description: "To find shared events — like a concert you're both attending — so you can reach out before it happens."
                )
                Divider().padding(.leading, 64)
                PermissionRow(
                    icon: "heart.fill",
                    color: .red,
                    title: "Health (optional)",
                    description: "Activity data unlocks behavioral insights in future versions. Nothing is shared without your permission."
                )
            }
            .background(Color.amberCardBackground)
            .cornerRadius(16)
            .padding(.horizontal, 24)

            Spacer()

            Button {
                isRequesting = true
                Task {
                    await vm.requestPermissions(context: context)
                    isRequesting = false
                    vm.advance()
                }
            } label: {
                HStack {
                    if isRequesting {
                        ProgressView().tint(.white)
                    }
                    Text(isRequesting ? "Setting up…" : "Grant Access & Continue")
                        .font(.amberBody.weight(.semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.amberGold)
                .cornerRadius(16)
            }
            .disabled(isRequesting)
            .padding(.horizontal, 32)
            .padding(.bottom, 16)

            Button("Skip for now") {
                vm.advance()
            }
            .font(.amberCaption)
            .foregroundColor(.amberSecondaryText)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)
        }
    }
}

private struct PermissionRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .padding(.leading, 16)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.amberBody.weight(.semibold))
                    .foregroundColor(.amberText)
                Text(description)
                    .font(.amberCaption)
                    .foregroundColor(.amberSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 16)
            .padding(.trailing, 16)
        }
    }
}
