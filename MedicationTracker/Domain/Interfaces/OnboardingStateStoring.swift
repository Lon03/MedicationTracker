//
//  OnboardingStateStoring.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

protocol OnboardingStateStoring: Sendable {
    var hasCompletedOnboarding: Bool { get }
    func markOnboardingCompleted()
}
