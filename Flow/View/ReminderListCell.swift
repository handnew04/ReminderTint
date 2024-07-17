//
//  ReminderListCell.swift
//  Flow
//
//  Created by handnew on 6/12/24.
//

import UIKit
import SnapKit

class ReminderListCell: UITableViewCell {
    let colorCircleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 7.5
        view.layer.masksToBounds = true
        view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(colorCircleView)
        contentView.addSubview(titleLabel)

        colorCircleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(colorCircleView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
    }

    func configure(with reminder: Reminder) {
        titleLabel.text = reminder.title
        colorCircleView.backgroundColor = reminder.color
    }
}
