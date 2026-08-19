//
//  NotificationDelegate.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import UserNotifications

/// `@MainActor` on the type, not a hop per callback: a nonisolated `async`
/// implementation of a main-actor requirement may resume off-main, and touching
/// the observable coordinator there crashes SwiftUI.
@MainActor
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let actions: any NotificationActionHandling
    private let onDeepLink: (DeepLink) -> Void

    init(
        actions: any NotificationActionHandling,
        onDeepLink: @escaping (DeepLink) -> Void
    ) {
        self.actions = actions
        self.onDeepLink = onDeepLink
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard let medicationID = NotificationIdentifier.parse(response.notification.request.identifier)
        else { return }

        switch response.actionIdentifier {
        case NotificationCategory.markTakenAction:
            await actions.recordDose(
                medicationID: medicationID,
                outcome: .taken,
                firedAt: response.notification.date
            )
        case NotificationCategory.markMissedAction:
            await actions.recordDose(
                medicationID: medicationID,
                outcome: .missed,
                firedAt: response.notification.date
            )
        case UNNotificationDefaultActionIdentifier:
            onDeepLink(.medication(id: medicationID, day: response.notification.date))
        default:
            break
        }
    }
}
