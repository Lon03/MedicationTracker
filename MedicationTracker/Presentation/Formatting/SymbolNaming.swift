//
//  SymbolNaming.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

/// Spoken names for the icon choices. Without these VoiceOver reads the raw SF
/// Symbol identifier — "pills.fill" — which is not a name for anything.
enum SymbolNaming {
    static func name(for symbol: String) -> String {
        switch symbol {
        case AppTheme.Images.medicationPills: L(.symbolPills)
        case AppTheme.Images.medicationCapsule: L(.symbolCapsule)
        case AppTheme.Images.medicationDrops: L(.symbolDrops)
        case AppTheme.Images.medicationVial: L(.symbolVial)
        case AppTheme.Images.medicationInjection: L(.symbolInjection)
        case AppTheme.Images.medicationBandage: L(.symbolBandage)
        case AppTheme.Images.medicationHeart: L(.symbolHeart)
        case AppTheme.Images.medicationLeaf: L(.symbolLeaf)
        default: L(.symbolPills)
        }
    }
}
