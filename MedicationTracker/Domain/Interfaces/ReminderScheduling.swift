//
//  ReminderScheduling.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

protocol ReminderScheduling: Sendable {
    /// Adds nothing when the app-wide switch is off, whatever the medication
    /// says — the check lives here rather than at the call sites so a new caller
    /// cannot forget it.
    func reschedule(
        for medication: Medication,
        fire: ReminderFire,
        availability: ReminderAvailability
    ) async throws
    func cancelAll(for medicationID: Medication.ID) async
    /// Withdraws every reminder the app owns. Used when reminders are switched
    /// off app-wide, where cancelling one medication at a time would leave any
    /// request whose medication has since been deleted still pending.
    func cancelAll() async
}
