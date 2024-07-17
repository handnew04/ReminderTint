//
//  ReminderBottomSheetViewController.swift
//  Flow
//
//  Created by handnew on 6/14/24.
//

import UIKit
import SnapKit

class ReminderModifyViewController: UIViewController {
  private let viewModel: ReminderModifyViewViewModel
  var onDismiss: ((Bool) -> Void)?
  var hasChanges = false

  private let titleTextField: UITextField = {
    let textField = UITextField()
    textField.font = UIFont.systemFont(ofSize: 34, weight: .bold)
    textField.borderStyle = .none
    textField.returnKeyType = .done
    return textField
  }()

  init(viewModel: ReminderModifyViewViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    titleTextField.text = viewModel.reminder.title
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.layer.cornerRadius = 25
    view.layer.masksToBounds = true
    view.backgroundColor = viewModel.reminder.color

    setupSwipeGesture()
    setupView()
  }

  private func setupSwipeGesture() {
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
    swipeGesture.direction = .right
    view.addGestureRecognizer(swipeGesture)
  }

  @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
    if gesture.state == .ended {
      dismiss(animated: true)
    }
  }

  func dismiss(animated: Bool) {
    guard let parentVC = parent else { return }
    willMove(toParent: nil)

    UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
      self.view.alpha = 0
      self.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }) { _ in
      self.view.removeFromSuperview()
      self.removeFromParent()
      self.onDismiss?(self.hasChanges)
    }
  }

  private func setupView() {
    view.addSubview(titleTextField)
    titleTextField.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      make.left.right.equalToSuperview().inset(20)
    }

    updateTextColor()
  }

  private func setupColorPicker() {

  }

  private func updateTextColor() {
    titleTextField.textColor = isDarkColor(view.backgroundColor ?? .white) ? .white : .black  }

  private func isDarkColor(_ color: UIColor) -> Bool {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    let brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
    return brightness < 0.5
  }
}

extension ReminderModifyViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return true
  }
}
