//
//  AppActivation.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// Everything that has to be reconciled each time the app comes to the front.
///
/// A named type rather than a closure in a lifecycle callback because it is
/// real behaviour with an order to it, and because the reason it exists is easy
/// to forget: iOS lets the user change notification permission, and answer a
/// dose from a banner, entirely outside the app. Nothing tells us. Coming back
/// to the front is the one moment we can look.
@MainActor
struct AppActivation {
    private let badge: any BadgeUpdating
    private let reminders: any ReminderSwitching

    init(badge: any BadgeUpdating, reminders: any ReminderSwitching) {
        self.badge = badge
        self.reminders = reminders
    }

    func activate() async {
        // Badge first: it is what the user is looking at, and it must not wait
        // on a re-plan that visits every medication.
        await badge.clear()
        // Cancel-then-add per medication, so repeating this replaces rather
        // than duplicates.
        await reminders.reapply()
    }
}
