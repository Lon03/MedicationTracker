//
//  MedicationsCoordinatorView.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct MedicationsCoordinatorView: View {
    @Bindable private var coordinator: MedicationsCoordinator
    private let factory: any MedicationsViewFactory & MedicationFormViewFactory

    init(
        coordinator: MedicationsCoordinator,
        factory: any MedicationsViewFactory & MedicationFormViewFactory
    ) {
        self.coordinator = coordinator
        self.factory = factory
    }

    var body: some View {
        NavigationStack {
            factory.makeMedicationsView()
        }
        // `item:` rather than a bool, so a swipe-down clears the coordinator's
        // state and the two can never disagree about what is on screen.
        .sheet(item: $coordinator.presentedSheet) { sheet in
            switch sheet {
            case .addMedication:
                factory.makeMedicationFormView(for: nil)
            case let .editMedication(medication):
                factory.makeMedicationFormView(for: medication)
            }
        }
    }
}
