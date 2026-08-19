//
//  MedicationTrackerApp.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

@main
struct MedicationTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    private var activation: AppActivation { appDelegate.factory.activation }

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(
                coordinator: appDelegate.factory.coordinator,
                factory: ScreenFactory(appFactory: appDelegate.factory)
            )
            .preferredColorScheme(.light)
        }
        // Not `applicationDidBecomeActive(_:)`: this target declares a scene
        // manifest, and UIKit does not call that delegate method for scene-based
        // apps. The scene phase is the signal that does arrive.
        //
        // `initial: true` so a launch that comes up already `.active` is not
        // missed.
        .onChange(of: scenePhase, initial: true) { _, phase in
            guard phase == .active else { return }
            Task { await activation.activate() }
        }
    }
}
