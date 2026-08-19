//
//  ReminderSwitch.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

struct ReminderSwitch: ReminderSwitching {
    private let store: any ReminderPreferenceStoring
    private let medications: any MedicationRepository
    private let doses: any DoseRepository
    private let scheduler: any ReminderScheduling
    private let authorizer: any NotificationAuthorizing
    private let calendar: Calendar
    private let now: @Sendable () -> Date
    private let queue: ReminderOperationQueue

    init(
        store: any ReminderPreferenceStoring,
        medications: any MedicationRepository,
        doses: any DoseRepository,
        scheduler: any ReminderScheduling,
        authorizer: any NotificationAuthorizing,
        calendar: Calendar = .autoupdatingCurrent,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.store = store
        self.medications = medications
        self.doses = doses
        self.scheduler = scheduler
        self.authorizer = authorizer
        self.calendar = calendar
        self.now = now
        queue = ReminderOperationQueue()
    }

    var isEnabled: Bool { store.remindersEnabled }

    /// The flag is written **first**, so that even if the work below is
    /// interrupted the scheduler — which reads the same flag on every save —
    /// already refuses to add anything.
    func setEnabled(_ enabled: Bool) async {
        await queue.run {
            store.setRemindersEnabled(enabled)

            guard enabled else {
                await scheduler.cancelAll()
                return
            }
            await performReapply()
        }
    }

    /// Cancels the deleted reminder, then reconciles the remaining plan.
    func forget(medicationID: Medication.ID) async {
        await queue.run {
            await scheduler.cancelAll(for: medicationID)
            await performReapply()
        }
    }

    func reapply() async {
        await queue.run { await performReapply() }
    }

    private func performReapply() async {
        guard store.remindersEnabled else { return }

        let ordered: [Medication]
        do {
            ordered = try await medications.medications()
                .sorted { ($0.doseTime, $0.name) < ($1.doseTime, $1.name) }
        } catch {
            // Keep the existing notification plan intact. Treating a failed read
            // as an empty store would either leave it stale or erase valid work.
            AppLogger.persistence.error("loading reminder plan failed: \(error)")
            return
        }
        let availability = await authorizer.availability()
        let instant = now()
        let answered = await answeredToday(at: instant)

        for medication in ordered {
            do {
                try await scheduler.reschedule(
                    for: medication,
                    fire: ReminderPlan.fire(
                        at: medication.doseTime,
                        answeredToday: answered.contains(medication.id),
                        now: instant,
                        calendar: calendar
                    ),
                    availability: availability
                )
            } catch {
                AppLogger.notifications.error("rescheduling failed for one medication: \(error)")
            }
        }
    }

    /// One read for the whole day rather than one per medication. A failed read
    /// means "nothing known to be answered", which only ever schedules more
    /// reminders — never fewer.
    private func answeredToday(at instant: Date) async -> Set<Medication.ID> {
        let today = calendar.startOfDay(for: instant)
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return [] }

        do {
            let records = try await doses.doseRecords(in: DateInterval(start: today, end: tomorrow))
            return Set(records.map(\.medicationID))
        } catch {
            AppLogger.persistence.error("reading today's answers for the reminder plan failed: \(error)")
            return []
        }
    }
}

/// Chains operations explicitly. Actor isolation alone would still allow an
/// older re-plan to resume after a newer delete while awaiting notification
/// centre calls; the task chain keeps each whole operation atomic in order.
private actor ReminderOperationQueue {
    private var tail: Task<Void, Never>?

    func run(_ operation: @escaping @Sendable () async -> Void) async {
        let previous = tail
        let task = Task {
            await previous?.value
            await operation()
        }
        tail = task
        await task.value
    }
}
