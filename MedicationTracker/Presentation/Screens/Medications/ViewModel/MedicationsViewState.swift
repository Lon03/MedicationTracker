//
//  MedicationsViewState.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

enum MedicationsViewEvent {
    case addTapped
    case select(Medication)
}

struct MedicationsViewState {
    enum Content: Equatable {
        case loading
        case empty
        case loaded([Medication])
        case error(String)
    }

    var content: Content = .loading
}
