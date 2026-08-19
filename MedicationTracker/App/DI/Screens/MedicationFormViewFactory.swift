//
//  MedicationFormViewFactory.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

extension ScreenFactory: MedicationFormViewFactory {
    func makeMedicationFormView(for medication: Medication?) -> MedicationFormView {
        MedicationFormView(
            viewModel: MedicationFormViewModel(
                medication: medication,
                repository: appFactory.medications,
                authorizer: appFactory.authorizer,
                status: appFactory.reminderStatus,
                reminders: appFactory.reminderSwitch,
                coordinator: appFactory.coordinator.medications,
                settings: appFactory.settingsOpener
            ),
            formName: DosageFormatting.formName
        )
    }
}
