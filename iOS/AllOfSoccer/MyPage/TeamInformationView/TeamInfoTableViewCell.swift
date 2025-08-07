//
//  TeamInfoTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/19.
//

import UIKit

protocol TeamInfoTableViewDelegate: AnyObject {
    func changeTeamInfoButtonDidSelected()
}

class TeamInfoTableViewCell: UITableViewCell {

    weak var delegate: TeamInfoTableViewDelegate?

    @IBOutlet private weak var ageContentLabel: UILabel!
    @IBOutlet private weak var skillContentLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var firstUniformTopView: RoundView!
    @IBOutlet private weak var secondUniformTopView: RoundView!
    @IBOutlet private weak var firstUniformBottonView: RoundView!
    @IBOutlet private weak var changeInfoButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        setChangeInfoButton()
    }

    private func setChangeInfoButton() {
        self.changeInfoButton.addTarget(self, action: #selector(changeInfoButtonDidSelected), for: .touchUpInside)
    }

    func configure(model: TeamInfoModel) {
        self.ageContentLabel.text = model.age
        self.skillContentLabel.text = model.skill
        self.phoneNumberLabel.text = model.phoneNumber

        // 서버랑 협의 후 데이터 형태 결정한 후에 코드 짤 에정
//        if model.Uniform.top.count >= 2 && model.Uniform.botton.count >= 1 {
//            self.firstUniformTopView.backgroundColor = model.Uniform.top[0]
//            self.secondUniformTopView.backgroundColor = model.Uniform.top[1]
//            self.firstUniformBottonView.backgroundColor = model.Uniform.botton
//        }
    }

    @objc private func changeInfoButtonDidSelected(sender: UIButton) {
        self.delegate?.changeTeamInfoButtonDidSelected()
    }
}
