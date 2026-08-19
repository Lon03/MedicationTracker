//
//  ReminderWarningBanner.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct ReminderWarningBanner: View {
    let warning: ReminderWarning
    let onOpenSettings: (() -> Void)?

    init(warning: ReminderWarning, onOpenSettings: (() -> Void)? = nil) {
        self.warning = warning
        self.onOpenSettings = onOpenSettings
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
            Image(systemName: AppTheme.Images.warning)
                .foregroundStyle(AppTheme.Colors.warning)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                message
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.text)
                if let onOpenSettings {
                    Button(action: onOpenSettings) {
                        Text(.permissionOpenSettings)
                            .font(AppTheme.Typography.caption.weight(.semibold))
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .cardSurface(tint: AppTheme.Colors.warningSurface)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var message: some View {
        switch warning {
        case .turnedOff: Text(.permissionTurnedOffTitle)
        case .alertsDisabled: Text(.permissionAlertsOffTitle)
        case .denied: Text(.permissionDeniedTitle)
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.medium) {
        ReminderWarningBanner(warning: .turnedOff) {}
        ReminderWarningBanner(warning: .denied) {}
        ReminderWarningBanner(warning: .alertsDisabled) {}
    }
    .padding(AppTheme.Spacing.normal)
}
