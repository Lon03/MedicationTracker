//
//  AppDelegate.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI
import UserNotifications

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate {
    let factory = AppFactory()

    private var notificationDelegate: NotificationDelegate?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let coordinator = factory.coordinator
        let delegate = NotificationDelegate(actions: factory.notificationActions) { link in
            coordinator.handle(link)
        }
        // Held so it outlives this call — `UNUserNotificationCenter` does not
        // retain its delegate.
        notificationDelegate = delegate
        UNUserNotificationCenter.current().delegate = delegate

        NotificationCategories.register()
        return true
    }
}
