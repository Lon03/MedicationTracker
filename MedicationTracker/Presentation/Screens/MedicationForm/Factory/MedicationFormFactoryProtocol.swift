//
//  MedicationFormFactoryProtocol.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

@MainActor
protocol MedicationFormViewFactory {
    func makeMedicationFormView(for medication: Medication?) -> MedicationFormView
}
