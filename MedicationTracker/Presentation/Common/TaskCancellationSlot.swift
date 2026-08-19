//
//  TaskCancellationSlot.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// Owns one replaceable UI task without exposing its handle to Observation.
/// Replacing the task cooperatively cancels the previous operation first.
@MainActor
final class TaskCancellationSlot {
    private var task: Task<Void, Never>?

    func replace(with task: Task<Void, Never>) {
        cancel()
        self.task = task
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
