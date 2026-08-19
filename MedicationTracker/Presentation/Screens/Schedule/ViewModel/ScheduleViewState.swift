//
//  ScheduleViewState.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum ScheduleViewEvent {
    case recordDose(medicationID: Medication.ID, outcome: DoseOutcome)
    case addMedication
    case openSystemSettings
    case selectDay(Date)
    case stepDay(days: Int)
    case dayChanged
    case sceneBecameActive
    case deepLinkChanged
    case focusHandled
    case recordFailureDismissed
}

struct ScheduleViewState {
    enum Content: Equatable {
        case loading
        /// Nothing has been added to the app at all.
        case empty
        /// Medication exists, but none of it was being tracked on this day.
        case noDoses
        case loaded([DoseOccurrence])
        case error(String)
    }

    var content: Content = .loading
    var status: ReminderWarning?
    var focusedMedicationID: Medication.ID?
    var recordingMedicationIDs: Set<Medication.ID> = []
    /// One row failing to save is not a reason to take the day off screen.
    var didFailToRecord = false

    /// The day on screen, always the start of it. The day picker cannot go past
    /// `latestSelectableDay`: a dose in the future has not happened yet, so
    /// there is nothing truthful to record against it.
    var selectedDay = Date.now
    var latestSelectableDay = Date.now
    var dayTitle = ""
    var isShowingToday = true

    /// Permission is app-wide, so a denial remains useful before the first
    /// medication is added. Historical days stay focused on recorded doses.
    var warning: ReminderWarning? {
        isShowingToday ? status : nil
    }
}
