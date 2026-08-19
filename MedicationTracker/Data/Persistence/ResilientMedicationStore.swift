//
//  ResilientMedicationStore.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// Opens the on-disk store lazily and retries after a failed open. It never
/// accepts writes into a temporary store that would later be discarded.
actor ResilientMedicationStore: MedicationRepository, DoseRepository {
    private let open: @Sendable () -> SwiftDataMedicationStore?
    private var connected: SwiftDataMedicationStore?

    init(open: @escaping @Sendable () -> SwiftDataMedicationStore?) {
        self.open = open
    }

    private func store() throws -> SwiftDataMedicationStore {
        if let connected { return connected }
        guard let opened = open() else {
            throw PersistenceError.loadFailed("The persistent store is not available yet")
        }
        connected = opened
        return opened
    }

    func medications() async throws -> [Medication] {
        try await store().medications()
    }

    func medication(id: Medication.ID) async throws -> Medication? {
        try await store().medication(id: id)
    }

    func save(_ medication: Medication) async throws {
        try await store().save(medication)
    }

    func delete(id: Medication.ID) async throws {
        try await store().delete(id: id)
    }

    func doseRecords(in range: DateInterval) async throws -> [DoseRecord] {
        try await store().doseRecords(in: range)
    }

    func recordDose(_ record: DoseRecord) async throws {
        try await store().recordDose(record)
    }
}
