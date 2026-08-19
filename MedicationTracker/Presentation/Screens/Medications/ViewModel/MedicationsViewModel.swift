//
//  MedicationsViewModel.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MedicationsViewModel {
    private(set) var state: MedicationsViewState

    private let repository: any MedicationRepository
    private let coordinator: any MedicationsCoordinatorProtocol
    private let loadTaskSlot = TaskCancellationSlot()

    init(
        repository: any MedicationRepository,
        coordinator: any MedicationsCoordinatorProtocol
    ) {
        self.repository = repository
        self.coordinator = coordinator
        state = MedicationsViewState()
    }

    var medicationsRevision: Int { coordinator.medicationsRevision }

    func load() async {
        // Unwrapped, not `self?.performLoad()`: that infers `Task<Void?, Never>`.
        let task = Task { [weak self] in
            guard let self else { return }
            await performLoad()
        }
        loadTaskSlot.replace(with: task)

        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }

    private func performLoad() async {
        do {
            let medications = try await repository.medications()
            guard !Task.isCancelled else { return }
            state.content = medications.isEmpty ? .empty : .loaded(medications)
        } catch {
            guard !Task.isCancelled else { return }
            AppLogger.persistence.error("load medications failed: \(error)")
            state.content = .error(L(.errorGeneric))
        }
    }

    func handle(_ event: MedicationsViewEvent) {
        switch event {
        case .addTapped:
            coordinator.showAdd()
        case let .select(medication):
            coordinator.showDetail(medication)
        }
    }
}
