//
//  ViewController.swift
//  Flow
//
//  Created by handnew on 3/25/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    var reminders: [Reminder] = []
    private var reminderStore: ReminderStore { ReminderStore.shared }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.backgroundColor = .white
        let redButton = UIButton()
             redButton.backgroundColor = .blue
        redButton.setTitle("Button", for: .normal)

             // 버튼을 뷰에 추가
             view.addSubview(redButton)

             // SnapKit을 사용하여 제약 조건 설정
             redButton.snp.makeConstraints { make in
                 make.center.equalToSuperview()
//                 make.width.equalTo(40)
//                 make.height.equalTo(20)
             }
        prepareReminderStore()
    }

    func prepareReminderStore() {
        Task {
            do {
                log.debug("prepareReminderStore before requestAccess")
                try await reminderStore.requestAccess()
                reminders = try await reminderStore.readAll()
                log.debug(reminders)
            } catch ReminderError.accessDenied, ReminderError.accessRestricted {
                #if DEBUG
                //reminder sample
                #endif
            } catch {
                //showError
            }
        }
    }
}

