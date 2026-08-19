//
//  DoseCard.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct DoseCard: View {
    private struct Correction {
        let title: LocalizedStringResource
        let symbol: String
        let action: () -> Void
    }

    let occurrence: DoseOccurrence
    let dosageLine: String
    let isWorking: Bool
    let allowsRecording: Bool
    let onMarkTaken: () -> Void
    let onMarkMissed: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.normal) {
            HStack(spacing: AppTheme.Spacing.medium) {
                MedicationSymbolTile(symbolName: occurrence.medication.symbolName)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.tiny) {
                    Text(occurrence.medication.name)
                        .font(AppTheme.Typography.cardTitle)
                        .foregroundStyle(AppTheme.Colors.text)
                    Text(dosageLine)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                Spacer(minLength: AppTheme.Spacing.small)
                scheduleState
            }

            if showsActionRow {
                Divider()
                actionRow
            }
        }
        .padding(AppTheme.Spacing.normal)
        .background(
            cardBackground,
            in: .rect(cornerRadius: AppTheme.Radius.compactCard)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.compactCard)
                .strokeBorder(
                    borderColor,
                    lineWidth: AppTheme.Stroke.standard
                )
        }
    }

    /// A pending dose is read-only until its scheduled time; an answered one
    /// always offers its correction menu.
    private var showsActionRow: Bool {
        if case .pending = occurrence.status { return allowsRecording }
        return true
    }

    private var scheduleState: some View {
        HStack(spacing: AppTheme.Spacing.tiny) {
            if occurrence.medication.remindersEnabled {
                Image(systemName: AppTheme.Images.reminder)
            }
            Text(occurrence.time.clockText)
                .monospacedDigit()
        }
        .font(AppTheme.Typography.caption.weight(.semibold))
        .foregroundStyle(AppTheme.Colors.text)
        .padding(.horizontal, AppTheme.Spacing.medium)
        .padding(.vertical, AppTheme.Spacing.small)
        .background(AppTheme.Colors.elevatedBackground, in: .capsule)
    }

    @ViewBuilder
    private var actionRow: some View {
        switch occurrence.status {
        case .taken:
            resolvedRow(
                title: .statusTaken,
                color: AppTheme.Colors.doseTaken,
                symbol: AppTheme.Images.doseTaken,
                correction: Correction(
                    title: .doseMarkMissed,
                    symbol: AppTheme.Images.markMissed,
                    action: onMarkMissed
                )
            )
        case .missed:
            resolvedRow(
                title: .statusMissed,
                color: AppTheme.Colors.doseMissed,
                symbol: AppTheme.Images.doseMissed,
                correction: Correction(
                    title: .doseMarkTaken,
                    symbol: AppTheme.Images.markTaken,
                    action: onMarkTaken
                )
            )
        case .pending:
            HStack(spacing: AppTheme.Spacing.small) {
                Button(action: onMarkTaken) {
                    Label {
                        Text(.doseMarkTaken)
                    } icon: {
                        Image(systemName: AppTheme.Images.markTaken)
                    }
                    .font(AppTheme.Typography.body.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.accentDeep)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: AppTheme.Sizes.doseActionHeight)
                    .background(
                        AppTheme.Colors.mint,
                        in: .rect(cornerRadius: AppTheme.Radius.compactCard)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isWorking)

                Button(action: onMarkMissed) {
                    Label {
                        Text(.doseMarkMissed)
                    } icon: {
                        Image(systemName: AppTheme.Images.markMissed)
                    }
                    .font(AppTheme.Typography.body.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.doseMissed)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: AppTheme.Sizes.doseActionHeight)
                    .background(
                        AppTheme.Colors.doseMissedActionSurface,
                        in: .rect(cornerRadius: AppTheme.Radius.compactCard)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: AppTheme.Radius.compactCard)
                            .strokeBorder(
                                AppTheme.Colors.doseMissedBorder,
                                lineWidth: AppTheme.Stroke.standard
                            )
                    }
                }
                .buttonStyle(.plain)
                .disabled(isWorking)
            }
        }
    }

    private func resolvedRow(
        title: LocalizedStringResource,
        color: Color,
        symbol: String,
        correction: Correction
    ) -> some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: symbol)
            }
            .font(AppTheme.Typography.cardTitle)
            .foregroundStyle(color)

            Spacer()

            if allowsRecording {
                Menu {
                    Button(action: correction.action) {
                        Label {
                            Text(correction.title)
                        } icon: {
                            Image(systemName: correction.symbol)
                        }
                    }
                } label: {
                    Image(systemName: AppTheme.Images.more)
                        .font(AppTheme.Typography.menuIcon)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(
                            width: AppTheme.Sizes.minimumTouchTarget,
                            height: AppTheme.Sizes.minimumTouchTarget
                        )
                        .background(AppTheme.Colors.elevatedBackground, in: .circle)
                }
                .accessibilityLabel(Text(.doseActions))
                .disabled(isWorking)
            }
        }
    }

    private var cardBackground: Color {
        switch occurrence.status {
        case .taken:
            AppTheme.Colors.doseTakenCard
        case .missed:
            AppTheme.Colors.doseMissedCard
        case .pending:
            AppTheme.Colors.cardBackground
        }
    }

    private var borderColor: Color {
        switch occurrence.status {
        case .taken:
            AppTheme.Colors.doseTakenBorder
        case .missed:
            AppTheme.Colors.doseMissedBorder
        case .pending:
            AppTheme.Colors.line
        }
    }
}

struct MedicationSymbolTile: View {
    let symbolName: String

    var body: some View {
        Image(systemName: symbolName)
            .font(AppTheme.Typography.medicationSymbol)
            .foregroundStyle(AppTheme.Colors.accentDeep)
            .frame(width: AppTheme.Sizes.symbolTile, height: AppTheme.Sizes.symbolTile)
            .background(
                AppTheme.Colors.mint,
                in: .rect(cornerRadius: AppTheme.Radius.symbol)
            )
            .accessibilityHidden(true)
    }
}
