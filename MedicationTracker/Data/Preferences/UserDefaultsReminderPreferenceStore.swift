//
//  UserDefaultsReminderPreferenceStore.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// The key is the negative on purpose: `bool(forKey:)` is `false` when unset,
/// so storing "disabled" makes a fresh install come up with reminders on.
struct UserDefaultsReminderPreferenceStore: ReminderPreferenceStoring {
    private static let key = "reminders.disabled"

    var remindersEnabled: Bool {
        !UserDefaults.standard.bool(forKey: Self.key)
    }

    func setRemindersEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(!enabled, forKey: Self.key)
    }
}
