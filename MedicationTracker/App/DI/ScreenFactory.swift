//
//  ScreenFactory.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// Only what the root presents. A screen it does not present does not belong
/// here — the medications tab builds its own list and form.
typealias RootCoordinatorFactory = MedicationsFlowFactory &
    OnboardingViewFactory & ScheduleViewFactory & SettingsViewFactory

/// Builds every screen from the composition root. One method per screen, each
/// in that screen's own folder, behind that screen's own protocol.
@MainActor
final class ScreenFactory {
    let appFactory: AppFactory

    init(appFactory: AppFactory) {
        self.appFactory = appFactory
    }
}
