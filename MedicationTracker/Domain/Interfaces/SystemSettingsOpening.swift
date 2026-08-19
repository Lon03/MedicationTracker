//
//  SystemSettingsOpening.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// A seam, so the view models that send the user to iOS Settings stay free of
/// UIKit and can be asserted against.
@MainActor
protocol SystemSettingsOpening: Sendable {
    func openNotificationSettings()
}
