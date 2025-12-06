//
//  filterContentsTagCollectionViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/03.
//

import UIKit

class FilterDetailTagCollectionViewCell: UICollectionViewCell {

    lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.backgroundColor = UIColor(red: 221.0/255.0, green: 222.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        label.textColor = UIColor(red: 157.0/255.0, green: 159.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(red: 221.0/255.0, green: 222.0/255.0, blue: 225.0/255.0, alpha: 1.0).cgColor
        label.clipsToBounds = true
        label.layer.cornerRadius = 6

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.addSubview(tagLabel)

        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            self.tagLabel.textColor = isSelected ? .white : UIColor(red: 157.0/255.0, green: 159.0/255.0, blue: 160.0/255.0, alpha: 1.0)
            self.tagLabel.backgroundColor = isSelected ? UIColor(red: 236.0/255.0, green: 95.0/255.0, blue: 95.0/255.0, alpha: 1.0) : UIColor(red: 221.0/255.0, green: 222.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            self.tagLabel.layer.borderColor = isSelected ? UIColor(red: 236.0/255.0, green: 95.0/255.0, blue: 95.0/255.0, alpha: 1.0).cgColor : UIColor(red: 221.0/255.0, green: 222.0/255.0, blue: 225.0/255.0, alpha: 1.0).cgColor
        }
    }

    private func setupConstraint() {
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }

    func configure(_ model: FilterDetailTagModel) {
        self.tagLabel.text = model.title
    }
}
