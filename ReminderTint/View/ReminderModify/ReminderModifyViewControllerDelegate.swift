//
//  ReminderModifyViewControllerDelegate.swift
//  Flow
//
//  Created by handnew on 11/26/24.
//

import Foundation

protocol ReminderModifyViewControllerDelegate: AnyObject {
    func reminderModifyViewController(_ controller: ReminderModifyViewController, _ isSuccess: Bool)


    func reminderModifyViewControllerDidCancel(_ controller: ReminderModifyViewController)
}

// 옵셔널 메서드 정의
extension ReminderModifyViewControllerDelegate {
    func reminderModifyViewControllerDidCancel(_ controller: ReminderModifyViewController) {

    }
}
