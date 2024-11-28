//
//  ReminderBottomSheetViewModel.swift
//  Flow
//
//  Created by handnew on 6/14/24.
//

import Foundation
import UIKit

final class ReminderModifyViewViewModel {
  enum Mode {
    case create
    case modify(Reminder)
  }

  private let mode: Mode
  var title: String
  var color: UIColor

  init(mode: Mode) {
    self.mode = mode
    switch mode {
    case .create:
      self.title = "Title"
      self.color = UIColor().random()
    case .modify(let reminder):
      self.title = reminder.title
      self.color = reminder.color ?? UIColor().random()
    }
  }

  func save() async throws -> Bool {
    switch mode {
    case .create:
      return try await ReminderStore.shared.createReminderList(title: title, color: color.cgColor)
    case .modify(let reminder):
      var updateReminder = reminder
      updateReminder.title = title
      updateReminder.color = color
      return try await ReminderStore.shared.updateReminderInfo(reminder: updateReminder)
    }
  }
}
