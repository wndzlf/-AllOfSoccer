//
//  IntroductionDetailTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/07.
//

import UIKit

class CallPreviusMatchingInformationTableViewCell: UITableViewCell {

    private var favoriteButton: SeletableButton = {
        let button = SeletableButton()
        button.setTitle(SortMode.distance.sortModeTitle, for: .normal)
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

    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "6vs6 / 남성매치 / 7000원"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black

        return label
    }()

    private var addressLabel: UILabel = {
        let label = UILabel()
        label.text = "8월 27일 용산 아이파크몰"
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

    internal func update(viewModel: GameMatchListViewModel) {
        self.addressLabel.text = viewModel.address
        self.descriptionLabel.text = viewModel.description
        self.favoriteButton.isSelected = viewModel.isFavorite
    }

    private func setConstraints() {
        self.debugBorder()
        self.backgroundColor = .blue

        self.contentView.addsubviews(favoriteButton, descriptionLabel, addressLabel)
        NSLayoutConstraint.activate([
            self.favoriteButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.favoriteButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),

            self.descriptionLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.favoriteButton.trailingAnchor, constant: 8),

            self.addressLabel.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 5),
            self.addressLabel.leadingAnchor.constraint(equalTo: self.favoriteButton.trailingAnchor, constant: 8),
            self.addressLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5)
        ])
    }

    @objc func checkButtonTouchUp(_ sender: SeletableButton) {
        sender.isSelected = sender.isSelected ? false : true

    }
}
