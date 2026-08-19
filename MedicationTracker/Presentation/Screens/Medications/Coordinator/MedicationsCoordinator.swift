//
//  MedicationsCoordinator.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MedicationsCoordinator: MedicationsCoordinatorProtocol {
    /// `Identifiable` by itself, so `.sheet(item:)` swaps the sheet when the
    /// medication being edited changes.
    enum Sheet: Hashable, Sendable, Identifiable {
        case addMedication
        case editMedication(Medication)

        var id: Self { self }
    }

    var presentedSheet: Sheet?

    /// Revision of the persisted medication collection. A successful save or
    /// delete advances it so `.task(id:)` reloads the list; canceling does not.
    private(set) var medicationsRevision = 0

    func showAdd() {
        presentedSheet = .addMedication
    }

    func showDetail(_ medication: Medication) {
        presentedSheet = .editMedication(medication)
    }

    func finishForm(saved: Bool) {
        if saved { medicationsRevision += 1 }
        presentedSheet = nil
    }
}
