//
//  ReminderPlan.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// How a medication's next reminder should fire.
enum ReminderFire: Hashable, Sendable {
    /// Repeating, at the same time every day.
    case daily
    /// One firing, on this day only, at the medication's usual time. Does not
    /// repeat, so whatever schedules it owes a re-plan afterwards.
    case onDay(DateComponents)
}

enum ReminderPlan {
    /// A repeating daily trigger always fires at the *next* match, so it cannot
    /// skip a day. Moving the time to a moment still ahead today would therefore
    /// remind the user about a dose they have already answered.
    ///
    /// That one case is planned as a dated firing for tomorrow. A re-plan on a
    /// later day returns it to the normal repeating request.
    static func fire(
        at time: TimeOfDay,
        answeredToday: Bool,
        now: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> ReminderFire {
        guard answeredToday, time.date(on: now, calendar: calendar) > now else { return .daily }

        let today = calendar.startOfDay(for: now)
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return .daily }

        return .onDay(calendar.dateComponents([.year, .month, .day], from: tomorrow))
    }
}
