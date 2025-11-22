//
//  MyPageTeamInfoViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/18.
//

import UIKit

class MyPageTeamInfomationViewController: UIViewController {

    private var teamInfoTableViewModel: [TeamInfoModel] = []

    @IBOutlet private weak var teamInfoTableView: IntrinsicTableView!
    @IBOutlet private weak var addCellButton: RoundButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        tempTeamInfoTablViewModelSetting()
        setTeamInfoTablView()
        setAddCellButton()
    }

    private func tempTeamInfoTablViewModelSetting() {
        self.teamInfoTableViewModel.append(TeamInfoModel(age: "30", skill: "최상", Uniform: Uniform(top: ["red", "white"], bottom: "white"), phoneNumber: "010-1111-1111"))
        self.teamInfoTableViewModel.append(TeamInfoModel(age: "29", skill: "하", Uniform: Uniform(top: ["red", "white"], bottom: "white"), phoneNumber: "010-9999-9999"))
    }

    private func setTeamInfoTablView() {
        self.teamInfoTableView.delegate = self
        self.teamInfoTableView.dataSource = self
    }

    private func setAddCellButton() {
        self.addCellButton.addTarget(self, action: #selector(addCellButtonDidSelected), for: .touchUpInside)
    }

    @objc private func addCellButtonDidSelected(sender: UIButton) {
        guard let addTeamInfoViewController = UIStoryboard.init(name: "MyPage", bundle: nil).instantiateViewController(withIdentifier: "MyPageAddTeamInfoViewController") as? MyPageAddTeamInfoViewController else { return }

        navigationController?.pushViewController(addTeamInfoViewController, animated: true)
    }
}

extension MyPageTeamInfomationViewController: UITableViewDelegate {

}

extension MyPageTeamInfomationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teamInfoTableViewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamInfoTableViewCell", for: indexPath) as? TeamInfoTableViewCell else {
            return UITableViewCell()
        }

        cell.delegate = self

        let cellModel = self.teamInfoTableViewModel[indexPath.row]
        cell.configure(model: cellModel)

        return cell
    }
}

extension MyPageTeamInfomationViewController: TeamInfoTableViewDelegate {
    func changeTeamInfoButtonDidSelected() {
        let vc = MyPageChangeTeamInfoViewController()

        navigationController?.pushViewController(vc, animated: true)
    }
}
