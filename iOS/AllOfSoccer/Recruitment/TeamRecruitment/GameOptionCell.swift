//
//  GameOptionCell.swift
//  AllOfSoccer
//
//  Created by USER on 8/24/25.
//

import UIKit

// MARK: - GameOptionCell
class GameOptionCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height: CGFloat = 40
        let cellPadding: CGFloat = 24 // Cell 내부 좌우 여백을 늘려서 더 예쁘게

//        let option = gameOptions[indexPath.item]
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let textSize = (titleLabel.text ?? "").size(withAttributes: [.font: font])
        let width = textSize.width + (cellPadding * 2)

        return CGSize(width: width, height: height)
    }

    private func setupUI() {
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        updateAppearance(isSelected: false)
    }

    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        updateAppearance(isSelected: isSelected)
    }

    private func updateAppearance(isSelected: Bool) {
        if isSelected {
            contentView.backgroundColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
            titleLabel.textColor = .white
            contentView.layer.borderColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0).cgColor
        } else {
            contentView.backgroundColor = .white
            titleLabel.textColor = UIColor(red: 0.615, green: 0.623, blue: 0.627, alpha: 1.0)
            contentView.layer.borderColor = UIColor(red: 0.866, green: 0.870, blue: 0.882, alpha: 1.0).cgColor
        }

        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1.5
    }
}
