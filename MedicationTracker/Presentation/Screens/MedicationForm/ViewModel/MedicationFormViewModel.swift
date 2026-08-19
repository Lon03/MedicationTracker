//
//  MedicationFormViewModel.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MedicationFormViewModel {
    private(set) var state: MedicationFormViewState

    private let repository: any MedicationRepository
    private let authorizer: any NotificationAuthorizing
    private let status: any ReminderStatusReading
    private let reminders: any ReminderSwitching
    private let coordinator: any MedicationsCoordinatorProtocol
    private let settings: any SystemSettingsOpening
    private let existing: Medication?
    private let now: @Sendable () -> Date
    private let calendar: Calendar
    private let loadTaskSlot = TaskCancellationSlot()

    init(
        medication: Medication?,
        repository: any MedicationRepository,
        authorizer: any NotificationAuthorizing,
        status: any ReminderStatusReading,
        reminders: any ReminderSwitching,
        coordinator: any MedicationsCoordinatorProtocol,
        settings: any SystemSettingsOpening,
        now: @escaping @Sendable () -> Date = Date.init,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.repository = repository
        self.authorizer = authorizer
        self.status = status
        self.reminders = reminders
        self.coordinator = coordinator
        self.settings = settings
        existing = medication
        self.now = now
        self.calendar = calendar

        if let medication {
            state = MedicationFormViewState(
                name: medication.name,
                form: medication.form,
                amount: medication.amount,
                symbolName: medication.symbolName,
                doseTime: medication.doseTime,
                remindersEnabled: medication.remindersEnabled,
                isEditing: true
            )
        } else {
            state = MedicationFormViewState()
        }
    }

    func load() async {
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

    func handle(_ event: MedicationFormViewEvent) {
        switch event {
        case .save:
            Task { await save() }
        case .delete:
            Task { await delete() }
        case .cancel:
            coordinator.finishForm(saved: false)
        case .openSystemSettings:
            settings.openNotificationSettings()
        case .sceneBecameActive:
            Task { await load() }
        }
    }

    var name: String {
        get { state.name }
        set { state.name = newValue }
    }

    var form: DosageForm {
        get { state.form }
        set { state.form = newValue }
    }

    var amount: Double {
        get { state.amount }
        set { state.amount = max(0, newValue) }
    }

    var symbolName: String {
        get { state.symbolName }
        set { state.symbolName = newValue }
    }

    var doseTime: Date {
        get { state.doseTime.date(on: now(), calendar: calendar) }
        set { state.doseTime = TimeOfDay(date: newValue, calendar: calendar) }
    }

    var remindersEnabled: Bool {
        get { state.remindersEnabled }
        set { state.remindersEnabled = newValue }
    }

    func save() async {
        guard state.canSave else { return }
        cancelPendingLoad()
        state.isSubmitting = true
        state.errorMessage = nil
        defer { state.isSubmitting = false }

        let medication = Medication(
            id: existing?.id ?? UUID(),
            name: state.name.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: state.amount,
            form: state.form,
            symbolName: state.symbolName,
            doseTime: state.doseTime,
            remindersEnabled: state.remindersEnabled,
            createdAt: existing?.createdAt ?? now()
        )

        do {
            try await repository.save(medication)
        } catch {
            AppLogger.persistence.error("save failed: \(error)")
            state.errorMessage = L(.errorGeneric)
            return
        }

        if medication.remindersEnabled, state.reminders == .notDetermined {
            let availability = await authorizer.requestAuthorization()
            // Returning from the system permission sheet may have launched a
            // scene-active refresh using the previous authorization value.
            cancelPendingLoad()
            state.reminders = availability
        }
        // Reconcile the full plan so permission and the app-wide switch are
        // enforced consistently for every pending request.
        await reminders.reapply()
        coordinator.finishForm(saved: true)
    }

    func delete() async {
        guard let existing, !state.isSubmitting else { return }
        cancelPendingLoad()
        state.isSubmitting = true
        state.errorMessage = nil
        defer { state.isSubmitting = false }

        do {
            try await repository.delete(id: existing.id)
            await reminders.forget(medicationID: existing.id)
            coordinator.finishForm(saved: true)
        } catch {
            AppLogger.persistence.error("delete failed: \(error)")
            state.errorMessage = L(.errorGeneric)
        }
    }

    private func performLoad() async {
        let reminders = await authorizer.availability()
        guard !Task.isCancelled else { return }

        let warning = await status.warning()
        guard !Task.isCancelled else { return }

        // Applied together so a canceled refresh cannot leave a half-new state.
        state.reminders = reminders
        state.status = warning
    }

    private func cancelPendingLoad() {
        loadTaskSlot.cancel()
    }
}
