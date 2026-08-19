//
//  RootCoordinatorView.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct RootCoordinatorView<Factory: RootCoordinatorFactory>: View {
    @Bindable private var coordinator: AppCoordinator
    private let factory: Factory

    init(coordinator: AppCoordinator, factory: Factory) {
        self.coordinator = coordinator
        self.factory = factory
    }

    var body: some View {
        Group {
            switch coordinator.route {
            case .onboarding:
                factory.makeOnboardingView()
            case .main:
                TabView(selection: $coordinator.selectedTab) {
                    Tab(value: AppCoordinator.Tab.schedule) {
                        factory.makeScheduleView()
                    } label: {
                        Label { Text(.tabSchedule) } icon: { Image(systemName: AppTheme.Images.schedule) }
                    }
                    Tab(value: AppCoordinator.Tab.medications) {
                        factory.makeMedicationsFlow()
                    } label: {
                        Label { Text(.tabMedications) } icon: { Image(systemName: AppTheme.Images.medications) }
                    }
                    Tab(value: AppCoordinator.Tab.settings) {
                        factory.makeSettingsView()
                    } label: {
                        Label { Text(.tabSettings) } icon: { Image(systemName: AppTheme.Images.settings) }
                    }
                }
                .tint(AppTheme.Colors.accent)
            }
        }
    }
}
