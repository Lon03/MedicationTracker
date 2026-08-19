//
//  AppTheme.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

enum AppTheme {
    enum Colors {
        static let accent: Color = .accentColor
        static let accentDeep: Color = .accentDeep
        static let text: Color = .textPrimary
        static let textSecondary: Color = .textSecondary
        static let screenBackground: Color = .screenBackground
        static let cardBackground: Color = .cardBackground
        static let transparent: Color = .transparent
        static let elevatedBackground: Color = .elevatedBackground
        static let line: Color = .divider
        static let mint: Color = .mintSurface

        static let doseTaken = accent
        static let doseMissed: Color = .doseMissed
        static let warningSurface: Color = .warningSurface
        static let warning: Color = .warning
        static let disabledSurface: Color = .disabledSurface
        static let disabledText: Color = .disabledText
        static let shadow: Color = .shadow
        static let doseMissedActionSurface: Color = .doseMissedActionSurface
        static let doseMissedBorder: Color = .doseMissedBorder
        static let doseTakenCard: Color = .doseTakenCard
        static let doseMissedCard: Color = .doseMissedCard
        static let doseTakenBorder: Color = .doseTakenBorder
        static let onboardingInnerSurface: Color = .onboardingInnerSurface
        static let formBottomBar: Color = .formBottomBar
        private static let healthGradientEnd: Color = .healthGradientEnd

        static let healthGradient = LinearGradient(
            colors: [mint, cardBackground, healthGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum Typography {
        static let screenTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
        static let sectionTitle = Font.system(.title3, design: .rounded, weight: .bold)
        static let cardTitle = Font.system(.headline, design: .rounded, weight: .semibold)
        static let caption = Font.system(.caption, design: .rounded)
        static let body = Font.system(.subheadline, design: .rounded)
        static let metric = Font.system(.title, design: .rounded, weight: .bold)
        static let disclosureIndicator = Font.system(size: 11, weight: .bold)
        static let menuIcon = Font.system(size: 17, weight: .semibold)
        static let emptyStateIcon = Font.system(size: 42, weight: .medium)
        static let onboardingIcon = Font.system(size: 58, weight: .medium)
        static let medicationSymbol = Font.title3
    }

    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let normal: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let screenMargin: CGFloat = 20
    }

    enum Radius {
        static let card: CGFloat = 26
        static let compactCard: CGFloat = 18
        static let symbol: CGFloat = 16
    }

    enum Sizes {
        static let symbolTile: CGFloat = 48
        static let disclosureIndicator: CGFloat = 34
        static let minimumTouchTarget: CGFloat = 44
        static let doseActionHeight: CGFloat = 48
        static let emptyStateSymbol: CGFloat = 112
        static let onboardingArtwork: CGFloat = 210
        static let onboardingArtworkInner: CGFloat = 142
        static let dayPickerSheetHeight: CGFloat = 480
    }

    enum TextLayout {
        static let bodyLineSpacing: CGFloat = 3
        static let onboardingLineSpacing: CGFloat = 4
    }

    enum Stroke {
        static let standard: CGFloat = 1
    }

    enum Effects {
        static let restingOpacity = 1.0
        static let primaryPressedOpacity = 0.8
        static let secondaryPressedOpacity = 0.6
        static let cardShadowRadius: CGFloat = 14
        static let cardShadowY: CGFloat = 7
    }

    enum Motion {
        static let onboardingPage = Animation.easeInOut(duration: 0.35)
        static let onboardingActions = Animation.easeInOut(duration: 0.25)
    }

    enum Images {
        static let schedule = "calendar"
        static let medications = "pills"
        static let settings = "gearshape"
        static let add = "plus"
        static let more = "ellipsis"
        static let chevron = "chevron.right"
        static let chevronLeft = "chevron.left"
        static let calendar = "calendar"
        static let close = "xmark"
        static let reminder = "bell"
        static let time = "clock"
        static let warning = "exclamationmark.triangle.fill"
        static let emptySchedule = "calendar.badge.clock"
        static let emptyMedications = "pills.circle"
        static let onboardingTrack = "list.bullet.clipboard.fill"
        static let onboardingReminders = "bell.badge.fill"
        static let onboardingPermission = "checkmark.seal.fill"

        static let doseTaken = "checkmark.circle.fill"
        static let doseMissed = "xmark.circle.fill"
        static let markTaken = "checkmark.circle"
        static let markMissed = "xmark.circle"

        static let medicationPills = "pills.fill"
        static let medicationCapsule = "capsule.fill"
        static let medicationDrops = "drop.fill"
        static let medicationVial = "cross.vial.fill"
        static let medicationInjection = "syringe.fill"
        static let medicationBandage = "bandage.fill"
        static let medicationHeart = "heart.fill"
        static let medicationLeaf = "leaf.fill"

        static let medicationDefault = medicationPills
        static let medicationSymbols = [
            medicationPills,
            medicationCapsule,
            medicationDrops,
            medicationVial,
            medicationInjection,
            medicationBandage,
            medicationHeart,
            medicationLeaf,
        ]
    }
}
