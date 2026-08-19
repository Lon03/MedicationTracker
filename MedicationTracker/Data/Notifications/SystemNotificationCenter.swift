//
//  SystemNotificationCenter.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import UserNotifications

/// The only place the app talks to `UNUserNotificationCenter`.
struct SystemNotificationCenter: NotificationCenterProtocol {
    private var center: UNUserNotificationCenter { .current() }

    func add(_ reminder: ScheduledReminder) async throws {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        content.badge = NSNumber(value: NotificationBadge.pending)
        content.categoryIdentifier = NotificationCategory.reminder

        var components = DateComponents()
        components.hour = reminder.hour
        components.minute = reminder.minute
        var repeats = true

        if case let .onDay(day) = reminder.fire {
            components.year = day.year
            components.month = day.month
            components.day = day.day
            repeats = false
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        try await center.add(
            UNNotificationRequest(
                identifier: reminder.identifier,
                content: content,
                trigger: trigger
            )
        )
    }

    func removePending(identifiers: [String]) async {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func setBadgeCount(_ count: Int) async {
        try? await center.setBadgeCount(count)
    }

    func removeAllPending() async {
        center.removeAllPendingNotificationRequests()
    }

    func settings() async -> (authorization: UNAuthorizationStatus, alertsEnabled: Bool) {
        let settings = await center.notificationSettings()
        return (settings.authorizationStatus, settings.alertSetting != .disabled)
    }

    func requestAuthorization() async -> Bool {
        await (try? center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }
}
