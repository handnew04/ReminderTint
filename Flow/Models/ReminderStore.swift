//
//  ReminderStore.swift
//  Flow
//
//  Created by handnew on 3/25/24.
//

import EventKit
import Foundation

final class ReminderStore {
  static let shared = ReminderStore()
  private let ekStore = EKEventStore()

  var isAvailable: Bool {
    EKEventStore.authorizationStatus(for: .reminder) == .authorized
  }

  func requestAccess() async throws {
    let status = EKEventStore.authorizationStatus(for: .reminder)
    switch status {
    case .authorized:
      log.debug("reminder access : authorized")
      return
    case .restricted:
      log.debug("reminder access : restricted")
      throw ReminderError.accessRestricted
    case .notDetermined:
      log.debug("reminder access : notDetermined")
      let accessGranted = try await ekStore.requestAccess(to: .reminder)
      guard accessGranted else {
        throw ReminderError.accessDenied
      }
    case .denied:
      throw ReminderError.accessDenied
    case .fullAccess:
      log.debug("reminder access : fullAccess by iOS17")
      return
    case .writeOnly:
      log.debug("reminder access : writeOnly by iOS17")
      return
    @unknown default:
      throw ReminderError.unknown
    }
  }

  func fetchReminderLists() async throws -> [Reminder] {
    guard isAvailable else { throw ReminderError.accessDenied }
    let calendars = ekStore.calendars(for: .reminder)
    var reminders: [Reminder] = []
    log.debug("reminder list :: \(calendars)")
    for calendar in calendars {
      do {
        try reminders.append(Reminder(with: calendar))
      } catch {
        log.warning("FAIL : ekCalendar into Reminder")
      }
    }
    return reminders
  }

  private func fetchReminderList(id: String) async throws -> EKCalendar {
    guard isAvailable else { throw ReminderError.accessDenied }
    guard let canlendar = ekStore.calendar(withIdentifier: id) else {
      throw ReminderStoreError.fetchFailed
    }
    log.debug("fetch reminder: \(canlendar)")
    return canlendar
  }

  func createReminderList(title: String, color: CGColor) async throws -> Bool {
    let ekCalendar = EKCalendar(for: .reminder, eventStore: ekStore)

    ekCalendar.title = title
    ekCalendar.cgColor = color

    if let iCloudSource = ekStore.sources.first(where: { $0.sourceType == .calDAV && $0.title == "iCloud" }) {
      ekCalendar.source = iCloudSource
    } else if let localSource = ekStore.sources.first(where: { $0.sourceType == .local }) {
      ekCalendar.source = localSource
    } else {
      throw ReminderStoreError.sourceNotFound
    }

    do {
      try ekStore.saveCalendar(ekCalendar, commit: true)
      return true
    } catch {
      throw ReminderStoreError.savedFailed(error)
    }
  }

  func updateReminderInfo(reminder: Reminder) async throws -> Bool {
    do {
      let ekCalendar = reminder.originalReminder
      ekCalendar.title = reminder.title
      ekCalendar.cgColor = reminder.color?.cgColor

      try ekStore.saveCalendar(ekCalendar, commit: true)
      return true
    } catch {
      throw ReminderStoreError.updateFailed
    }

  }

  func deleteReminderList(reminder: Reminder) async throws -> Bool {
    do {
      let reminder = try await fetchReminderList(id: reminder.id)
      try ekStore.removeCalendar(reminder, commit: true)
      return true
    } catch {
      throw ReminderStoreError.removeFailed
    }
  }
}


