//
//  Reminder.swift
//  Flow
//
//  Created by handnew on 3/25/24.
//

import Foundation
import EventKit
import UIKit

struct Reminder {
    var id: String
    var title: String
    var type: Int?
    var allowsModify: Bool
    var color: UIColor?

    var hexColor: String { self.color?.toHexString() ?? "unKnown Color" }
}


extension Reminder {
    init(with ekCalendar: EKCalendar) throws {
        id = ekCalendar.calendarIdentifier
        title = ekCalendar.title
        allowsModify = ekCalendar.allowsContentModifications
        type = ekCalendar.type.rawValue
        color = UIColor(cgColor: ekCalendar.cgColor)
    }
}
