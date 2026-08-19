//
//  ScheduleViewModel.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ScheduleViewModel {
    private(set) var state: ScheduleViewState

    private let medications: any MedicationRepository
    private let doses: any DoseRepository
    private let status: any ReminderStatusReading
    private let coordinator: any ScheduleCoordinatorProtocol
    private let deepLinks: any DeepLinkConsuming
    private let settings: any SystemSettingsOpening
    private let reminders: any ReminderSwitching
    private let now: @Sendable () -> Date
    private let calendar: Calendar
    private var data: ScheduleData
    /// Only the newest refresh may update the screen. Keeping the task handle
    /// also lets cooperative repositories stop work that is no longer useful.
    private let loadTaskSlot = TaskCancellationSlot()

    init(
        medications: any MedicationRepository,
        doses: any DoseRepository,
        status: any ReminderStatusReading,
        coordinator: any ScheduleCoordinatorProtocol,
        deepLinks: any DeepLinkConsuming,
        settings: any SystemSettingsOpening,
        reminders: any ReminderSwitching,
        now: @escaping @Sendable () -> Date = Date.init,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.medications = medications
        self.doses = doses
        self.status = status
        self.coordinator = coordinator
        self.deepLinks = deepLinks
        self.settings = settings
        self.reminders = reminders
        self.now = now
        self.calendar = calendar
        state = ScheduleViewState()
        data = ScheduleData()
        show(day: calendar.startOfDay(for: now()))
    }

    func load() async {
        // Unwrapped, not `self?.performLoad()`: that infers `Task<Void?, Never>`.
        let task = Task { [weak self] in
            guard let self else { return }
            await performLoad()
        }
        loadTaskSlot.replace(with: task)

        // SwiftUI cancels its `.task` when the view disappears. An unstructured
        // task does not inherit that later cancellation, so forward it.
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }

    private func performLoad() async {
        let day = state.selectedDay
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else {
            state.content = .error(L(.errorGeneric))
            return
        }

        let warning = await status.warning()
        guard !Task.isCancelled else { return }

        let loaded: [Medication]
        let records: [DoseRecord]
        do {
            loaded = try await medications.medications()
            guard !Task.isCancelled else { return }

            records = loaded.isEmpty
                ? []
                : try await doses.doseRecords(in: DateInterval(start: day, end: nextDay))
            guard !Task.isCancelled else { return }
        } catch {
            guard !Task.isCancelled else { return }
            AppLogger.persistence.error("loading the day failed: \(error)")
            state.content = .error(L(.errorGeneric))
            return
        }

        // No more awaits below: once cancellation has been checked, this state
        // update is atomic on the main actor.
        state.status = warning
        data = ScheduleData(medications: loaded, doses: records)

        if loaded.isEmpty {
            // Adding medication now cannot change a historical day. Past dates
            // therefore get the read-only historical placeholder, while today
            // keeps the useful add-medication action.
            state.content = state.isShowingToday ? .empty : .noDoses
        } else {
            recompute()
        }

        // Last, because a link for another day starts a fresh load that cancels
        // this task — nothing may write state after it.
        consumeDeepLink()
    }

    func handle(_ event: ScheduleViewEvent) {
        switch event {
        case let .recordDose(medicationID, outcome):
            Task { await recordDose(medicationID: medicationID, outcome: outcome) }
        case .addMedication:
            coordinator.addMedication()
        case .openSystemSettings:
            settings.openNotificationSettings()
        case let .selectDay(day):
            Task { await selectDay(day) }
        case let .stepDay(days):
            guard let stepped = calendar.date(byAdding: .day, value: days, to: state.selectedDay)
            else { return }
            Task { await selectDay(stepped) }
        case .dayChanged, .sceneBecameActive:
            // The calendar day can roll over while the app is backgrounded, so
            // both paths re-anchor first. Following midnight is only right for
            // someone watching today; a reader of last Tuesday stays there.
            show(day: state.isShowingToday ? calendar.startOfDay(for: now()) : state.selectedDay)
            Task { await load() }
        case .deepLinkChanged:
            Task { await load() }
        case .focusHandled:
            state.focusedMedicationID = nil
        case .recordFailureDismissed:
            state.didFailToRecord = false
        }
    }

    var pendingDeepLink: DeepLink? { deepLinks.pendingDeepLink }

    /// The picker writes through this rather than into `state`, so every day
    /// change goes down the same path.
    var selectedDay: Date {
        get { state.selectedDay }
        set { handle(.selectDay(newValue)) }
    }

    // MARK: - Day selection

    private var today: Date { calendar.startOfDay(for: now()) }

    /// Moves the schedule to another day.
    func selectDay(_ day: Date) async {
        guard show(day: day) else { return }
        state.content = .loading
        await load()
    }

    /// Returns whether the day actually moved, so a repeated tap on the same
    /// date does not throw the schedule away and load it again.
    @discardableResult
    private func show(day: Date) -> Bool {
        let currentDay = today
        let clamped = min(calendar.startOfDay(for: day), currentDay)

        state.latestSelectableDay = currentDay
        let moved = clamped != state.selectedDay || state.dayTitle.isEmpty
        state.selectedDay = clamped
        state.isShowingToday = clamped == currentDay
        state.dayTitle = title(for: clamped, today: currentDay)
        return moved
    }

    private func title(for day: Date, today: Date) -> String {
        if day == today { return L(.todayLabel) }
        if day == calendar.date(byAdding: .day, value: -1, to: today) { return L(.dayYesterday) }
        return day.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    // MARK: - Deep links

    private func consumeDeepLink() {
        guard case let .medication(id, day)? = deepLinks.consumeDeepLink() else { return }
        guard data.medications.contains(where: { $0.id == id }) else {
            state.focusedMedicationID = nil
            return
        }
        state.focusedMedicationID = id
        // A reminder tapped the next morning is still about the day it fired on.
        Task { await selectDay(day) }
    }

    private func cancelPendingLoad() {
        loadTaskSlot.cancel()
    }

    private func recompute() {
        let occurrences = DaySchedule.occurrences(
            data,
            on: state.selectedDay,
            calendar: calendar
        )
        state.content = occurrences.isEmpty ? .noDoses : .loaded(occurrences)
    }

    /// Past doses are always actionable. A dose scheduled later today remains
    /// read-only until its exact scheduled time.
    func canRecord(_ occurrence: DoseOccurrence, at date: Date? = nil) -> Bool {
        occurrence.time.date(on: state.selectedDay, calendar: calendar) <= (date ?? now())
    }

    func recordDose(
        medicationID: Medication.ID,
        outcome: DoseOutcome
    ) async {
        guard let medication = data.medications.first(where: { $0.id == medicationID })
        else { return }

        let scheduledTime = data.doses.first {
            $0.medicationID == medicationID
                && calendar.isDate($0.day, inSameDayAs: state.selectedDay)
        }?.scheduledTime ?? medication.doseTime
        guard scheduledTime.date(on: state.selectedDay, calendar: calendar) <= now() else {
            return
        }

        guard state.recordingMedicationIDs.insert(medicationID).inserted else { return }
        // Any refresh already reading the pre-write store is now obsolete.
        cancelPendingLoad()
        defer { state.recordingMedicationIDs.remove(medicationID) }

        let day = state.selectedDay
        let record = DoseRecord(
            medicationID: medicationID,
            day: day,
            outcome: outcome,
            recordedAt: now(),
            scheduledTime: scheduledTime,
            calendar: calendar
        )

        do {
            try await doses.recordDose(record)

            // A refresh may have started while the write was suspended. Patch
            // the cache only if the user is still on the day just written; a
            // refresh for another day is valid and must be allowed to finish.
            if calendar.isDate(state.selectedDay, inSameDayAs: day) {
                cancelPendingLoad()
                data.doses.removeAll {
                    $0.medicationID == medicationID
                        && calendar.isDate($0.day, inSameDayAs: day)
                }
                data.doses.append(record)
                recompute()
            }

            // Only today's answer changes what is still worth reminding
            // about. Not awaited: the row must stop spinning once it is stored.
            if day == today {
                Task { await reminders.reapply() }
            }
        } catch {
            AppLogger.persistence.error("record dose failed: \(error)")
            state.didFailToRecord = true
        }
    }
}
