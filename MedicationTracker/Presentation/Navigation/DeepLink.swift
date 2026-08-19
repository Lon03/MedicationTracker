//
//  DeepLink.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum DeepLink: Hashable, Sendable {
    /// `day` is the day the dose belongs to, not the moment of the tap. A
    /// reminder opened the next morning still has to land on the day it fired
    /// on, or the dose it is asking about is not on screen to answer.
    case medication(id: Medication.ID, day: Date)
}

@MainActor
protocol DeepLinkConsuming: AnyObject {
    /// Observable, so a screen already on display reacts to a link arriving.
    var pendingDeepLink: DeepLink? { get }
    /// Returns the link once and forgets it, so it cannot be acted on twice.
    func consumeDeepLink() -> DeepLink?
}
