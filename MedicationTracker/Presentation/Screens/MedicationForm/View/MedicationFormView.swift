//
//  MedicationFormView.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

enum MedicationFormField: Hashable {
    case name
    case dose
}

struct MedicationFormView: View {
    @State private var viewModel: MedicationFormViewModel
    @State private var showsDeleteConfirmation: Bool
    @State private var presentedReminderWarning: ReminderWarning?
    @FocusState private var focusedField: MedicationFormField?
    @Environment(\.scenePhase) private var scenePhase
    private let formName: (DosageForm) -> String

    init(
        viewModel: MedicationFormViewModel,
        formName: @escaping (DosageForm) -> String
    ) {
        _viewModel = State(initialValue: viewModel)
        _showsDeleteConfirmation = State(initialValue: false)
        _presentedReminderWarning = State(initialValue: nil)
        self.formName = formName
    }

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage = viewModel.state.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(AppTheme.Colors.warning)
                    }
                    .listRowBackground(AppTheme.Colors.warningSurface)
                }
                detailsSection
                symbolSection
                intakeSection
                reminderSection

                if viewModel.state.isEditing {
                    deleteSection
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.screenBackground)
            .navigationTitle(
                viewModel.state.isEditing ? Text(.formEditTitle) : Text(.formAddTitle)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.Colors.screenBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.handle(.cancel)
                    } label: {
                        Image(systemName: AppTheme.Images.close)
                    }
                    .accessibilityLabel(Text(.commonCancel))
                    .disabled(viewModel.state.isSubmitting)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        focusedField = nil
                    } label: {
                        Text(.commonDone)
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                saveBar
            }
        }
        .task { await viewModel.load() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.handle(.sceneBecameActive) }
        }
        .onChange(of: viewModel.state.warning) { _, warning in
            if let warning { presentedReminderWarning = warning }
        }
        .alert(
            Text(.formRemindersTitle),
            isPresented: Binding(
                get: { presentedReminderWarning != nil },
                set: { if !$0 { presentedReminderWarning = nil } }
            ),
            presenting: presentedReminderWarning
        ) { warning in
            if warning.isRepairedInApp {
                Button(.commonDone, role: .cancel) {}
            } else {
                Button(.permissionOpenSettings) {
                    viewModel.handle(.openSystemSettings)
                }
                Button(.commonCancel, role: .cancel) {}
            }
        } message: { warning in
            reminderWarningMessage(warning)
        }
        .alert(
            Text(.deleteConfirmationTitle),
            isPresented: $showsDeleteConfirmation
        ) {
            Button(.commonDelete, role: .destructive) {
                viewModel.handle(.delete)
            }
            Button(.commonCancel, role: .cancel) {}
        } message: {
            Text(.deleteConfirmationMessage)
        }
    }

    private var saveBar: some View {
        Button {
            focusedField = nil
            viewModel.handle(.save)
        } label: {
            Text(.commonSave)
        }
        .buttonStyle(.primary)
        .disabled(!viewModel.state.canSave)
        .screenPadding()
        .padding(.vertical, AppTheme.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            AppTheme.Colors.formBottomBar
                .overlay(alignment: .top) {
                    AppTheme.Colors.line
                        .frame(height: AppTheme.Stroke.standard)
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private var detailsSection: some View {
        Section {
            LabeledContent {
                TextField(L(.formNamePlaceholder), text: $viewModel.name)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
            } label: {
                Text(.formNameLabel)
            }

            Picker(selection: $viewModel.form) {
                ForEach(DosageForm.allCases) { form in
                    Text(formName(form)).tag(form)
                }
            } label: {
                Text(.formUnitLabel)
            }

            LabeledContent {
                TextField(value: $viewModel.amount, format: .number) {
                    Text(.formDoseLabel)
                }
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .dose)
                .labelsHidden()
            } label: {
                Text(.formDoseLabel)
            }
        } header: {
            Text(.formDetailsTitle)
        }
        .listRowBackground(AppTheme.Colors.cardBackground)
    }

    private var symbolSection: some View {
        Section {
            SymbolPicker(symbols: AppTheme.Images.medicationSymbols, selection: $viewModel.symbolName)
                .padding(.vertical, AppTheme.Spacing.tiny)
        } header: {
            Text(.formSymbolLabel)
        }
        .listRowBackground(AppTheme.Colors.cardBackground)
    }

    private var reminderSection: some View {
        Section {
            Toggle(isOn: $viewModel.remindersEnabled) {
                Label {
                    Text(.formReminderToggle)
                } icon: {
                    Image(systemName: AppTheme.Images.reminder)
                }
            }
        } header: {
            Text(.formRemindersTitle)
        } footer: {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text(.formReminderOptionalCaption)

                if let warning = viewModel.state.warning {
                    ReminderWarningBanner(
                        warning: warning,
                        onOpenSettings: warning.isRepairedInApp
                            ? nil
                            : { viewModel.handle(.openSystemSettings) }
                    )
                }
            }
        }
        .listRowBackground(AppTheme.Colors.cardBackground)
    }

    @ViewBuilder
    private func reminderWarningMessage(_ warning: ReminderWarning) -> some View {
        switch warning {
        case .turnedOff: Text(.permissionTurnedOffTitle)
        case .denied: Text(.permissionDeniedTitle)
        case .alertsDisabled: Text(.permissionAlertsOffTitle)
        }
    }

    private var intakeSection: some View {
        Section {
            DatePicker(
                selection: $viewModel.doseTime,
                displayedComponents: .hourAndMinute
            ) {
                Text(.formIntakeTimeLabel)
            }
        } header: {
            Text(.formIntakeTitle)
        }
        .listRowBackground(AppTheme.Colors.cardBackground)
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                focusedField = nil
                showsDeleteConfirmation = true
            } label: {
                Text(.commonDelete).frame(maxWidth: .infinity)
            }
            .disabled(viewModel.state.isSubmitting)
        }
        .listRowBackground(AppTheme.Colors.cardBackground)
    }
}
