//
//  ButtonStyles.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    /// A custom background does not dim itself when disabled, so the style has
    /// to read the environment.
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.cardTitle)
            .foregroundStyle(isEnabled ? AppTheme.Colors.cardBackground : AppTheme.Colors.disabledText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.normal)
            .background(
                isEnabled ? AppTheme.Colors.text : AppTheme.Colors.disabledSurface,
                in: .rect(cornerRadius: AppTheme.Radius.compactCard)
            )
            .opacity(
                configuration.isPressed
                    ? AppTheme.Effects.primaryPressedOpacity
                    : AppTheme.Effects.restingOpacity
            )
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.Colors.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.medium)
            .background(AppTheme.Colors.cardBackground, in: .rect(cornerRadius: AppTheme.Radius.compactCard))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.compactCard)
                    .strokeBorder(
                        AppTheme.Colors.line,
                        lineWidth: AppTheme.Stroke.standard
                    )
            }
            .opacity(
                configuration.isPressed
                    ? AppTheme.Effects.secondaryPressedOpacity
                    : AppTheme.Effects.restingOpacity
            )
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: Self { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: Self { SecondaryButtonStyle() }
}
