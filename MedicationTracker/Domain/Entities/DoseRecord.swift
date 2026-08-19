//
//  DoseRecord.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum DoseOutcome: String, Codable, Hashable, Sendable {
    case taken
    case missed
}

struct DoseRecord: Identifiable, Hashable, Sendable {
    let id: UUID
    let medicationID: Medication.ID
    let day: Date
    let outcome: DoseOutcome
    let recordedAt: Date
    /// The dose time this answer was given against. Frozen here so editing the
    /// medication's time later cannot relabel a day the user already answered.
    /// `nil` when the store has no value for it.
    let scheduledTime: TimeOfDay?

    init(
        id: UUID = UUID(),
        medicationID: Medication.ID,
        day: Date,
        outcome: DoseOutcome,
        recordedAt: Date,
        scheduledTime: TimeOfDay?,
        calendar: Calendar = .current
    ) {
        self.id = id
        self.medicationID = medicationID
        self.day = calendar.startOfDay(for: day)
        self.outcome = outcome
        self.recordedAt = recordedAt
        self.scheduledTime = scheduledTime
    }
}
