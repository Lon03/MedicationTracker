//
//  MedicationsFactoryProtocol.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

@MainActor
protocol MedicationsViewFactory {
    func makeMedicationsView() -> MedicationsView
}

@MainActor
protocol MedicationsFlowFactory {
    func makeMedicationsFlow() -> MedicationsCoordinatorView
}
