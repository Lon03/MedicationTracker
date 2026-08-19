//
//  SwiftDataMedicationStore.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import SwiftData

@ModelActor
actor SwiftDataMedicationStore {
    private func medicationEntity(id: UUID) throws -> MedicationEntity? {
        var descriptor = FetchDescriptor<MedicationEntity>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}

// MARK: - MedicationRepository

extension SwiftDataMedicationStore: MedicationRepository {
    func medications() async throws -> [Medication] {
        do {
            let descriptor = FetchDescriptor<MedicationEntity>(
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
            return try modelContext.fetch(descriptor).map(\.asDomain)
        } catch {
            throw PersistenceError.loadFailed(String(describing: error))
        }
    }

    func medication(id: Medication.ID) async throws -> Medication? {
        do {
            return try medicationEntity(id: id)?.asDomain
        } catch {
            throw PersistenceError.loadFailed(String(describing: error))
        }
    }

    func save(_ medication: Medication) async throws {
        do {
            if let existing = try medicationEntity(id: medication.id) {
                existing.update(from: medication)
            } else {
                modelContext.insert(MedicationEntity(medication))
            }
            try modelContext.save()
        } catch {
            throw PersistenceError.saveFailed(String(describing: error))
        }
    }

    func delete(id: Medication.ID) async throws {
        do {
            guard let entity = try medicationEntity(id: id) else { return }
            modelContext.delete(entity)
            let medicationID = id
            let doseDescriptor = FetchDescriptor<DoseRecordEntity>(
                predicate: #Predicate { $0.medicationID == medicationID }
            )
            for dose in try modelContext.fetch(doseDescriptor) {
                modelContext.delete(dose)
            }
            try modelContext.save()
        } catch {
            throw PersistenceError.deleteFailed(String(describing: error))
        }
    }
}

// MARK: - DoseRepository

extension SwiftDataMedicationStore: DoseRepository {
    func doseRecords(in range: DateInterval) async throws -> [DoseRecord] {
        do {
            let start = range.start
            let end = range.end
            let descriptor = FetchDescriptor<DoseRecordEntity>(
                predicate: #Predicate { $0.day >= start && $0.day < end }
            )
            return try modelContext.fetch(descriptor).compactMap(\.asDomain)
        } catch {
            throw PersistenceError.loadFailed(String(describing: error))
        }
    }

    func recordDose(_ record: DoseRecord) async throws {
        do {
            if let existing = try existingDose(
                medicationID: record.medicationID,
                on: record.day
            ) {
                existing.update(from: record)
            } else {
                modelContext.insert(DoseRecordEntity(record))
            }
            try modelContext.save()
        } catch {
            throw PersistenceError.saveFailed(String(describing: error))
        }
    }

    private func existingDose(
        medicationID: UUID,
        on day: Date
    ) throws -> DoseRecordEntity? {
        let start = Calendar.current.startOfDay(for: day)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else {
            return nil
        }
        var descriptor = FetchDescriptor<DoseRecordEntity>(
            predicate: #Predicate {
                $0.medicationID == medicationID
                    && $0.day >= start
                    && $0.day < end
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
