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
            log.debug("requestAccess reminder... fullAccess... by iOS17")
            return
        case .writeOnly:
            log.debug("requestAccess reminder... writeOnly... by iOS17")
        @unknown default:
            throw ReminderError.unknown
        }
    }

    func readAll() async throws -> [Reminder] {
        log.debug("Read all Reminders...")
        guard isAvailable else {
            throw ReminderError.accessDenied
        }

        let predicate = ekStore.predicateForReminders(in: nil)
        let ekReminders = try await ekStore.reminders(matching: predicate)
        let reminders: [Reminder] = try ekReminders.compactMap { ekReminder in
            do {
                return try Reminder(with: ekReminder)
            } catch ReminderError.reminderHasNoDueDate {
                log.warning("reminderHasNoDueDate")
                return nil
            }
        }
        return reminders
    }
}
