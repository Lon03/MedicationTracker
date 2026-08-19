//
//  ScheduleViewFactory.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

extension ScreenFactory: ScheduleViewFactory {
    func makeScheduleView() -> ScheduleView {
        ScheduleView(
            viewModel: ScheduleViewModel(
                medications: appFactory.medications,
                doses: appFactory.doses,
                status: appFactory.reminderStatus,
                coordinator: appFactory.coordinator,
                deepLinks: appFactory.coordinator,
                settings: appFactory.settingsOpener,
                reminders: appFactory.reminderSwitch
            ),
            dosageLine: DosageFormatting.occurrenceLine
        )
    }
}
