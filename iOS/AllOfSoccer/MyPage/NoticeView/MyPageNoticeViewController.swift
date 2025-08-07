//
//  NoticeViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/15.
//

import UIKit

class MyPageNoticeViewController: UIViewController {

    @IBOutlet private weak var noticeTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.noticeTableView.delegate = self
        self.noticeTableView.dataSource = self
    }
}

extension MyPageNoticeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let MyPageNoticeDetailView = UIStoryboard.init(name: "MyPage", bundle: nil).instantiateViewController(withIdentifier: "MyPageNoticeDetailViewController") as? MyPageNoticeDetailViewController else { return }

        navigationController?.pushViewController(MyPageNoticeDetailView, animated: true)
    }
}

extension MyPageNoticeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageTableViewCell", for: indexPath) as? MyPageTableViewCell else {
            return UITableViewCell()
        }

        return cell
    }
}
