//
//  ManIntroductionTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/01.
//

import UIKit

protocol ManIntroductionTableViewCellDelegate: AnyObject {
    func removeButtonDidSeleced(_ tableviewCell: ManIntroductionTableViewCell)
    func updownButtonDidSelected(_ tableviewCell: ManIntroductionTableViewCell)
}

class ManIntroductionTableViewCell: UITableViewCell {

    weak var delegate: ManIntroductionTableViewCellDelegate?

    @IBOutlet private weak var contentsLabel: UILabel!
    @IBOutlet private weak var removeButton: UIButton!

    @IBAction func removeButtonDidSelected(_ sender: UIButton) {
        self.delegate?.removeButtonDidSeleced(self)
    }

    @IBAction func updownButtonDidSelected(_ sender: Any) {
        self.delegate?.updownButtonDidSelected(self)
    }

    func configure(_ model: Comment) {
        self.contentsLabel.text = model.content
    }
}
