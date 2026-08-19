//
//  ReminderError.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum ReminderError: Error, Sendable {
    case schedulingFailed(String)
}
