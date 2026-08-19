//
//  MedicationFormViewState.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum MedicationFormViewEvent {
    case save
    case delete
    case cancel
    case openSystemSettings
    case sceneBecameActive
}

struct MedicationFormViewState {
    var name: String = ""
    var form: DosageForm = .tablet
    var amount: Double = 1
    var symbolName: String = AppTheme.Images.medicationDefault
    var doseTime: TimeOfDay = .init(hour: 9, minute: 0)
    var remindersEnabled = false
    var reminders: ReminderAvailability = .authorized
    var status: ReminderWarning?
    var isEditing = false
    var isSubmitting = false
    var errorMessage: String?

    var canSave: Bool {
        !isSubmitting
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && amount > 0
    }

    /// The same warning the Schedule tab shows, gated on this medication wanting
    /// one.
    var warning: ReminderWarning? {
        remindersEnabled ? status : nil
    }
}
