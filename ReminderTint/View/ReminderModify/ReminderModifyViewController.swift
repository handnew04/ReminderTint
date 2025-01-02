//
//  ReminderBottomSheetViewController.swift
//  Flow
//
//  Created by handnew on 6/14/24.
//

import UIKit
import SnapKit

class ReminderModifyViewController: UIViewController {
  weak var delegate: ReminderModifyViewControllerDelegate?
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

  private let colorCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()

  private let colorCodeTextField: UITextField = {
    let textField = UITextField()
    textField.returnKeyType = .done
    textField.font = UIFont.systemFont(ofSize: 20)
    return textField
  }()

  private let colorPicker: UIColorWell = {
    let colorWell = UIColorWell()
    colorWell.supportsAlpha = false
    return colorWell
  }()

  init(viewModel: ReminderModifyViewViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    titleTextField.text = viewModel.title
    colorCodeTextField.text = viewModel.color.toHexString()
    colorPicker.selectedColor = viewModel.color
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.layer.cornerRadius = 25
    view.layer.masksToBounds = true
    view.backgroundColor = viewModel.color

    titleTextField.delegate = self
    colorCodeTextField.delegate = self

    setupUI()
    setupViewModel()
  }

  private func setupViewModel() {
    viewModel.colorDidChange = { [weak self] color in
      UIView.animate(withDuration: 0.3) {
        self?.view.backgroundColor = color
        self?.colorCodeTextField.text = color.toHexString()
        self?.colorPicker.selectedColor = color
        self?.updateTextColor()
      }
    }
  }

  private func setupUI() {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 20
    stackView.alignment = .center
    stackView.distribution = .fill
    view.addSubview(stackView)

    stackView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
      make.leading.trailing.equalToSuperview().inset(20)
    }

    stackView.addArrangedSubview(titleTextField)
    stackView.addArrangedSubview(colorCodeTextField)
    stackView.addArrangedSubview(colorPicker)

    colorPicker.addTarget(self, action: #selector(colorChanged), for: .valueChanged)

    updateTextColor()
  }

  @objc func colorChanged(_ sender: UIColorWell) {
    guard let selectedColor = sender.selectedColor else { return }
    viewModel.color = selectedColor
  }

  private func updateTextColor() {
    titleTextField.textColor = isDarkColor(view.backgroundColor ?? .white) ? .white : .black
    colorCodeTextField.textColor = isDarkColor(view.backgroundColor ?? .white) ? .white : .black
  }

  private func isDarkColor(_ color: UIColor) -> Bool {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    let brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
    return brightness < 0.5
  }
}

extension ReminderModifyViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    guard textField == colorCodeTextField else { return true }

    let currentText = textField.text ?? ""

    if string.isEmpty {
        return true
    }

    if currentText.count >= 6 {
      return false
    }

    // 16진수 문자만 허용
    let allowedCharacters = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
    let characterSet = CharacterSet(charactersIn: string)

    return characterSet.isSubset(of: allowedCharacters)
  }

  func textFieldDidChangeSelection(_ textField: UITextField) {
    guard textField.text?.count == 6, let color = UIColor(hex: textField.text) else { return }
    viewModel.color = color
  }

}

extension ReminderModifyViewController {
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    updateReminder()
  }

  private func updateReminder() {
    guard let title = titleTextField.text, title != "" else { return }
    guard let color = UIColor(hex: colorCodeTextField.text) else { return }

    viewModel.title = title
    viewModel.color = color

    Task {
      do {
        let success = try await viewModel.save()
        if success {
          await MainActor.run { [weak self] in
            guard let self = self else { return }

            self.delegate?.reminderModifyViewController(self, success)
          }
        }
      } catch {
        print("Failed to update reminder: \(error)")
      }
    }
  }
}
