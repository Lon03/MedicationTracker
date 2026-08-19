//
//  OnboardingViewState.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum OnboardingPage: CaseIterable, Identifiable, Hashable, Sendable {
    case track
    case reminders
    case permission

    var id: Self { self }

    var symbolName: String {
        switch self {
        case .track: AppTheme.Images.onboardingTrack
        case .reminders: AppTheme.Images.onboardingReminders
        case .permission: AppTheme.Images.onboardingPermission
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .track: .onboardingTrackTitle
        case .reminders: .onboardingRemindersTitle
        case .permission: .onboardingPermissionTitle
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .track: .onboardingTrackBody
        case .reminders: .onboardingRemindersBody
        case .permission: .onboardingPermissionBody
        }
    }

    var next: OnboardingPage? {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self), index + 1 < all.count else { return nil }
        return all[index + 1]
    }
}

enum OnboardingViewEvent {
    case next
    case enableReminders
    case notNow
}

struct OnboardingViewState {
    var page: OnboardingPage
    var isRequestingPermission = false

    var isLastPage: Bool { page.next == nil }
}
