//
//  AppFactory.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import Foundation

@MainActor
final class AppFactory {
    let onboardingStore: any OnboardingStateStoring
    let medications: any MedicationRepository
    let doses: any DoseRepository
    let authorizer: any NotificationAuthorizing
    let scheduler: any ReminderScheduling
    let reminderSwitch: any ReminderSwitching
    let reminderStatus: any ReminderStatusReading
    let badge: any BadgeUpdating
    let settingsOpener: any SystemSettingsOpening
    let notificationActions: any NotificationActionHandling
    let activation: AppActivation
    let coordinator: AppCoordinator

    init() {
        let store = ResilientMedicationStore {
            PersistenceContainer.container().map(SwiftDataMedicationStore.init(modelContainer:))
        }
        let center = SystemNotificationCenter()
        let authorizer = UserNotificationsAuthorizer(center: center)

        settingsOpener = UIKitSettingsOpener()
        let preferences = UserDefaultsReminderPreferenceStore()
        reminderStatus = ReminderStatus(preferences: preferences, authorizer: authorizer)
        let scheduler = UserNotificationsReminderScheduler(
            center: center,
            preferences: preferences,
            dosageLine: DosageFormatting.line(for:)
        )

        let reminderSwitch = ReminderSwitch(
            store: preferences,
            medications: store,
            doses: store,
            scheduler: scheduler,
            authorizer: authorizer
        )
        self.reminderSwitch = reminderSwitch
        medications = store
        doses = store
        self.authorizer = authorizer
        self.scheduler = scheduler
        let badge = DoseBadge(medications: store, doses: store, center: center)
        self.badge = badge
        notificationActions = DoseActionHandler(
            medications: store,
            doses: store,
            badge: badge,
            reminders: reminderSwitch
        )
        activation = AppActivation(badge: badge, reminders: reminderSwitch)
        onboardingStore = UserDefaultsOnboardingStore()
        coordinator = AppCoordinator(onboardingStore: onboardingStore)
    }
}
