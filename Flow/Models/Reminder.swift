//
//  Reminder.swift
//  Flow
//
//  Created by handnew on 3/25/24.
//

import Foundation

struct Reminder {
    var id: String
    var title: String
    var dueDate: Date? = nil
    var notes: String? = nil
    var isComplete: Bool = false
}
