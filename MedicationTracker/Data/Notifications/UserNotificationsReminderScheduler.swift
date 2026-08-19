//
//  UserNotificationsReminderScheduler.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import UserNotifications

struct UserNotificationsReminderScheduler: ReminderScheduling {
    private let center: any NotificationCenterProtocol
    private let dosageLine: @Sendable (Medication) -> String
    private let preferences: any ReminderPreferenceStoring

    init(
        center: any NotificationCenterProtocol,
        preferences: any ReminderPreferenceStoring,
        dosageLine: @escaping @Sendable (Medication) -> String
    ) {
        self.center = center
        self.preferences = preferences
        self.dosageLine = dosageLine
    }

    func reschedule(
        for medication: Medication,
        fire: ReminderFire,
        availability: ReminderAvailability
    ) async throws {
        await cancelAll(for: medication.id)
        guard preferences.remindersEnabled,
              medication.remindersEnabled,
              availability.allowsScheduling
        else { return }

        do {
            try await center.add(Self.reminder(for: medication, fire: fire, dosageLine: dosageLine))
        } catch {
            throw ReminderError.schedulingFailed(String(describing: error))
        }
    }

    func cancelAll(for medicationID: Medication.ID) async {
        await center.removePending(
            identifiers: [NotificationIdentifier.make(medicationID: medicationID)]
        )
    }

    func cancelAll() async {
        await center.removeAllPending()
    }

    static func reminder(
        for medication: Medication,
        fire: ReminderFire,
        dosageLine: (Medication) -> String
    ) -> ScheduledReminder {
        ScheduledReminder(
            identifier: NotificationIdentifier.make(medicationID: medication.id),
            title: medication.name,
            body: body(for: medication, dosageLine: dosageLine),
            hour: medication.doseTime.hour,
            minute: medication.doseTime.minute,
            fire: fire
        )
    }

    private static func body(
        for medication: Medication,
        dosageLine: (Medication) -> String
    ) -> String {
        let dosage = dosageLine(medication)
        guard !dosage.isEmpty else {
            return NSString.localizedUserNotificationString(
                forKey: NotificationStringKey.body,
                arguments: nil
            )
        }
        return NSString.localizedUserNotificationString(
            forKey: NotificationStringKey.bodyWithDosage,
            arguments: [dosage]
        )
    }
}
