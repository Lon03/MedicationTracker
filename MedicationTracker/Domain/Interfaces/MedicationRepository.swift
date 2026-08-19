//
//  MedicationRepository.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

protocol MedicationRepository: Sendable {
    func medications() async throws -> [Medication]
    func medication(id: Medication.ID) async throws -> Medication?
    func save(_ medication: Medication) async throws
    func delete(id: Medication.ID) async throws
}
