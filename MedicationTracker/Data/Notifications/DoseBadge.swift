//
//  DoseBadge.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

actor DoseBadge: BadgeUpdating {
    private let medications: any MedicationRepository
    private let doses: any DoseRepository
    private let center: any NotificationCenterProtocol
    private let calendar: Calendar
    private let now: @Sendable () -> Date
    private var operationTask: Task<Void, Never>?

    init(
        medications: any MedicationRepository,
        doses: any DoseRepository,
        center: any NotificationCenterProtocol,
        calendar: Calendar = .autoupdatingCurrent,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.medications = medications
        self.doses = doses
        self.center = center
        self.calendar = calendar
        self.now = now
    }

    func refresh() async {
        let previous = operationTask
        previous?.cancel()

        let task = Task { [weak self] in
            await previous?.value
            guard !Task.isCancelled, let self else { return }
            await self.performRefresh()
        }
        operationTask = task

        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }

    private func performRefresh() async {
        do {
            let count = try await pendingToday()
            guard !Task.isCancelled else { return }
            await center.setBadgeCount(count)
        } catch {
            guard !Task.isCancelled else { return }
            // A failed read must not overwrite a valid badge with a fabricated 0.
            AppLogger.persistence.error("refreshing badge failed: \(error)")
        }
    }

    func clear() async {
        let previous = operationTask
        previous?.cancel()
        let center = center
        let task = Task {
            await previous?.value
            await center.setBadgeCount(0)
        }
        operationTask = task
        await task.value
    }

    /// Uses `DaySchedule`, the same function the Schedule tab renders from. The icon
    /// is intentionally binary because scheduled numeric badges become stale as
    /// soon as a dose is answered or the calendar day changes.
    private func pendingToday() async throws -> Int {
        let today = calendar.startOfDay(for: now())
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return 0 }

        let loadedMedications = try await medications.medications()
        guard !Task.isCancelled else { throw CancellationError() }

        let records = try await doses.doseRecords(in: DateInterval(start: today, end: tomorrow))
        guard !Task.isCancelled else { throw CancellationError() }

        let data = ScheduleData(medications: loadedMedications, doses: records)
        let hasPendingDose = DaySchedule.occurrences(data, on: today, calendar: calendar)
            .contains { $0.status == .pending }
        return hasPendingDose ? NotificationBadge.pending : 0
    }
}
