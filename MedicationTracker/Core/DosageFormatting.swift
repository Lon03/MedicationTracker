//
//  DosageFormatting.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum DosageFormatting {
    static func formName(_ form: DosageForm) -> String {
        switch form {
        case .tablet: L(.formTablet)
        case .capsule: L(.formCapsule)
        case .liquid: L(.formLiquid)
        case .drops: L(.formDrops)
        case .injection: L(.formInjection)
        }
    }

    static func line(for medication: Medication) -> String {
        MedicationDosage.line(for: medication, formName: formName)
    }

    static func occurrenceLine(_ occurrence: DoseOccurrence) -> String {
        line(for: occurrence.medication)
    }
}
