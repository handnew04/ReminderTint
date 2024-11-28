//
//  AddReminderCell.swift
//  Flow
//
//  Created by handnew on 11/28/24.
//

import UIKit

class AddReminderCell: UITableViewCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    backgroundColor = UIColor(hex: "FCFCFC")

    let circleImageView = UIImageView(image: UIImage(systemName: "plus.circle"))
    let label = UILabel()
    label.text = "Add Reminder List"

    let stackView = UIStackView(arrangedSubviews: [circleImageView, label])
    stackView.spacing = 8
    stackView.alignment = .center

    circleImageView.anchor(width: 16, height: 16)

    contentView.addSubview(stackView)
    stackView.anchor(leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, paddingLeading: 16, paddingTrailing: 16)
    stackView.centerY(in: contentView)
  }

}
