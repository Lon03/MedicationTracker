//
//  DayNavigator.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

/// Which day the schedule below belongs to, and the only way to change it.
///
/// Sits above the content rather than inside it, so an empty or failed day is
/// still one tap away from a day that has something on it.
struct DayNavigator: View {
    let title: String
    let canGoForward: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onChooseDay: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            step(symbol: AppTheme.Images.chevronLeft, label: .dayPreviousAction, action: onPrevious)

            Button(action: onChooseDay) {
                HStack(spacing: AppTheme.Spacing.small) {
                    Image(systemName: AppTheme.Images.calendar)
                    Text(title)
                }
                .font(AppTheme.Typography.cardTitle)
                .foregroundStyle(AppTheme.Colors.text)
                .frame(maxWidth: .infinity, minHeight: AppTheme.Sizes.minimumTouchTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(.dayChooseAction))
            .accessibilityValue(title)

            step(symbol: AppTheme.Images.chevron, label: .dayNextAction, action: onNext)
                .disabled(!canGoForward)
        }
        .padding(.horizontal, AppTheme.Spacing.small)
        .cardSurface()
    }

    private func step(
        symbol: String,
        label: LocalizedStringResource,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(AppTheme.Typography.disclosureIndicator)
                .frame(
                    width: AppTheme.Sizes.minimumTouchTarget,
                    height: AppTheme.Sizes.minimumTouchTarget
                )
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}
