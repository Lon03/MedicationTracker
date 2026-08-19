//
//  MedicationsView.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct MedicationsView: View {
    @State private var viewModel: MedicationsViewModel
    private let dosageLine: (Medication) -> String

    init(viewModel: MedicationsViewModel, dosageLine: @escaping (Medication) -> String) {
        _viewModel = State(initialValue: viewModel)
        self.dosageLine = dosageLine
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.screenBackground)
            .screenTitle(.medicationsTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.handle(.addTapped)
                    } label: {
                        Image(systemName: AppTheme.Images.add)
                    }
                    .accessibilityLabel(Text(.commonAddMedication))
                }
            }
            .tint(AppTheme.Colors.accent)
            .task(id: viewModel.medicationsRevision) { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state.content {
        case .loading:
            ProgressView()
        case .empty:
            EmptyStateView(
                symbolName: AppTheme.Images.emptyMedications,
                title: .medicationsEmptyTitle,
                message: .medicationsEmptyBody,
                actionTitle: .commonAddMedication
            ) {
                viewModel.handle(.addTapped)
            }
        case let .error(message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        case let .loaded(medications):
            ScrollView {
                LazyVStack(spacing: AppTheme.Spacing.medium) {
                    ForEach(medications) { medication in
                        Button {
                            viewModel.handle(.select(medication))
                        } label: {
                            HStack(spacing: AppTheme.Spacing.medium) {
                                MedicationRow(
                                    medication: medication,
                                    dosageLine: dosageLine(medication)
                                )
                                Image(systemName: AppTheme.Images.chevron)
                                    .font(AppTheme.Typography.disclosureIndicator)
                                    .foregroundStyle(AppTheme.Colors.text)
                                    .frame(
                                        width: AppTheme.Sizes.disclosureIndicator,
                                        height: AppTheme.Sizes.disclosureIndicator
                                    )
                                    .background(AppTheme.Colors.elevatedBackground, in: .circle)
                                    .accessibilityHidden(true)
                            }
                            .cardSurface()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .screenPadding()
                .padding(.vertical, AppTheme.Spacing.medium)
            }
        }
    }
}
