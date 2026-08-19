//
//  NotificationActionHandling.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// `firedAt` is the notification's delivery time, not the moment the user
/// answered: a 21:00 reminder answered at 00:30 is still the previous day's dose.
/// Idempotent per medication and day; never throws.
protocol NotificationActionHandling: Sendable {
    func recordDose(
        medicationID: Medication.ID,
        outcome: DoseOutcome,
        firedAt: Date
    ) async
}
