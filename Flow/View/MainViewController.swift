//
//  ViewController.swift
//  Flow
//
//  Created by handnew on 3/25/24.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    private let viewModel = MainViewModel()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewModel.prepareReminderStore()
        setupTableView()
        setUpTitleView()
        setupNavigationBar()
        bindViewModel()
        viewModel.prepareReminderStore()
    }

    private func setUpTitleView() {
        let titleView = UIView()
        view.addSubview(titleView)

        titleView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }

        let titleLabel = UILabel()
        titleLabel.text = "My Lists"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .left
        titleView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.contentInsetAdjustmentBehavior = .never

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReminderListCell")
    }

    private func setupNavigationBar() {
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
        let alertController = UIAlertController(title: "New List", message: "New reminder category", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Category Name"
        }
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let categoryName = alertController.textFields?.first?.text, !categoryName.isEmpty else { return }
           // self?.viewModel.createReminderList(named: categoryName)
        }
        alertController.addAction(createAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reminders.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderListCell", for: indexPath)
        cell.textLabel?.text = viewModel.reminders.value[indexPath.row].title

        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }
}
