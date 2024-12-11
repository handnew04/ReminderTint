//
//  UIView+.swift
//  Flow
//
//  Created by handnew on 11/13/24.
//
import UIKit

let defaultPadding = CGFloat(20)

extension UIView {
  func anchor(top: NSLayoutYAxisAnchor? = nil,
              leading: NSLayoutXAxisAnchor? = nil,
              bottom: NSLayoutYAxisAnchor? = nil,
              trailing: NSLayoutXAxisAnchor? = nil,
              paddingTop: CGFloat = 0,
              paddingLeading: CGFloat = 0,
              paddingTrailing: CGFloat = 0,
              paddingBottom: CGFloat = 0,
              width: CGFloat? = nil,
              height: CGFloat? = nil) {
    translatesAutoresizingMaskIntoConstraints = false

    if let top {
      topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
    }

    if let leading {
      leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
    }

    if let bottom {
      bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
    }

    if let trailing {
      trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing).isActive = true
    }

    if let width {
      widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    if let height {
      heightAnchor.constraint(equalToConstant: height).isActive = true
    }
  }

  func centerX(in view: UIView) {
    translatesAutoresizingMaskIntoConstraints = false
    centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
  }

  func centerY(in view: UIView) {
    translatesAutoresizingMaskIntoConstraints = false
    centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}
