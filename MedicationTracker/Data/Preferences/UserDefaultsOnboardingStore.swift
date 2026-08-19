//
//  UserDefaultsOnboardingStore.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

struct UserDefaultsOnboardingStore: OnboardingStateStoring {
    private static let key = "onboarding.hasCompleted"

    var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: Self.key)
    }

    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: Self.key)
    }
}
