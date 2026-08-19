//
//  ReminderPreferenceStoring.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

protocol ReminderPreferenceStoring: Sendable {
    var remindersEnabled: Bool { get }
    func setRemindersEnabled(_ enabled: Bool)
}
