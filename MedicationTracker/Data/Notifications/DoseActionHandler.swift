//
//  DoseActionHandler.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

struct DoseActionHandler: NotificationActionHandling {
    private let medications: any MedicationRepository
    private let doses: any DoseRepository
    private let calendar: Calendar
    private let badge: any BadgeUpdating
    private let reminders: any ReminderSwitching
    private let now: @Sendable () -> Date

    init(
        medications: any MedicationRepository,
        doses: any DoseRepository,
        badge: any BadgeUpdating,
        reminders: any ReminderSwitching,
        calendar: Calendar = .autoupdatingCurrent,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.medications = medications
        self.doses = doses
        self.calendar = calendar
        self.badge = badge
        self.reminders = reminders
        self.now = now
    }

    func recordDose(
        medicationID: Medication.ID,
        outcome: DoseOutcome,
        firedAt: Date
    ) async {
        do {
            guard let medication = try await medications.medication(id: medicationID) else { return }
            try await doses.recordDose(
                DoseRecord(
                    medicationID: medicationID,
                    day: firedAt,
                    outcome: outcome,
                    recordedAt: now(),
                    scheduledTime: medication.doseTime,
                    calendar: calendar
                )
            )
            await badge.refresh()
            // Answering is the other moment a dated one-shot can collapse back
            // into the durable repeating request, and it needs no app launch.
            await reminders.reapply()
        } catch {
            AppLogger.notifications.error("record dose failed: \(error)")
        }
    }
}
