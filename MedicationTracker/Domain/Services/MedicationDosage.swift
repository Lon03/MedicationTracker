//
//  MedicationDosage.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum MedicationDosage {
    static func line(
        for medication: Medication,
        formName: (DosageForm) -> String
    ) -> String {
        let amount = medication.amount.formatted(.number.precision(.fractionLength(0 ... 2)))
        return "\(amount) \(formName(medication.form))"
    }
}
