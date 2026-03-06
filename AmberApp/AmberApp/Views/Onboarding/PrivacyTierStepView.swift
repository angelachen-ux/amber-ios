// DESIGN-03 / PRIVACY-01: Privacy tier selection screen

import SwiftUI

struct PrivacyTierStepView: View {
    @Binding var selected: PrivacyTier

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("How private do you want to be?")
                .font(.amberTitle)
                .foregroundColor(.amberText)
                .padding(.horizontal, 32)
                .padding(.bottom, 8)

            Text("You can change this any time in Settings.")
                .font(.amberBody)
                .foregroundColor(.amberSecondaryText)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(PrivacyTier.allCases, id: \.self) { tier in
                        PrivacyTierCard(tier: tier, isSelected: selected == tier) {
                            withAnimation(.spring(response: 0.3)) { selected = tier }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
    }
}

struct PrivacyTierCard: View {
    let tier: PrivacyTier
    let isSelected: Bool
    let onSelect: () -> Void

    private var icon: String {
        switch tier {
        case .localOnly:  return "lock.shield.fill"
        case .selective:  return "slider.horizontal.3"
        case .fullSocial: return "person.3.fill"
        }
    }

    private var accentColor: Color {
        switch tier {
        case .localOnly:  return .blue
        case .selective:  return .amberGold
        case .fullSocial: return .green
        }
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(accentColor)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tier.displayName)
                            .font(.amberBody.weight(.semibold))
                            .foregroundColor(.amberText)
                        Text(tier.tagline)
                            .font(.amberCaption)
                            .foregroundColor(.amberSecondaryText)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(accentColor)
                            .font(.title3)
                    }
                }

                // Feature list
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(tier.features, id: \.self) { feature in
                        Label(feature, systemImage: "checkmark")
                            .font(.amberCaption)
                            .foregroundColor(.amberSecondaryText)
                    }
                }
                .padding(.leading, 48)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.amberCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
