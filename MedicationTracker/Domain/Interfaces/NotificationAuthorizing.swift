//
//  NotificationAuthorizing.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// `alertsDisabled` means authorization exists, but visible alerts are disabled.
enum ReminderAvailability: Hashable, Sendable {
    case notDetermined
    case denied
    case authorized
    case alertsDisabled

    /// Existing authorization is enough to keep requests scheduled; the UI
    /// separately warns when visible alerts are disabled.
    var allowsScheduling: Bool {
        self == .authorized || self == .alertsDisabled
    }
}

protocol NotificationAuthorizing: Sendable {
    func availability() async -> ReminderAvailability

    /// Never call once the status is `.denied` — iOS returns silently and the
    /// user sees nothing. Route them to Settings instead.
    @discardableResult
    func requestAuthorization() async -> ReminderAvailability
}
