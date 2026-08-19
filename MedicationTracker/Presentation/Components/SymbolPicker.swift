//
//  SymbolPicker.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct SymbolPicker: View {
    let symbols: [String]
    @Binding var selection: String

    private let columns = [
        GridItem(.adaptive(minimum: AppTheme.Sizes.symbolTile + AppTheme.Spacing.small)),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.small) {
            ForEach(symbols, id: \.self) { symbol in
                Button {
                    selection = symbol
                } label: {
                    Image(systemName: symbol)
                        .font(AppTheme.Typography.medicationSymbol)
                        .foregroundStyle(
                            symbol == selection ? AppTheme.Colors.cardBackground : AppTheme.Colors.accent
                        )
                        .frame(
                            width: AppTheme.Sizes.symbolTile,
                            height: AppTheme.Sizes.symbolTile
                        )
                        .background(
                            symbol == selection
                                ? AppTheme.Colors.text
                                : AppTheme.Colors.mint,
                            in: .rect(cornerRadius: AppTheme.Radius.symbol)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(SymbolNaming.name(for: symbol))
                .accessibilityAddTraits(symbol == selection ? [.isSelected] : [])
            }
        }
    }
}
