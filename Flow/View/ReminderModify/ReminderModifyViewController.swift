//
//  ReminderBottomSheetViewController.swift
//  Flow
//
//  Created by handnew on 6/14/24.
//

import UIKit

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

  init(viewModel: ReminderModifyViewViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    titleTextField.text = viewModel.title
    colorCodeTextField.text = viewModel.color.toHexString()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.layer.cornerRadius = 25
    view.layer.masksToBounds = true
    view.backgroundColor = viewModel.color

    setupUI()
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

  private func setupUI() {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 20
    stackView.alignment = .center
    stackView.distribution = .fill
    view.addSubview(stackView)

    stackView.anchor(
      top: view.safeAreaLayoutGuide.topAnchor,
      leading: view.leadingAnchor,
      bottom: view.bottomAnchor,
      trailing: view.trailingAnchor,
      paddingTop: 80,
      paddingLeading: defaultPadding,
      paddingTrailing: defaultPadding,
      paddingBottom: defaultPadding
    )

    // 스택뷰에 뷰들 추가
    stackView.addArrangedSubview(titleTextField)
    stackView.addArrangedSubview(colorCodeTextField)
    stackView.addArrangedSubview(colorCollectionView)

    // 추가 설정
    colorCollectionView.backgroundColor = .white
    colorCollectionView.backgroundColor?.withAlphaComponent(0.8)
    colorCollectionView.layer.cornerRadius = 25

    updateTextColor()
  }

  private func configureColorPalette() {


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
    self.view.endEditing(true)
    return true
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return true
  }
}

extension ReminderModifyViewController {
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    updateReminder()
  }

  private func updateReminder() {
    guard let title = titleTextField.text, title != "" else { return }
    guard let colorCode = colorCodeTextField.text, let color = UIColor(hex: colorCode) else { return }

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
