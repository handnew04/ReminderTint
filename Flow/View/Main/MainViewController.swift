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

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    viewModel.prepareReminderStore()
    setupTableView()
    setupTitleView()
    setupNavigation()
    bindViewModel()
  }

  private func setupTitleView() {
    let titleView = UIView()
    view.addSubview(titleView)

    titleView.anchor(
      top: view.safeAreaLayoutGuide.topAnchor,
      leading: view.leadingAnchor,
      trailing: view.trailingAnchor,
      height: 60
    )

    let titleLabel = UILabel()
    titleLabel.text = "Reminder List"
    titleLabel.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
    titleLabel.textAlignment = .left
    titleView.addSubview(titleLabel)

    titleLabel.anchor(
      leading: titleView.leadingAnchor,
      trailing: titleView.trailingAnchor,
      paddingLeading: 16,
      paddingTrailing: 16
    )
    titleLabel.centerX(in: titleView)
    titleLabel.centerY(in: titleView)
  }

  private func setupTableView() {
    view.addSubview(tableView)

    tableView.anchor(
      top: view.safeAreaLayoutGuide.topAnchor,
      leading: view.leadingAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      trailing: view.trailingAnchor,
      paddingTop: 60
    )

    tableView.layoutMargins = UIEdgeInsets.zero
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.estimatedRowHeight = 90
    tableView.rowHeight = UITableView.automaticDimension
    tableView.separatorStyle = .none

    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(ReminderListCell.self, forCellReuseIdentifier: "ReminderListCell")
    tableView.register(AddReminderCell.self, forCellReuseIdentifier: "AddReminderCell")
  }

  private func setupNavigation() {
    navigationItem.title = "Reminder Categories"
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addReminderList))
    navigationItem.rightBarButtonItem = addButton
  }

  private func bindViewModel() {
    viewModel.reminders.bind { [weak self] _ in
      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    }
  }

  @objc private func addReminderList() {

  }
}

extension MainViewController: ReminderModifyViewControllerDelegate {
  func reminderModifyViewController(_ controller: ReminderModifyViewController, _ isSuccess: Bool) {
    Task {
      await viewModel.loadReminders()
    }
  }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.reminders.value.count + 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == viewModel.reminders.value.count {
      let cell = tableView.dequeueReusableCell(withIdentifier: "AddReminderCell", for: indexPath) as! AddReminderCell
      return cell
    }


    let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderListCell", for: indexPath) as! ReminderListCell

    cell.configure(with: viewModel.reminders.value[indexPath.row])
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == viewModel.reminders.value.count  {
      showModifyViewController()
    }
    else {
      let reminder = viewModel.reminders.value[indexPath.row]
      showModifyViewController(for: reminder)
    }
  }

  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in

      guard let self = self else {
        completion(false)
        return
      }

      showCancelAlert(for: indexPath.row, completion: completion)
    }

    deleteAction.backgroundColor = .systemRed

    let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
    return configuration
  }

  func showModifyViewController(for reminder: Reminder? = nil) {
    let mode: ReminderModifyViewViewModel.Mode = reminder.map { .modify($0) } ?? .create
    let viewModel = ReminderModifyViewViewModel(mode: mode)
    let modifyVC = ReminderModifyViewController(viewModel: viewModel)

    modifyVC.modalPresentationStyle = .pageSheet
    if let sheet = modifyVC.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.prefersGrabberVisible = true
    }

    modifyVC.delegate = self
    present(modifyVC, animated: true)
  }

  func showCancelAlert(for index: Int, completion: @escaping (Bool) -> Void) {
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
