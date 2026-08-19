//
//  AppCoordinator.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppCoordinator {
    enum Route: Hashable { case onboarding, main }
    enum Tab: Hashable { case schedule, medications, settings }

    private(set) var route: Route
    var selectedTab: Tab

    let medications: MedicationsCoordinator

    private(set) var pendingDeepLink: DeepLink?

    init(onboardingStore: any OnboardingStateStoring) {
        // Read synchronously: doing this in `.task` would render the list for a
        // frame before the onboarding appears.
        route = onboardingStore.hasCompletedOnboarding ? .main : .onboarding
        selectedTab = .schedule
        medications = MedicationsCoordinator()
        pendingDeepLink = nil
    }

    func handle(_ link: DeepLink) {
        pendingDeepLink = link
        selectedTab = .schedule
    }
}

extension AppCoordinator: OnboardingCoordinatorProtocol {
    func finishOnboarding() {
        route = .main
    }
}

extension AppCoordinator: DeepLinkConsuming {
    func consumeDeepLink() -> DeepLink? {
        defer { pendingDeepLink = nil }
        return pendingDeepLink
    }
}

extension AppCoordinator: ScheduleCoordinatorProtocol {
    func addMedication() {
        selectedTab = .medications
        medications.showAdd()
    }
}
