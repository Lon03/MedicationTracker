//
//  OnboardingPageView.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct OnboardingPageView: View {
    let symbolName: String
    let title: LocalizedStringResource
    let message: LocalizedStringResource

    var body: some View {
        VStack(spacing: AppTheme.Spacing.extraLarge) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.mint)
                    .frame(
                        width: AppTheme.Sizes.onboardingArtwork,
                        height: AppTheme.Sizes.onboardingArtwork
                    )
                Circle()
                    .fill(AppTheme.Colors.onboardingInnerSurface)
                    .frame(
                        width: AppTheme.Sizes.onboardingArtworkInner,
                        height: AppTheme.Sizes.onboardingArtworkInner
                    )
                Image(systemName: symbolName)
                    .font(AppTheme.Typography.onboardingIcon)
                    .foregroundStyle(AppTheme.Colors.accentDeep)
            }
            .accessibilityHidden(true)

            VStack(spacing: AppTheme.Spacing.medium) {
                Text(title)
                    .font(AppTheme.Typography.screenTitle)
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(AppTheme.TextLayout.onboardingLineSpacing)
            }
            .padding(AppTheme.Spacing.large)
            .background(AppTheme.Colors.cardBackground, in: .rect(cornerRadius: AppTheme.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .strokeBorder(
                        AppTheme.Colors.line,
                        lineWidth: AppTheme.Stroke.standard
                    )
            }
        }
        .screenPadding()
    }
}
