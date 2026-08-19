//
//  PersistenceError.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum PersistenceError: Error, Sendable {
    case loadFailed(String)
    case saveFailed(String)
    case deleteFailed(String)
}
