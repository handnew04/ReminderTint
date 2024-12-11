//
//  ReminderListCell.swift
//  Flow
//
//  Created by handnew on 6/12/24.
//

import UIKit

class ReminderListCell: UICollectionViewCell {
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

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }

  private func setupUI() {
    let stackView = UIStackView(arrangedSubviews: [colorCircleView, titleLabel])
    contentView.addSubview(stackView)

    stackView.axis = .horizontal
    stackView.spacing = 12
    stackView.alignment = .center
    stackView.anchor(
      top: contentView.topAnchor,
      leading: contentView.leadingAnchor,
      bottom: contentView.bottomAnchor,
      trailing: contentView.trailingAnchor,
      paddingTop: 10,
      paddingLeading: 16,
      paddingTrailing: 16,
      paddingBottom: 10
    )
    stackView.centerY(in: contentView)

    contentView.layer.cornerRadius = 12
    contentView.layer.masksToBounds = true

    colorCircleView.anchor(width: 15, height: 15)
  }

  func configure(with reminder: Reminder) {
    titleLabel.text = reminder.title
    colorCircleView.backgroundColor = reminder.color
    contentView.layer.backgroundColor = reminder.color?.cgColor.copy(alpha: 0.1)
  }
}
