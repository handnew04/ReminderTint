//
//  Reminder+EKReminder.swift
//  Flow
//
//  Created by handnew on 3/25/24.
//

import EventKit
import Foundation

extension Reminder {
    init(with ekReminder: EKReminder) throws {
//        guard let dueDate = ekReminder.alarms?.first?.absoluteDate else {
//            throw ReminderError.reminderHasNoDueDate
//        }
        id = ekReminder.calendarItemIdentifier
        title = ekReminder.title
        self.dueDate = ekReminder.dueDateComponents?.date
        notes = ekReminder.notes
        isComplete = ekReminder.isCompleted
    }
}
