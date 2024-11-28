//
//  ReminderListCell.swift
//  Flow
//
//  Created by handnew on 6/12/24.
//

import UIKit

class ReminderListCell: UITableViewCell {
  let colorCircleView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 7.5
    view.layer.masksToBounds = true
    return view
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    return label
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    contentView.addSubview(colorCircleView)
    contentView.addSubview(titleLabel)

    colorCircleView.anchor(leading: contentView.leadingAnchor, paddingLeading: 16, width: 15, height: 15)
    colorCircleView.centerY(in: contentView)

    titleLabel.anchor(leading: colorCircleView.trailingAnchor, trailing: contentView.trailingAnchor, paddingLeading: 12, paddingTrailing: 16)
    titleLabel.centerY(in: contentView)
  }

  func configure(with reminder: Reminder) {
    titleLabel.text = reminder.title
    colorCircleView.backgroundColor = reminder.color
  }
}
