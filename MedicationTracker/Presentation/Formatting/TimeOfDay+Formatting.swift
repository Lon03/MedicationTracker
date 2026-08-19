//
//  TimeOfDay+Formatting.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

extension TimeOfDay {
    /// The user's locale and 12/24-hour convention. Any day works — only the
    /// hour and minute are rendered.
    var clockText: String {
        date(on: .now).formatted(date: .omitted, time: .shortened)
    }
}
