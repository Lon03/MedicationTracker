//
//  DaySchedule.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

struct DoseOccurrence: Identifiable, Hashable, Sendable {
    enum Status: Hashable, Sendable {
        case taken(at: Date)
        case missed
        case pending

        var isTaken: Bool {
            if case .taken = self { return true }
            return false
        }
    }

    let medication: Medication
    let status: Status
    /// The medication's current time for an unanswered day, and the time the
    /// answer was given against for one the user already resolved.
    let time: TimeOfDay

    var id: Medication.ID { medication.id }
}

struct ScheduleData: Equatable, Sendable {
    var medications: [Medication] = []
    var doses: [DoseRecord] = []
}

enum DaySchedule {
    static func occurrences(
        _ data: ScheduleData,
        on day: Date,
        calendar: Calendar = .current
    ) -> [DoseOccurrence] {
        let day = calendar.startOfDay(for: day)
        let records = data.doses.reduce(into: [Medication.ID: DoseRecord]()) { result, record in
            guard calendar.isDate(record.day, inSameDayAs: day) else { return }
            result[record.medicationID] = record
        }

        return data.medications
            .filter { calendar.startOfDay(for: $0.createdAt) <= day }
            .map { medication in
                let record = records[medication.id]
                let status: DoseOccurrence.Status = switch record?.outcome {
                case .taken:
                    .taken(at: record?.recordedAt ?? day)
                case .missed:
                    .missed
                case nil:
                    .pending
                }
                return DoseOccurrence(
                    medication: medication,
                    status: status,
                    time: record?.scheduledTime ?? medication.doseTime
                )
            }
            .sorted { lhs, rhs in
                (lhs.time, lhs.medication.name) < (rhs.time, rhs.medication.name)
            }
    }
}
