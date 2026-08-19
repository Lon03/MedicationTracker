//
//  SettingsViewFactory.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

extension ScreenFactory: SettingsViewFactory {
    func makeSettingsView() -> SettingsView {
        SettingsView(
            viewModel: SettingsViewModel(
                reminders: appFactory.reminderSwitch,
                status: appFactory.reminderStatus,
                settings: appFactory.settingsOpener
            )
        )
    }
}
