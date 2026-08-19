//
//  UserNotificationsAuthorizer.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import UserNotifications

struct UserNotificationsAuthorizer: NotificationAuthorizing {
    private let center: any NotificationCenterProtocol

    init(center: any NotificationCenterProtocol) {
        self.center = center
    }

    func availability() async -> ReminderAvailability {
        let (status, alertsEnabled) = await center.settings()
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        default:
            return alertsEnabled ? .authorized : .alertsDisabled
        }
    }

    @discardableResult
    func requestAuthorization() async -> ReminderAvailability {
        let current = await availability()
        guard current == .notDetermined else {
            return current
        }
        _ = await center.requestAuthorization()
        return await availability()
    }
}
