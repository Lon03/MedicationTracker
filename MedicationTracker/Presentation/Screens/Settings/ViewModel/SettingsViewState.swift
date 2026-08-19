//
//  SettingsViewState.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum SettingsViewEvent {
    case setReminders(Bool)
    case confirmDisable
    case cancelDisable
    case openSystemSettings
    case sceneBecameActive
}

struct SettingsViewState {
    var remindersEnabled = true
    /// Always shown here: this is the screen the switch lives on.
    var warning: ReminderWarning?
    var isConfirmingDisable = false
    var isApplying = false
}
