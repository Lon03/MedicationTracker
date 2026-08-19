//
//  ReminderWarning.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum ReminderWarning: Hashable, Sendable {
    case turnedOff
    case denied
    case alertsDisabled

    /// The user's own switch outranks the system's — otherwise the warning
    /// sends them to iOS Settings to undo something they did in this app.
    static func resolve(
        remindersEnabled: Bool,
        availability: ReminderAvailability
    ) -> ReminderWarning? {
        guard remindersEnabled else { return .turnedOff }

        switch availability {
        case .denied: return .denied
        case .alertsDisabled: return .alertsDisabled
        case .authorized, .notDetermined: return nil
        }
    }

    var isRepairedInApp: Bool {
        self == .turnedOff
    }
}
