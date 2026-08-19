//
//  OnboardingViewFactory.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

extension ScreenFactory: OnboardingViewFactory {
    func makeOnboardingView() -> OnboardingView {
        OnboardingView(
            viewModel: OnboardingViewModel(
                authorizer: appFactory.authorizer,
                store: appFactory.onboardingStore,
                router: appFactory.coordinator
            )
        )
    }
}
