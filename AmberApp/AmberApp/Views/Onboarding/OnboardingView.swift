// ONBOARD-01: Onboarding flow — one question per screen, conversational tone.

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()
    @Environment(\.modelContext) private var context
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.amberBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                ProgressDotsView(total: OnboardingStep.allCases.count - 1, current: vm.step.rawValue)
                    .padding(.top, 20)
                    .padding(.horizontal, 32)

                // Step content
                Group {
                    switch vm.step {
                    case .name:        NameStepView(name: $vm.displayName)
                    case .birthday:    BirthdayStepView(birthday: $vm.birthday, location: $vm.birthdayLocation, sign: vm.horoscopeSign)
                    case .almaMater:   TextFieldStepView(title: "Where did you go to school?", subtitle: "University, college, or wherever you grew up learning.", placeholder: "USC, MIT, …", value: $vm.almaMater, isOptional: true)
                    case .hometown:    TextFieldStepView(title: "Where did you grow up?", subtitle: "Your hometown — even a small town counts.", placeholder: "Pasadena, CA", value: $vm.hometown, isOptional: true)
                    case .privacyTier: PrivacyTierStepView(selected: $vm.selectedTier)
                    case .permissions: PermissionsStepView(vm: vm)
                    case .done:        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(vm.step)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // CTA
                if vm.step != .permissions && vm.step != .done {
                    Button {
                        if vm.step == .hometown {
                            Task {
                                await vm.saveProfile(context: context)
                                vm.advance()
                            }
                        } else {
                            vm.advance()
                        }
                    } label: {
                        Text(vm.step == .privacyTier ? "Continue" : "Next")
                            .font(.amberBody.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(vm.canAdvance ? Color.amberGold : Color.gray.opacity(0.4))
                            .cornerRadius(16)
                    }
                    .disabled(!vm.canAdvance)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Name Step

private struct NameStepView: View {
    @Binding var name: String
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            Text("What should Amber call you?")
                .font(.amberTitle)
                .foregroundColor(.amberText)
            Text("Just your first name is fine.")
                .font(.amberBody)
                .foregroundColor(.amberSecondaryText)
            TextField("Your name", text: $name)
                .font(.amberTitle2)
                .foregroundColor(.amberText)
                .focused($focused)
                .onAppear { focused = true }
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Birthday Step

private struct BirthdayStepView: View {
    @Binding var birthday: Date
    @Binding var location: String
    let sign: String

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            Text("When were you born?")
                .font(.amberTitle)
                .foregroundColor(.amberText)
            Text("Amber derives your \(sign) automatically.")
                .font(.amberBody)
                .foregroundColor(.amberSecondaryText)
            DatePicker("Birthday", selection: $birthday, displayedComponents: [.date])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            if !sign.isEmpty {
                Text(sign)
                    .font(.amberTitle2)
                    .foregroundColor(.amberGold)
                    .frame(maxWidth: .infinity)
            }
            TextField("City of birth (optional)", text: $location)
                .font(.amberBody)
                .foregroundColor(.amberText)
                .opacity(0.7)
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Generic text field step

private struct TextFieldStepView: View {
    let title: String
    let subtitle: String
    let placeholder: String
    @Binding var value: String
    var isOptional: Bool = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            Text(title)
                .font(.amberTitle)
                .foregroundColor(.amberText)
            Text(subtitle + (isOptional ? " (optional)" : ""))
                .font(.amberBody)
                .foregroundColor(.amberSecondaryText)
            TextField(placeholder, text: $value)
                .font(.amberTitle2)
                .foregroundColor(.amberText)
                .focused($focused)
                .onAppear { focused = true }
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Progress dots

private struct ProgressDotsView: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i <= current ? Color.amberGold : Color.gray.opacity(0.3))
                    .frame(width: i == current ? 24 : 8, height: 8)
                    .animation(.spring(), value: current)
            }
        }
    }
}
