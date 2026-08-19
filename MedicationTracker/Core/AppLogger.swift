//
//  AppLogger.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import OSLog

struct AppLog: Sendable {
    private let logger: Logger

    init(category: String) {
        logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "MedicationTracker",
            category: category
        )
    }

    func warning(_ message: @autoclosure () -> String) {
        let resolved = message()
        logger.warning("\(resolved, privacy: .public)")
    }

    func error(_ message: @autoclosure () -> String) {
        let resolved = message()
        logger.error("\(resolved, privacy: .public)")
    }
}

enum AppLogger {
    static let persistence = AppLog(category: "persistence")
    static let notifications = AppLog(category: "notifications")
}
