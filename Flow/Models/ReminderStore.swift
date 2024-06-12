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

    func fetchReminderLists() async throws -> [Reminder] {
        guard isAvailable else { throw ReminderError.accessDenied }
        let calendars = ekStore.calendars(for: .reminder)
        var reminders: [Reminder] = []
        log.debug("reminder list : :: : : : \(calendars)")
        for calendar in calendars {
            do {
                try reminders.append(Reminder(with: calendar))
            } catch {
                log.warning("FAIL : ekCalendar into Reminder")
            }
        }
        return reminders
    }
    
    func createReminderList() async throws {
        //create.. 
    }

}
