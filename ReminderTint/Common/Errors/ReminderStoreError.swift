//
//  ReminderStoreError.swift
//  Flow
//
//  Created by handnew on 11/26/24.
//

import Foundation

enum ReminderStoreError: Error {
  case updateFailed
  case removeFailed
  case fetchFailed
  case savedFailed(Error)
  case sourceNotFound

  var errorDescription: String? {
    switch self {
    case .updateFailed:
      return "Failed to update reminder"
    case .removeFailed:
      return "Failed to remove reminder"
    case .fetchFailed:
      return "Failed to fetch reminder"
    case .savedFailed(let error):
      return "Failed to save reminder: \(error)"
    case .sourceNotFound:
      return "Reminder source not found"
    }
  }
}
