//
//  NotificationIdentifier.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum NotificationIdentifier {
    private static let prefix = "medication."

    static func make(medicationID: Medication.ID) -> String {
        prefix + medicationID.uuidString
    }

    static func parse(_ identifier: String) -> Medication.ID? {
        guard identifier.hasPrefix(prefix) else { return nil }
        return UUID(uuidString: String(identifier.dropFirst(prefix.count)))
    }
}

enum NotificationStringKey {
    static let body = "reminderBody"
    static let bodyWithDosage = "reminderBodyWithDosage"
}

/// The icon badge is an attention flag, not a count: a number frozen at
/// scheduling time is wrong the moment a dose is answered.
enum NotificationBadge {
    static let pending = 1
}

/// The action glyphs, owned here rather than taken from the design system:
/// these are drawn by iOS in the notification shade, not by the app.
enum NotificationActionIcon {
    static let markTaken = "checkmark.circle"
    static let markMissed = "xmark.circle"
}

enum NotificationCategory {
    static let reminder = "medicationReminder"
    static let markTakenAction = "markTaken"
    static let markMissedAction = "markMissed"
}
