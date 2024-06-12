//
//  Color+.swift
//  Flow
//
//  Created by handnew on 6/5/24.
//

import Foundation
import UIKit

extension UIColor {
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
              return String(format: "#%02X%02X%02X%02X", Int(r * 255.0), Int(g * 255.0), Int(b * 255.0), Int(alpha * 255.0))
    }
}
