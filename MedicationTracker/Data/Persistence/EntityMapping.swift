//
//  EntityMapping.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

extension MedicationEntity {
    var asDomain: Medication {
        Medication(
            id: id,
            name: name,
            amount: amount,
            form: DosageForm(rawValue: formRaw) ?? .tablet,
            symbolName: symbolName,
            doseTime: TimeOfDay(hour: doseHour, minute: doseMinute),
            remindersEnabled: remindersEnabled,
            createdAt: createdAt
        )
    }

    convenience init(_ medication: Medication) {
        self.init(
            id: medication.id,
            name: medication.name,
            amount: medication.amount,
            formRaw: medication.form.rawValue,
            symbolName: medication.symbolName,
            doseHour: medication.doseTime.hour,
            doseMinute: medication.doseTime.minute,
            remindersEnabled: medication.remindersEnabled,
            createdAt: medication.createdAt
        )
    }

    func update(from medication: Medication) {
        name = medication.name
        amount = medication.amount
        formRaw = medication.form.rawValue
        symbolName = medication.symbolName
        doseHour = medication.doseTime.hour
        doseMinute = medication.doseTime.minute
        remindersEnabled = medication.remindersEnabled
    }
}

extension DoseRecordEntity {
    /// `nil` for an outcome this build cannot read: the day stays unresolved.
    /// `?? .taken` would claim a dose was taken that never was.
    /// Both halves or neither — a half-written time is not a time.
    private var scheduledTime: TimeOfDay? {
        guard let scheduledHour, let scheduledMinute else { return nil }
        return TimeOfDay(hour: scheduledHour, minute: scheduledMinute)
    }

    var asDomain: DoseRecord? {
        guard let outcome = DoseOutcome(rawValue: outcomeRaw) else { return nil }

        return DoseRecord(
            id: id,
            medicationID: medicationID,
            day: day,
            outcome: outcome,
            recordedAt: recordedAt,
            scheduledTime: scheduledTime
        )
    }

    convenience init(_ record: DoseRecord) {
        self.init(
            id: record.id,
            medicationID: record.medicationID,
            day: record.day,
            recordedAt: record.recordedAt,
            outcomeRaw: record.outcome.rawValue,
            scheduledHour: record.scheduledTime?.hour,
            scheduledMinute: record.scheduledTime?.minute
        )
    }

    func update(from record: DoseRecord) {
        day = record.day
        recordedAt = record.recordedAt
        outcomeRaw = record.outcome.rawValue
        scheduledHour = record.scheduledTime?.hour
        scheduledMinute = record.scheduledTime?.minute
    }
}
