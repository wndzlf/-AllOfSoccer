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
        setupLabels()
    }
    
    private func setupLabels() {
        // 레이블 설정으로 겹침 방지
        self.contentsLabel.numberOfLines = 2
        self.contentsLabel.lineBreakMode = .byTruncatingTail
        self.contentsLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.contentsLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        self.placeLabel.numberOfLines = 1
        self.placeLabel.lineBreakMode = .byTruncatingTail
        self.placeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        self.teamNameLabel.numberOfLines = 1
        self.teamNameLabel.lineBreakMode = .byTruncatingTail
        self.teamNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // 레이아웃이 제대로 업데이트되도록 설정
        self.contentView.setNeedsLayout()
    }

    internal func update(viewModel: GameMatchListViewModel) {
        self.dateLabel.text = viewModel.date
        self.timeLabel.text = viewModel.time

        self.placeLabel.text = viewModel.address
        self.contentsLabel.text = viewModel.description

        self.teamNameLabel.text = viewModel.teamName
        self.checkbutton.isSelected = viewModel.isFavorite
        self.recruitmentStatusLabel.text = viewModel.isRecruiting ? "모집 중" : "마감"
        
        // 레이아웃 업데이트로 겹침 방지
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 레이아웃 후에도 겹침 방지
        self.contentView.layoutIfNeeded()
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

// 목데이터는 GameMatchingViewModel에서 통합 관리하므로 제거
