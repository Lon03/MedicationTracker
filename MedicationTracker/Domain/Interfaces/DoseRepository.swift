//
//  DoseRepository.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// `recordDose` upserts on (medication, day): changing an answer replaces the
/// record. Reads throw so a broken store cannot masquerade as an empty day.
protocol DoseRepository: Sendable {
    func doseRecords(in range: DateInterval) async throws -> [DoseRecord]
    func recordDose(_ record: DoseRecord) async throws
}
