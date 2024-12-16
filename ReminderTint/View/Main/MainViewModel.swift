//
//  MainViewModel.swift
//  Flow
//
//  Created by handnew on 3/31/24.
//

import Foundation

class Observable<T> {
  var value: T {
    didSet {
      listener?(value)
    }
  }

  private var listener: ((T) -> Void)?

  init(_ value: T) {
    self.value = value
  }

  func bind(_ listener: @escaping (T) -> Void) {
    self.listener = listener
    listener(value)
  }
}


final class MainViewModel {
  private var reminderStore: ReminderStore { ReminderStore.shared }
  var reminders: Observable<[Reminder]> = Observable([])
  var authrizationStatus: Observable<AuthorizationStatus> = Observable(.initial)

  enum AuthorizationStatus {
    case initial
    case authorized
    case denied
    case error(Error)
  }

  func prepareReminderStore() {
    Task {
      do {
        log.debug("prepareReminderStore before requestAccess")
        try await reminderStore.requestAccess()
        await loadReminders()
        await MainActor.run {
          authrizationStatus.value = .authorized
        }
      } catch ReminderError.accessDenied, ReminderError.accessRestricted {
        await MainActor.run {
          authrizationStatus.value = .denied
        }
      } catch {
        await MainActor.run {
          authrizationStatus.value = .error(error)
        }
      }
    }
  }

  @MainActor
  func loadReminders() async {
    do {
      let calendars = try await reminderStore.fetchReminderLists()
      reminders.value = calendars
    } catch {
      print("Error fetching reminder list \(error)")
    }
  }

  func deleteReminder(_ reminder: Reminder) async throws {
    do {
      try await reminderStore.deleteReminderList(reminder: reminder)
      await loadReminders()
    } catch {
      throw error
    }
  }
}

