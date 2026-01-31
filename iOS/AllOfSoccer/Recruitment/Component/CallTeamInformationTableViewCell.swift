//
//  CallTeamInformationTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/11.
//

import UIKit

protocol CallTeamInformationTableViewCellDelegate: AnyObject {
    func didSelect(teamInfo: CallTeamInformationView.TeamInfo)
}

class CallTeamInformationTableViewCell: UITableViewCell {

    internal weak var delegate: CallTeamInformationTableViewCellDelegate?

    private var teamInfo: CallTeamInformationView.TeamInfo?

    private var checkButton: SeletableButton = {
        let button = SeletableButton()
        button.normalImage = UIImage(systemName: "checkmark.circle")
        button.selectImage = UIImage(systemName: "checkmark.circle.fill")
        button.normalBackgroundColor = UIColor.clear
        button.selectBackgroundColor = UIColor.clear
        button.normalBorderColor = UIColor.clear
        button.selectBorderColor = UIColor.clear
        button.normalTintColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
        button.selectTintColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.normalTitleColor = UIColor.black
        button.selectTitleColor = UIColor.black
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left

        button.addTarget(self, action: #selector(checkButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private var mainLabel: UILabel = {
        let label = UILabel()
        label.text = "모두의 축구"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black

        return label
    }()

    private var subLabel: UILabel = {
        let label = UILabel()
        label.text = "20대 중반 - 30대 중반 / 실력 중하"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 157/255, green: 159/255, blue: 160/255, alpha: 1)

        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    private func setConstraints() {
        self.contentView.addsubviews(checkButton, mainLabel, subLabel)
        NSLayoutConstraint.activate([
            self.checkButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.checkButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),

            self.mainLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.mainLabel.leadingAnchor.constraint(equalTo: self.checkButton.trailingAnchor, constant: 8),

            self.subLabel.topAnchor.constraint(equalTo: self.mainLabel.bottomAnchor, constant: 5),
            self.subLabel.leadingAnchor.constraint(equalTo: self.checkButton.trailingAnchor, constant: 8),
            self.subLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5)
        ])
    }

    internal func configure(teamInfo: CallTeamInformationView.TeamInfo) {
        self.checkButton.isSelected = teamInfo.isSelected
        self.teamInfo = teamInfo
    }

    @objc func checkButtonTouchUp(_ sender: SeletableButton) {

        self.teamInfo?.isSelected = !sender.isSelected

        if let data = self.teamInfo {
            delegate?.didSelect(teamInfo: data)
        }
    }
}
