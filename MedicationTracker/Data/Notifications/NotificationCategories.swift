//
//  NotificationCategories.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import UserNotifications

/// The actions attached to a delivered reminder.
///
/// Re-registered on every launch, which is what lets the action titles be
/// ordinary localized strings — unlike a notification body, which is frozen
/// when the reminder is scheduled.
enum NotificationCategories {
    static func register() {
        let markTaken = UNNotificationAction(
            identifier: NotificationCategory.markTakenAction,
            title: L(.reminderActionTaken),
            options: [],
            icon: UNNotificationActionIcon(systemImageName: NotificationActionIcon.markTaken)
        )
        let markMissed = UNNotificationAction(
            identifier: NotificationCategory.markMissedAction,
            title: L(.reminderActionMissed),
            options: [],
            icon: UNNotificationActionIcon(systemImageName: NotificationActionIcon.markMissed)
        )
        let category = UNNotificationCategory(
            identifier: NotificationCategory.reminder,
            actions: [markTaken, markMissed],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
