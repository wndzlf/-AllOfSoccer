//
//  GameMatchingTagCollectionViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/25.
//

import UIKit

class FilterTagCollectionViewCell: UICollectionViewCell {

    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let tagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "chevron.down")
        return imageView
    }()

    private let didSelectedBackgroundColor = UIColor(red: 236.0/255.0, green: 95.0/255.0, blue: 95.0/255.0, alpha: 1.0)
    private let didDeSelectedbackgroundColor = UIColor(red: 246.0/255.0, green: 247.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    private let didSelectedTitleColor = UIColor.white
    private let didDeSelectedTitleColor = UIColor(red: 157.0/255.0, green: 159.0/255.0, blue: 160.0/255.0, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 18
        contentView.backgroundColor = didDeSelectedbackgroundColor
        
        contentView.addSubview(tagLabel)
        contentView.addSubview(tagImageView)
        
        tagLabel.textColor = didDeSelectedTitleColor
        tagImageView.tintColor = didDeSelectedTitleColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = 18
        let padding: CGFloat = 16
        let spacing: CGFloat = 4
        
        // ImageView on the right
        tagImageView.frame = CGRect(
            x: contentView.bounds.width - padding - imageSize,
            y: (contentView.bounds.height - imageSize) / 2,
            width: imageSize,
            height: imageSize
        )
        
        // Label on the left
        tagLabel.frame = CGRect(
            x: padding,
            y: 0,
            width: contentView.bounds.width - (padding * 2) - imageSize - spacing,
            height: contentView.bounds.height
        )
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        // Calculate size based on label content
        tagLabel.sizeToFit()
        let labelWidth = tagLabel.bounds.width
        let imageWidth: CGFloat = 18
        let padding: CGFloat = 16
        let spacing: CGFloat = 4
        
        let totalWidth = padding + labelWidth + spacing + imageWidth + padding
        let height: CGFloat = 31
        
        attributes.frame.size = CGSize(width: totalWidth, height: height)
        return attributes
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
