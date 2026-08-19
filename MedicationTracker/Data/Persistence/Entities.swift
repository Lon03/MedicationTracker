//
//  Entities.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import SwiftData

@Model
final class MedicationEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Double
    var formRaw: String
    var symbolName: String
    var doseHour: Int
    var doseMinute: Int
    var remindersEnabled: Bool
    var createdAt: Date

    init(
        id: UUID,
        name: String,
        amount: Double,
        formRaw: String,
        symbolName: String,
        doseHour: Int,
        doseMinute: Int,
        remindersEnabled: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.formRaw = formRaw
        self.symbolName = symbolName
        self.doseHour = doseHour
        self.doseMinute = doseMinute
        self.remindersEnabled = remindersEnabled
        self.createdAt = createdAt
    }
}

@Model
final class DoseRecordEntity {
    @Attribute(.unique) var id: UUID
    var medicationID: UUID
    var day: Date
    /// When the user answered, which a `.missed` record has as much as a
    /// `.taken` one.
    var recordedAt: Date
    var outcomeRaw: String
    /// Optional so the attribute can be added to an existing store without a
    /// migration; read back as "unknown" rather than as midnight.
    var scheduledHour: Int?
    var scheduledMinute: Int?

    init(
        id: UUID,
        medicationID: UUID,
        day: Date,
        recordedAt: Date,
        outcomeRaw: String,
        scheduledHour: Int?,
        scheduledMinute: Int?
    ) {
        self.id = id
        self.medicationID = medicationID
        self.day = day
        self.recordedAt = recordedAt
        self.outcomeRaw = outcomeRaw
        self.scheduledHour = scheduledHour
        self.scheduledMinute = scheduledMinute
    }
}
