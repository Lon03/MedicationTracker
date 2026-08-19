//
//  ReminderStatusReading.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// What is currently stopping reminders from arriving, if anything.
///
/// Whether the current screen has reminder-enabled medication is intentionally
/// left to the caller.
protocol ReminderStatusReading: Sendable {
    func warning() async -> ReminderWarning?
}
