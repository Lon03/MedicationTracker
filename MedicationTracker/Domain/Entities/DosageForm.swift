//
//  DosageForm.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum DosageForm: String, Codable, CaseIterable, Identifiable, Sendable {
    case tablet, capsule, liquid, drops, injection

    var id: String { rawValue }
}
