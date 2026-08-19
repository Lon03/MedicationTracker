//
//  SettingsView.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                remindersSection
                if let warning = viewModel.state.warning {
                    warningSection(warning)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.screenBackground)
            .screenTitle(.settingsTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.Colors.screenBackground, for: .navigationBar)
        }
        .tint(AppTheme.Colors.accent)
        .task { await viewModel.load() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.handle(.sceneBecameActive) }
        }
        .alert(
            Text(.settingsDisableTitle),
            isPresented: disableConfirmation
        ) {
            Button(role: .destructive) {
                viewModel.handle(.confirmDisable)
            } label: {
                Text(.settingsDisableConfirm)
            }
            Button(role: .cancel) {
                viewModel.handle(.cancelDisable)
            } label: {
                Text(.commonCancel)
            }
        } message: {
            Text(.settingsDisableMessage)
        }
    }

    private var remindersSection: some View {
        Section {
            Toggle(isOn: remindersBinding) {
                Label {
                    Text(.settingsRemindersToggle)
                } icon: {
                    Image(systemName: AppTheme.Images.reminder)
                }
            }
            .disabled(viewModel.state.isApplying)
        } header: {
            Text(.settingsRemindersSection)
        } footer: {
            Text(.settingsRemindersFooter)
        }
        .listRowBackground(AppTheme.Colors.cardBackground)
    }

    private func warningSection(_ warning: ReminderWarning) -> some View {
        Section {
            ReminderWarningBanner(
                warning: warning,
                onOpenSettings: warning.isRepairedInApp
                    ? nil
                    : { viewModel.handle(.openSystemSettings) }
            )
            .listRowInsets(EdgeInsets())
            .listRowBackground(AppTheme.Colors.transparent)
        }
    }

    /// Reads the state, never writes it — which is how Cancel leaves the switch
    /// where it was.
    private var remindersBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.remindersEnabled },
            set: { viewModel.handle(.setReminders($0)) }
        )
    }

    private var disableConfirmation: Binding<Bool> {
        Binding(
            get: { viewModel.state.isConfirmingDisable },
            set: { if !$0 { viewModel.handle(.cancelDisable) } }
        )
    }
}
