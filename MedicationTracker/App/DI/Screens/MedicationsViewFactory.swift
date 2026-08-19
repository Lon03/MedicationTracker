//
//  MedicationsViewFactory.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

extension ScreenFactory: MedicationsViewFactory {
    func makeMedicationsView() -> MedicationsView {
        MedicationsView(
            viewModel: MedicationsViewModel(
                repository: appFactory.medications,
                coordinator: appFactory.coordinator.medications
            ),
            dosageLine: DosageFormatting.line(for:)
        )
    }
}

extension ScreenFactory: MedicationsFlowFactory {
    func makeMedicationsFlow() -> MedicationsCoordinatorView {
        MedicationsCoordinatorView(
            coordinator: appFactory.coordinator.medications,
            factory: self
        )
    }
}
