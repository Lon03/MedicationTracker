//
//  PersistenceContainer.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import SwiftData

enum PersistenceContainer {
    static let schema = Schema([MedicationEntity.self, DoseRecordEntity.self])

    /// Returns `nil` instead of trapping; the resilient store retries later.
    static func container() -> ModelContainer? {
        do {
            return try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema))
        } catch {
            AppLogger.persistence.error("ModelContainer failed: \(error)")
            return nil
        }
    }
}
