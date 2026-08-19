//
//  ReminderSwitching.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

protocol ReminderSwitching: Sendable {
    var isEnabled: Bool { get }
    func setEnabled(_ enabled: Bool) async

    /// Re-plans every medication against the current switch **and** the current
    /// iOS permission. Scheduling is refused while permission is missing, and
    /// nothing else retries — so without this, granting permission in Settings
    /// after refusing it once leaves the user with no reminders and no warning.
    func reapply() async

    /// Drops a deleted medication's reminder and reconciles what is left.
    func forget(medicationID: Medication.ID) async
}
