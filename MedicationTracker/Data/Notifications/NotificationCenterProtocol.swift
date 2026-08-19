//
//  NotificationCenterProtocol.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import UserNotifications

struct ScheduledReminder: Hashable, Sendable {
    let identifier: String
    let title: String
    let body: String
    let hour: Int
    let minute: Int
    let fire: ReminderFire
}

protocol NotificationCenterProtocol: Sendable {
    func add(_ reminder: ScheduledReminder) async throws
    func removePending(identifiers: [String]) async
    func removeAllPending() async
    func setBadgeCount(_ count: Int) async
    func settings() async -> (authorization: UNAuthorizationStatus, alertsEnabled: Bool)
    func requestAuthorization() async -> Bool
}
