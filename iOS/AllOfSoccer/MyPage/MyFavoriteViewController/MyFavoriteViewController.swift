//
//  MyFavoriteViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/16.
//

import UIKit

class MyFavoriteViewController: UIViewController {

    private var tableViewModel: [TableViewModel] = []

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setMyTableView()
        setData()
    }

    private func setMyTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    private func setData() {
        for index in 0...3 {
            let dataModel = TableViewModel(index: index, date: "8월 27일", location: "용산 아이팤몰", rules: "11vs11/남성매치/풋살화 필수", fee: 7000, temaInfo: "모두의축구", recruitmentState: "모집중")
            self.tableViewModel.append(dataModel)
        }
    }
}

extension MyFavoriteViewController: UITableViewDelegate {

}

extension MyFavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyFavoriteTableViewCell", for: indexPath) as? MyFavoriteTableViewCell else { return UITableViewCell() }

        if let data = self.tableViewModel[safe: indexPath.row] {
            cell.configure(data)
        }

        cell.delegate = self

        return cell
    }
}

extension MyFavoriteViewController: MyFavoriteTableViewCellDelegate {
    func favoriteButtonDidSelected(tableViewModel: TableViewModel) {

        self.tableViewModel = self.tableViewModel.filter { $0.index !=  tableViewModel.index }

        self.tableView.reloadData()
    }
}

extension MyFavoriteViewController {

    struct TableViewModel {
        let index: Int
        let date: String
        let location: String
        let rules: String
        let fee: Int
        let temaInfo: String
        let recruitmentState: String
    }
}
