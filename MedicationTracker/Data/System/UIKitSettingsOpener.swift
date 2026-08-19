//
//  UIKitSettingsOpener.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import UIKit

/// The only place the app opens a URL. `openNotificationSettingsURLString`
/// lands on this app's notification page rather than the top of Settings.
struct UIKitSettingsOpener: SystemSettingsOpening {
    func openNotificationSettings() {
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
