//
//  Color+.swift
//  Flow
//
//  Created by handnew on 6/5/24.
//

import Foundation
import UIKit

extension UIColor {
  convenience init?(hex: String?) {
    guard let hex else { return nil }

    let r, g, b, a: CGFloat

    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

    var rgb: UInt64 = 0

    //var alphaValue: CGFloat = 1.0

    guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

    if hexSanitized.count == 6 {
      r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
      g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
      b = CGFloat(rgb & 0x0000FF) / 255.0
    } else if hexSanitized.count == 8 {
      r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
      g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
      b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
      //alphaValue = CGFloat(rgb & 0x000000FF) / 255.0
    } else {
      return nil
    }

    self.init(red: r, green: g, blue: b, alpha: 1.0)
  }


  func toHexString() -> String? {
    guard let components = cgColor.components, components.count >= 3 else {
      return nil
    }

    let r = components[0]
    let g = components[1]
    let b = components[2]

    // 만약 색상이 알파값을 포함하고 있다면
    let alpha = components.count >= 4 ? components[3] : 1.0

    // 알파 값까지 포함하여 변환
    return String(format: "%02X%02X%02X", Int(r * 255.0), Int(g * 255.0), Int(b * 255.0))
  }

  func random() -> UIColor {
    .init(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
  }
}

extension CGColor {
  func toUIColor() -> UIColor {
    UIColor(cgColor: self)
  }
}

