//
//  SettingsViewModel.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private(set) var state: SettingsViewState

    private let reminders: any ReminderSwitching
    private let status: any ReminderStatusReading
    private let settings: any SystemSettingsOpening
    private let loadTaskSlot = TaskCancellationSlot()

    init(
        reminders: any ReminderSwitching,
        status: any ReminderStatusReading,
        settings: any SystemSettingsOpening
    ) {
        self.reminders = reminders
        self.status = status
        self.settings = settings
        state = SettingsViewState(remindersEnabled: reminders.isEnabled)
    }

    func load() async {
        // The apply operation owns the authoritative state and refreshes the
        // warning when it finishes, so a concurrent read would be redundant.
        guard !state.isApplying else { return }
        // Unwrapped, not `self?.performLoad()`: that infers `Task<Void?, Never>`.
        let task = Task { [weak self] in
            guard let self else { return }
            await performLoad()
        }
        loadTaskSlot.replace(with: task)

        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }

    func handle(_ event: SettingsViewEvent) {
        switch event {
        case let .setReminders(enabled):
            if enabled {
                apply(true)
            } else {
                state.isConfirmingDisable = true
            }
        case .confirmDisable:
            state.isConfirmingDisable = false
            apply(false)
        case .cancelDisable:
            // The state never moved, so the switch snaps back on its own.
            state.isConfirmingDisable = false
        case .openSystemSettings:
            settings.openNotificationSettings()
        case .sceneBecameActive:
            Task { await load() }
        }
    }
}

// MARK: - Applying

extension SettingsViewModel {
    private func apply(_ enabled: Bool) {
        guard !state.isApplying else { return }
        cancelPendingLoad()
        state.isApplying = true
        state.remindersEnabled = enabled
        Task {
            await reminders.setEnabled(enabled)
            let warning = await status.warning()
            // A scene-active refresh may have started while the external
            // notification operation was suspended. This result is newer.
            cancelPendingLoad()
            state.warning = warning
            state.isApplying = false
        }
    }

    private func performLoad() async {
        let enabled = reminders.isEnabled
        let warning = await status.warning()
        guard !Task.isCancelled else { return }

        state.remindersEnabled = enabled
        state.warning = warning
    }

    private func cancelPendingLoad() {
        loadTaskSlot.cancel()
    }
}
