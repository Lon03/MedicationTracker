//
//  ScheduleView.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel
    private let dosageLine: (DoseOccurrence) -> String

    @Environment(\.scenePhase) private var scenePhase
    @State private var isChoosingDay = false

    init(
        viewModel: ScheduleViewModel,
        dosageLine: @escaping (DoseOccurrence) -> String
    ) {
        _viewModel = State(initialValue: viewModel)
        self.dosageLine = dosageLine
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DayNavigator(
                    title: viewModel.state.dayTitle,
                    canGoForward: !viewModel.state.isShowingToday,
                    onPrevious: { viewModel.handle(.stepDay(days: -1)) },
                    onNext: { viewModel.handle(.stepDay(days: 1)) },
                    onChooseDay: { isChoosingDay = true }
                )
                .screenPadding()
                .padding(.top, AppTheme.Spacing.small)

                if let warning = viewModel.state.warning {
                    ReminderWarningBanner(
                        warning: warning,
                        onOpenSettings: warning.isRepairedInApp
                            ? nil
                            : { viewModel.handle(.openSystemSettings) }
                    )
                    .screenPadding()
                    .padding(.top, AppTheme.Spacing.medium)
                }

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(AppTheme.Colors.screenBackground)
            .screenTitle(.scheduleTitle)
        }
        .tint(AppTheme.Colors.accent)
        .task { await viewModel.load() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.handle(.sceneBecameActive) }
        }
        // Only the arrival matters: consuming the link sets it back to nil,
        // which would otherwise fire this a second time and reload for nothing.
        .onChange(of: viewModel.pendingDeepLink) { _, link in
            guard link != nil else { return }
            viewModel.handle(.deepLinkChanged)
        }
        .sheet(isPresented: $isChoosingDay) {
            dayPicker
        }
        .alert(
            Text(.errorGeneric),
            isPresented: Binding(
                get: { viewModel.state.didFailToRecord },
                set: { if !$0 { viewModel.handle(.recordFailureDismissed) } }
            )
        ) {} message: {
            Text(.scheduleRecordFailed)
        }
        // `NSCalendarDayChanged` is posted on a background thread; the closure
        // is typed `@MainActor` anyway, so the hop is not optional.
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            Task { @MainActor in viewModel.handle(.dayChanged) }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state.content {
        case .loading:
            ProgressView()
        case .empty:
            EmptyStateView(
                symbolName: AppTheme.Images.emptySchedule,
                title: .scheduleEmptyTitle,
                message: .scheduleEmptyBody,
                actionTitle: .commonAddMedication
            ) {
                viewModel.handle(.addMedication)
            }
        case .noDoses:
            EmptyStateView(
                symbolName: AppTheme.Images.emptySchedule,
                title: .dayNoDosesTitle,
                message: .dayNoDosesBody
            )
        case let .error(message):
            ErrorStateView(message: message) { Task { await viewModel.load() } }
        case let .loaded(occurrences):
            loaded(occurrences)
        }
    }

    private func loaded(_ occurrences: [DoseOccurrence]) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    progress(for: occurrences)

                    Text(.scheduleSectionTitle)
                        .font(AppTheme.Typography.sectionTitle)

                    doseCards(occurrences)
                }
                .screenPadding()
                .padding(.vertical, AppTheme.Spacing.large)
            }
            // `task(id:)` rather than `onChange`: the link is consumed during
            // `load()`, so on a launch *from* the notification the id is already
            // set by the time these rows exist and an `onChange` would never fire.
            .task(id: viewModel.state.focusedMedicationID) {
                guard let id = viewModel.state.focusedMedicationID else { return }
                // One turn, so the rows above are laid out and have registered
                // their ids before we ask to be taken to one.
                await Task.yield()
                withAnimation { proxy.scrollTo(id, anchor: .center) }
                viewModel.handle(.focusHandled)
            }
        }
    }

    private func doseCards(_ occurrences: [DoseOccurrence]) -> some View {
        // One clock for the whole list: a `TimelineView` per row would run a
        // timer per row to answer the same question at the same instant.
        TimelineView(.everyMinute) { context in
            LazyVStack(spacing: AppTheme.Spacing.medium) {
                ForEach(occurrences) { occurrence in
                    DoseCard(
                        occurrence: occurrence,
                        dosageLine: dosageLine(occurrence),
                        isWorking: viewModel.state.recordingMedicationIDs.contains(
                            occurrence.medication.id
                        ),
                        allowsRecording: viewModel.canRecord(
                            occurrence,
                            at: context.date
                        ),
                        onMarkTaken: {
                            viewModel.handle(
                                .recordDose(
                                    medicationID: occurrence.medication.id,
                                    outcome: .taken
                                )
                            )
                        },
                        onMarkMissed: {
                            viewModel.handle(
                                .recordDose(
                                    medicationID: occurrence.medication.id,
                                    outcome: .missed
                                )
                            )
                        }
                    )
                    .id(occurrence.medication.id)
                }
            }
        }
    }

    private var dayPicker: some View {
        NavigationStack {
            DatePicker(
                selection: $viewModel.selectedDay,
                in: ...viewModel.state.latestSelectableDay,
                displayedComponents: .date
            ) {
                Text(.dayChooseAction)
            }
            .datePickerStyle(.graphical)
            .tint(AppTheme.Colors.accent)
            .screenPadding()
            .frame(maxHeight: .infinity, alignment: .top)
            .background(AppTheme.Colors.screenBackground)
            .screenTitle(.dayChooseAction)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isChoosingDay = false } label: { Text(.commonDone) }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func progress(for occurrences: [DoseOccurrence]) -> some View {
        let taken = occurrences.filter(\.status.isTaken).count
        return HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.tiny) {
                Text(.scheduleProgressTitle)
                    .font(AppTheme.Typography.sectionTitle)
                Text(.scheduleProgressSubtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            Spacer()
            // Verbatim: interpolating into `Text` would extract "%lld / %lld"
            // into the catalog as if it were copy.
            Text(verbatim: "\(taken) / \(occurrences.count)")
                .font(AppTheme.Typography.metric)
                .monospacedDigit()
        }
        .padding(AppTheme.Spacing.normal)
        .background(AppTheme.Colors.healthGradient, in: .rect(cornerRadius: AppTheme.Radius.card))
    }
}
