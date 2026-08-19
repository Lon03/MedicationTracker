//
//  MedicationsCoordinatorProtocol.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

@MainActor
protocol MedicationsCoordinatorProtocol: AnyObject {
    var medicationsRevision: Int { get }

    func showAdd()
    func showDetail(_ medication: Medication)
    func finishForm(saved: Bool)
}
