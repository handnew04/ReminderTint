//
//  File.swift
//  Flow
//
//  Created by handnew on 3/28/24.
//

import Foundation

extension Date {
    enum DateType {
        case hyphen
        case hyphenWithTime
        case time
    }

    func dateFormatter(_ type: DateType) -> String {
        let formatter = DateFormatter()

        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = .autoupdatingCurrent
        formatter.locale = Locale.current

        switch type {
        case .hyphen:
            formatter.dateFormat = "yyyy-MM-dd"
        case .hyphenWithTime:
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        case .time:
            formatter.dateFormat = "HH:mm"
        }

        return formatter.string(from: self)
    }
}
