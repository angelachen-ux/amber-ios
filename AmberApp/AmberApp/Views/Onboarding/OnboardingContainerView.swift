//
//  OnboardingContainerView.swift
//  AmberApp
//
//  Created on 2026-03-04.
//

import SwiftUI

struct OnboardingContainerView: View {
    @StateObject var viewModel = OnboardingViewModel()
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.amberBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: back button + progress dots
                HStack {
                    if viewModel.currentStep != .welcome && viewModel.currentStep != .complete {
                        Button(action: { viewModel.previousStep() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, height: 44)
                        }
                    } else {
                        Spacer().frame(width: 44)
                    }

                    Spacer()

                    // Progress dots
                    HStack(spacing: 6) {
                        ForEach(OnboardingStep.allCases, id: \.self) { step in
                            Circle()
                                .fill(step == viewModel.currentStep
                                      ? Color.amberBlue
                                      : step.rawValue < viewModel.currentStep.rawValue
                                        ? Color.amberBlue.opacity(0.5)
                                        : Color.white.opacity(0.2))
                                .frame(width: step == viewModel.currentStep ? 10 : 7,
                                       height: step == viewModel.currentStep ? 10 : 7)
                                .animation(.spring(response: 0.3), value: viewModel.currentStep)
                        }
                    }

                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Step content
                Group {
                    switch viewModel.currentStep {
                    case .welcome:
                        WelcomeStepView(viewModel: viewModel)
                    case .basics:
                        BasicsStepView(viewModel: viewModel)
                    case .birthday:
                        BirthdayStepView(viewModel: viewModel)
                    case .location:
                        LocationStepView(viewModel: viewModel)
                    case .education:
                        EducationStepView(viewModel: viewModel)
                    case .permissions:
                        PermissionsStepView(viewModel: viewModel)
                    case .privacyTier:
                        PrivacyTierStepView(viewModel: viewModel)
                    case .complete:
                        OnboardingCompleteView(viewModel: viewModel, onComplete: onComplete)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.currentStep)
            }
        }
        .preferredColorScheme(.dark)
    }
}
