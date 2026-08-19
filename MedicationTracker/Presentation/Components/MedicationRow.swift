//
//  MedicationRow.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct MedicationRow: View {
    let medication: Medication
    let dosageLine: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            MedicationSymbolTile(symbolName: medication.symbolName)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.tiny) {
                Text(medication.name)
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.text)

                HStack(spacing: AppTheme.Spacing.small) {
                    Text(dosageLine)

                    Label {
                        Text(medication.doseTime.clockText)
                            .monospacedDigit()
                    } icon: {
                        Image(
                            systemName: medication.remindersEnabled
                                ? AppTheme.Images.reminder
                                : AppTheme.Images.time
                        )
                    }
                }
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}
