//
//  ViewModifiers.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct CardSurface: ViewModifier {
    var tint: Color = AppTheme.Colors.cardBackground

    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Spacing.normal)
            .background(tint, in: .rect(cornerRadius: AppTheme.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .strokeBorder(
                        AppTheme.Colors.line,
                        lineWidth: AppTheme.Stroke.standard
                    )
            }
            .shadow(
                color: AppTheme.Colors.shadow,
                radius: AppTheme.Effects.cardShadowRadius,
                y: AppTheme.Effects.cardShadowY
            )
    }
}

extension View {
    func cardSurface(tint: Color = AppTheme.Colors.cardBackground) -> some View {
        modifier(CardSurface(tint: tint))
    }

    func screenPadding() -> some View {
        padding(.horizontal, AppTheme.Spacing.screenMargin)
    }

    /// Localized navigation title. A literal title would quietly make the
    /// English copy the catalog key. A title that varies at runtime passes
    /// `Text(_:)` to `navigationTitle` directly.
    func screenTitle(_ key: LocalizedStringResource) -> some View {
        navigationTitle(Text(key))
    }
}
