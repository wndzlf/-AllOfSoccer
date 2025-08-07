//
//  NoticeTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/03.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var placeLabel: UILabel!
    @IBOutlet private weak var contentsLabel: UILabel!
    @IBOutlet private weak var teamImageView: UIImageView!
    @IBOutlet private weak var teamNameLabel: UILabel!
    @IBOutlet private weak var checkbutton: UIButton!
    @IBOutlet private weak var recruitmentStatusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setCheckButton()
    }

    internal func update(viewModel: GameMatchListViewModel) {
        self.dateLabel.text = viewModel.date
        self.timeLabel.text = viewModel.time

        self.placeLabel.text = viewModel.address
        self.contentsLabel.text = viewModel.description

        self.teamNameLabel.text = viewModel.teamName
        self.checkbutton.isSelected = viewModel.isFavorite
        self.recruitmentStatusLabel.text = viewModel.isRecruiting ? "모집 중" : "마감"
    }

    private func setCheckButton() {
        self.checkbutton.setImage(UIImage.init(systemName: "heart"), for: .normal)
        self.checkbutton.setImage(UIImage.init(systemName: "heart.fill"), for: .selected)

        self.checkbutton.addTarget(self, action: #selector(checkButtonDidSelected), for: .touchUpInside)
    }

    @objc private func checkButtonDidSelected(sender: UIButton) {
        sender.isSelected = sender.isSelected == true ? false : true
        let didSelectedColor = UIColor(red: 236.0/255.0, green: 95.0/255.0, blue: 95.0/255.0, alpha: 1)
        let didDeSelectedColor = UIColor.black
        sender.tintColor = sender.isSelected ? didSelectedColor : didDeSelectedColor
    }
}

internal struct GameMatchListViewModel {
    internal let date: String
    internal let time: String
    internal let address: String
    internal let description: String
    internal let isFavorite: Bool
    internal let isRecruiting: Bool
    internal let teamName: String

    internal init(date: String, time: String, address: String, description: String, isFavorite: Bool, isRecruiting: Bool, teamName: String) {
        self.date = date
        self.time = time
        self.address = address
        self.description = description
        self.isFavorite = isFavorite
        self.isRecruiting = isRecruiting
        self.teamName = teamName
    }
}

extension GameMatchListViewModel {

    static var mockData: GameMatchListViewModel = GameMatchListViewModel(date: "09.14.월", time: "22:00", address: "양원역 구장", description: "11대 11 실력 하하 구장비 7천원", isFavorite: true, isRecruiting: true, teamName: "FC 캘란")

    static var mockData1: GameMatchListViewModel = GameMatchListViewModel(date: "09.14.월", time: "22:00", address: "태릉중학교", description: "11대 11 실력 하하 구장비 5만원", isFavorite: true, isRecruiting: true, teamName: "FC 바르셀로나")

    static var mockData2: GameMatchListViewModel = GameMatchListViewModel(date: "09.14.월", time: "22:00", address: "용산 아이파크몰", description: "11대 11 실력 하하 구장비 7천원", isFavorite: true, isRecruiting: true, teamName: "FC 뮌헨")
}
