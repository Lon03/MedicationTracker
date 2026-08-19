//
//  OnboardingViewModel.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    private(set) var state: OnboardingViewState

    private let authorizer: any NotificationAuthorizing
    private let store: any OnboardingStateStoring
    private let router: any OnboardingCoordinatorProtocol

    init(
        authorizer: any NotificationAuthorizing,
        store: any OnboardingStateStoring,
        router: any OnboardingCoordinatorProtocol
    ) {
        self.authorizer = authorizer
        self.store = store
        self.router = router
        state = OnboardingViewState(page: .track)
    }

    var page: OnboardingPage {
        get { state.page }
        set { state.page = newValue }
    }

    func handle(_ event: OnboardingViewEvent) {
        switch event {
        case .next:
            state.page = state.page.next ?? state.page
        case .enableReminders:
            guard !state.isRequestingPermission else { return }
            state.isRequestingPermission = true
            Task {
                await authorizer.requestAuthorization()
                finish()
            }
        case .notNow:
            // Leaves authorization undetermined, so the first-save request still
            // gets its chance later.
            finish()
        }
    }

    /// Completion is recorded only on finishing the last page — quitting
    /// mid-flow must show the onboarding again.
    private func finish() {
        store.markOnboardingCompleted()
        router.finishOnboarding()
    }
}
