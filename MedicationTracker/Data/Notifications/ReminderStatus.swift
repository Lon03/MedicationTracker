//
//  ReminderStatus.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

struct ReminderStatus: ReminderStatusReading {
    private let preferences: any ReminderPreferenceStoring
    private let authorizer: any NotificationAuthorizing

    init(preferences: any ReminderPreferenceStoring, authorizer: any NotificationAuthorizing) {
        self.preferences = preferences
        self.authorizer = authorizer
    }

    func warning() async -> ReminderWarning? {
        await ReminderWarning.resolve(
            remindersEnabled: preferences.remindersEnabled,
            availability: authorizer.availability()
        )
    }
}
