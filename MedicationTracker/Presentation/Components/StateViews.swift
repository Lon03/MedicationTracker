//
//  StateViews.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

/// A centred symbol, title and message. The action is optional because a past
/// day with nothing on it has nothing to offer.
struct MessageStateView<Message: View>: View {
    let symbolName: String
    let symbolColor: Color
    let symbolBackground: Color
    let title: LocalizedStringResource
    let actionTitle: LocalizedStringResource?
    let action: (() -> Void)?
    @ViewBuilder let message: () -> Message

    var body: some View {
        VStack(spacing: AppTheme.Spacing.normal) {
            Spacer()
            Image(systemName: symbolName)
                .font(AppTheme.Typography.emptyStateIcon)
                .foregroundStyle(symbolColor)
                .frame(
                    width: AppTheme.Sizes.emptyStateSymbol,
                    height: AppTheme.Sizes.emptyStateSymbol
                )
                .background(symbolBackground, in: .circle)
                .accessibilityHidden(true)

            Text(title)
                .font(AppTheme.Typography.sectionTitle)
                .foregroundStyle(AppTheme.Colors.text)
                .multilineTextAlignment(.center)

            message()
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(AppTheme.TextLayout.bodyLineSpacing)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(.primary)
                .padding(.top, AppTheme.Spacing.small)
            }
            Spacer()
        }
        .screenPadding()
        .padding(.vertical, AppTheme.Spacing.large)
    }
}

struct EmptyStateView: View {
    let symbolName: String
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let actionTitle: LocalizedStringResource?
    let action: (() -> Void)?

    init(
        symbolName: String,
        title: LocalizedStringResource,
        message: LocalizedStringResource,
        actionTitle: LocalizedStringResource? = nil,
        action: (() -> Void)? = nil
    ) {
        self.symbolName = symbolName
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        MessageStateView(
            symbolName: symbolName,
            symbolColor: AppTheme.Colors.accentDeep,
            symbolBackground: AppTheme.Colors.mint,
            title: title,
            actionTitle: actionTitle,
            action: action
        ) {
            Text(message)
        }
    }
}

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        MessageStateView(
            symbolName: AppTheme.Images.warning,
            symbolColor: AppTheme.Colors.warning,
            symbolBackground: AppTheme.Colors.warningSurface,
            title: .errorGeneric,
            actionTitle: .commonRetry,
            action: retry
        ) {
            Text(message)
        }
    }
}
