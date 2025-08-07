//
//  GameMatchingTagCollectionViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/25.
//

import UIKit

class FilterTagCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagImageView: UIImageView!

    private let didSelectedBackgroundColor = UIColor(red: 236.0/255.0, green: 95.0/255.0, blue: 95.0/255.0, alpha: 1.0)
    private let didDeSelectedbackgroundColor = UIColor(red: 246.0/255.0, green: 247.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    private let didSelectedTitleColor = UIColor.white
    private let didDeSelectedTitleColor = UIColor(red: 157.0/255.0, green: 159.0/255.0, blue: 160.0/255.0, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.layer.cornerRadius = 18
        self.contentView.backgroundColor = self.didDeSelectedbackgroundColor
        self.tagLabel.textColor = self.didDeSelectedTitleColor
        self.tagImageView.tintColor = self.didDeSelectedTitleColor
    }

    func configure(_ model: FilterTagModel, _ didSelectedFilterList: [String: FilterType]) {
        self.tagLabel.text = model.filterType.tagTitle

        if !didSelectedFilterList.isEmpty {
            let valueFiterList = Set(didSelectedFilterList.values)
            if valueFiterList.contains(model.filterType) {
                self.contentView.backgroundColor = didSelectedBackgroundColor
                self.tagLabel.textColor = didSelectedTitleColor
                self.tagImageView.tintColor = didSelectedTitleColor
            } else {
                self.contentView.backgroundColor = didDeSelectedbackgroundColor
                self.tagLabel.textColor = didDeSelectedTitleColor
                self.tagImageView.tintColor = didDeSelectedTitleColor
            }
        } else {
            self.contentView.backgroundColor = didDeSelectedbackgroundColor
            self.tagLabel.textColor = didDeSelectedTitleColor
            self.tagImageView.tintColor = didDeSelectedTitleColor
        }
    }
}
