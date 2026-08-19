# Medication Tracker

A small SwiftUI app for tracking one daily dose per medication and optionally
receiving a local reminder for it.

## Run

1. Open `MedicationTracker.xcodeproj` in Xcode.
2. Select an iOS simulator or connected iPhone.
3. Run the `MedicationTracker` scheme.

Targets iOS 18, built in Swift 6 language mode with strict concurrency. No
accounts, backend, API keys, or third-party dependencies are required.

## What it does

- Add a medication with its name, dose and daily intake time, then optionally
  enable a notification for that time.
- See a day's medication on the Schedule tab and mark each dose taken or missed.
- Step back a day, or pick one from the calendar, to answer a dose that was
  missed while the app was closed. The picker does not go into the future.
- Edit or delete medication from the Medications tab.
- Tapping a reminder opens the day it fired on and scrolls to that medication.
  Its "Taken" and "Missed" actions record the result without opening the app.
- One switch on the Settings tab turns reminders off app-wide. Turning it off
  asks for confirmation and cancels every pending request.

## Decisions

**Storage.** SwiftData holds medications and dose records locally. Repository
reads throw rather than returning empty, so a broken store cannot look like a
day with nothing on it. If the store cannot be opened — a notification tap can
launch the app while the device is still locked — that surfaces as a retryable
error rather than a crash or a silent in-memory copy.

**Permission.** Requested at the end of onboarding, after the copy has explained
what reminders are for; if declined there, on the first save of a medication
that wants one. Never after a denial, because iOS returns silently at that point
and the user sees nothing. Saving always succeeds regardless, and the UI explains
how to open notification settings.

**Nothing becomes "missed" on its own.** A dose stays open until the user says
taken or missed, however long that takes, and either answer can be corrected
afterwards. The app never decides for them.

**Editing the time does not rewrite the past.** Mark Monday's 09:00 dose taken,
then move the medication to 21:00: Monday still reads 09:00, and 21:00 applies
from the next unanswered day. Each answer is stored with the time it was given
against.

**A warning about missing reminders points at the fix that works.** Turn
reminders off in the app while iOS also has them denied, and the banner names the
app's own switch — it does not send the user to iOS Settings to undo something
they did here. `ReminderWarning` picks one cause in a pure function: the app's
switch first, then a denial from iOS, then alerts silenced.

**A reminder that was switched off cannot come back by accident.** Saving a
medication with its own toggle on adds nothing while the app-wide switch is off,
because the check lives in `UserNotificationsReminderScheduler` rather than at
each call site.

**Light-only.** The palette is one set of named tokens with no dark variants, so
the app pins the colour scheme rather than shipping a half-legible dark mode.

## Structure

MVVM with a coordinator per flow and a factory that builds each screen, in five
folders with one-way dependencies:

    Domain/        Entities, Interfaces (protocols the outside implements),
                   Services (pure decisions), Errors.  Imports Foundation only.
    Core/          Logging, localization, dosage formatting.  Shared leaf.
    Data/          SwiftData, UserNotifications, UserDefaults, UIKit.
    Presentation/  Screens (View + ViewModel + ViewState + Coordinator +
                   Factory protocol), Components, DesignSystem, Navigation.
    App/           Entry point, lifecycle, composition root.

Each screen declares the factory protocol it needs and `App/DI/Screens` holds the
conformances, so `Presentation` never names the composition root. Nothing points
upwards anywhere: no type declared in a lower folder is referenced from one that
should not know about it.

`DaySchedule` decides what any given day looks like as a pure function of
medications and dose records, so the app's only real algorithm is tested with no
fakes, no `await` and no main actor. Everything a view model touches is a
protocol it can be handed a stub for, which is why the notification tests never
go near `UNUserNotificationCenter`.

## Tests

`DayScheduleTests` — which medications belong to a day and in what order, and
that answering a day freezes the time it was answered against.

`ReminderTests` — the reminder path from the app-wide switch down to the request
that would go to iOS, against a spy: a medication becomes one repeating request
at its dose time; a denied permission schedules nothing and recovers on the next
activation once granted; a dose already answered today moves to tomorrow.

`ScheduleViewModelTests` — a dose answered on an earlier day is recorded against
that day, and leaves today's notification plan alone.

## Trade-offs

One daily time per medication. Twice a day means two entries; selected weekdays,
intervals and course end dates would need a rolling window of dated requests
budgeted against the 64 pending notifications iOS keeps — a scheduling
subsystem rather than a field.

Dose history is browsable one day at a time, not as a list or a chart. That is
enough to answer a dose the app was closed for; streaks and adherence
percentages are a second way to navigate an app this size.
