//
//  Medication.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

struct Medication: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var amount: Double
    var form: DosageForm
    /// An opaque identifier the domain stores and never interprets. Which
    /// symbols exist, and which is the default, is the picker's business.
    var symbolName: String
    var doseTime: TimeOfDay
    var remindersEnabled: Bool
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double = 1,
        form: DosageForm = .tablet,
        symbolName: String,
        doseTime: TimeOfDay = TimeOfDay(hour: 9, minute: 0),
        remindersEnabled: Bool = false,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.amount = max(0, amount)
        self.form = form
        self.symbolName = symbolName
        self.doseTime = doseTime
        self.remindersEnabled = remindersEnabled
        self.createdAt = createdAt
    }
}
