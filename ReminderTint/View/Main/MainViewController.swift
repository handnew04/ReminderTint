//
//  ViewController.swift
//  Flow
//
//  Created by handnew on 3/25/24.
//

import UIKit

class MainViewController: UIViewController {
  private let viewModel = MainViewModel()
  private let tableView = UITableView()

  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 8

    let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collection.backgroundColor = .systemBackground
    collection.register(ReminderListCell.self, forCellWithReuseIdentifier: "ReminderCell")
    return collection
  }()

  private let addButton: UIButton = {
    let button = UIButton()
    button.setTitle("Add Reminder List", for: .normal)
    button.setTitleColor(.black, for: .normal)
    var config = UIButton.Configuration.filled()
    config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0)
    config.background.cornerRadius = 12
    config.background.backgroundColor = UIColor(hex: "F0F0F0")
    button.configuration = config
    return button
  }()

  private let titleView: UIView = {
    let view = UIView()
    let titleLabel = UILabel()
    view.addSubview(titleLabel)
    titleLabel.text = "Reminder List"
    titleLabel.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
    titleLabel.textAlignment = .left

    titleLabel.anchor(
      leading: view.leadingAnchor,
      trailing: view.trailingAnchor,
      paddingLeading: 16,
      paddingTrailing: 16
    )
    titleLabel.centerX(in: view)
    titleLabel.centerY(in: view)
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    viewModel.prepareReminderStore()
    bindViewModel()
    setupUI()
  }

  private func setupUI() {
    view.addSubview(collectionView)
    view.addSubview(addButton)
    view.addSubview(titleView)

    setupTitleView()
    setupAddButton()
    setupCollectionView()
  }

  private func setupTitleView() {
    titleView.anchor(
      top: view.safeAreaLayoutGuide.topAnchor,
      leading: view.leadingAnchor,
      trailing: view.trailingAnchor,
      height: 60
    )
  }

  private func setupCollectionView() {
    collectionView.anchor(
      top: view.safeAreaLayoutGuide.topAnchor,
      leading: view.leadingAnchor,
      bottom: addButton.topAnchor,
      trailing: view.trailingAnchor,
      paddingTop: 60,
      paddingLeading: 16,
      paddingTrailing: 16,
      paddingBottom: 10
    )

    collectionView.delegate = self
    collectionView.dataSource = self
  }

  private func setupAddButton() {
    addButton.anchor(
      leading: view.leadingAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      trailing: view.trailingAnchor,
      paddingLeading: 16,
      paddingTrailing: 16,
      paddingBottom: 20)

    addButton.addTarget(self, action: #selector (addReminderList), for: .touchUpInside)
  }

  private func bindViewModel() {
    viewModel.reminders.bind { [weak self] _ in
      DispatchQueue.main.async {
        self?.collectionView.reloadData()
      }
    }
    viewModel.authrizationStatus.bind { [weak self] status in
      self?.handleAuthorizationStatus(status)
    }
  }

  private func handleAuthorizationStatus(_ status: MainViewModel.AuthorizationStatus) {
    switch status {
    case .authorized, .initial:
      break
    case .denied:
      showPermissionAlert()
      break
    case .error(_):
      break
    }
  }

  private func showPermissionAlert() {
    let alert = UIAlertController(title: "Permission Required", message: "Please allow access to reminders to use this feature", preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
      if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(settingUrl)
      }
    }))

    present(alert, animated: true)
  }

  @objc private func addReminderList() {
    if case .authorized = viewModel.authrizationStatus.value {
      showModifyViewController()
    } else {
      showPermissionAlert()
    }
  }
}

extension MainViewController: ReminderModifyViewControllerDelegate {
  func reminderModifyViewController(_ controller: ReminderModifyViewController, _ isSuccess: Bool) {
    Task {
      await viewModel.loadReminders()
    }
  }

  func showModifyViewController(for reminder: Reminder? = nil) {
    let mode: ReminderModifyViewViewModel.Mode = reminder.map { .modify($0) } ?? .create
    let viewModel = ReminderModifyViewViewModel(mode: mode)
    let modifyVC = ReminderModifyViewController(viewModel: viewModel)

    modifyVC.modalPresentationStyle = .pageSheet
    if let sheet = modifyVC.sheetPresentationController {
      sheet.detents = [.large()]
      sheet.prefersGrabberVisible = true
    }

    modifyVC.delegate = self
    present(modifyVC, animated: true)
  }

  func showDeleteAlert(for index: Int, completion: @escaping (Bool) -> Void) {
    let reminderToDelete = self.viewModel.reminders.value[index]

    let alert = UIAlertController(title: "Delete Reminder", message: "Are you sure you want to delete this reminder list?", preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
      completion(false)
    })

    alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
      Task {
        do {
          try await self.viewModel.deleteReminder(reminderToDelete)
          completion(true)
        } catch {
          await MainActor.run {
            // Failed Alert
          }
          completion(false)
        }
      }
    })

    self.present(alert, animated: true)
  }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.reminders.value.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReminderCell", for: indexPath) as! ReminderListCell
    cell.configure(with: viewModel.reminders.value[indexPath.row])
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.bounds.width
    return CGSize(width: width, height: 50)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let reminder = viewModel.reminders.value[indexPath.row]
    showModifyViewController(for: reminder)
  }

  func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
    guard let indexPath = indexPaths.first else { return nil }

    return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
      let deleteAction = UIAction(
        title: "Delete",
        image: UIImage(systemName: "trash"),
        attributes: .destructive
      ) { [weak self] _ in
        self?.showDeleteAlert(for: indexPath.item) { isDeleted in
          if isDeleted { self?.collectionView.deleteItems(at: indexPaths) }
        }
      }
      return UIMenu(title: "", children: [deleteAction])
    }
  }
}
