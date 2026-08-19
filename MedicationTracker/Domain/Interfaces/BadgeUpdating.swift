//
//  BadgeUpdating.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

protocol BadgeUpdating: Sendable {
    /// Sets a binary attention badge while at least one dose is unanswered.
    func refresh() async

    func clear() async
}
