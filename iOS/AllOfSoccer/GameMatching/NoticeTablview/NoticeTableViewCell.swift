//
//  NoticeTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/03.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {

    // MARK: - UI Components
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0) // #666666
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let placeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    private let contentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0) // #666666
        label.numberOfLines = 0
        return label
    }()
    
    private let teamNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0) // #999999
        return label
    }()
    
    private let checkbutton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .black // Default tint
        return button
    }()
    
    private let recruitmentStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 77/255, green: 152/255, blue: 52/255, alpha: 1.0) // Green
        return label
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        self.selectionStyle = .none
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(placeLabel)
        self.contentView.addSubview(contentsLabel)
        self.contentView.addSubview(teamNameLabel)
        self.contentView.addSubview(checkbutton)
        self.contentView.addSubview(recruitmentStatusLabel)
        
        checkbutton.addTarget(self, action: #selector(checkButtonDidSelected), for: .touchUpInside)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Fixed positions based on Storyboard analysis (approximate for 414 width, but adapted)
        // Date Label: x=38, y=48
        dateLabel.frame = CGRect(x: 38, y: 48, width: 60, height: 17)
        dateLabel.sizeToFit()
        dateLabel.frame.origin = CGPoint(x: 38, y: 48)
        
        // Time Label: CenterX with DateLabel, Top = DateLabel.bottom + 2
        timeLabel.sizeToFit()
        timeLabel.center.x = dateLabel.center.x
        timeLabel.frame.origin.y = dateLabel.frame.maxY + 2
        
        // Place Label: x=123, y=25
        placeLabel.frame = CGRect(x: 123, y: 25, width: contentView.frame.width - 123 - 50, height: 22)
        
        // Check Button: Right aligned with padding
        let buttonSize: CGFloat = 22
        checkbutton.frame = CGRect(x: contentView.frame.width - 16 - buttonSize, y: 25, width: buttonSize, height: buttonSize)
        
        // Contents Label: x=123, y=48.5, Width=205
        contentsLabel.frame = CGRect(x: 123, y: 48.5, width: 205, height: 40)
        contentsLabel.sizeToFit()
        // Limit width if sizeToFit expands it too much
        if contentsLabel.frame.width > 205 {
            contentsLabel.frame.size.width = 205
            contentsLabel.sizeToFit() // Adjust height for wrapped text
        }
        contentsLabel.frame.origin = CGPoint(x: 123, y: 48.5)
        
        // Team Name Label: x=123, Top = ContentsLabel.bottom + 4
        teamNameLabel.sizeToFit()
        teamNameLabel.frame.origin = CGPoint(x: 123, y: contentsLabel.frame.maxY + 4)
        
        // Recruitment Status Label: Bottom Right
        recruitmentStatusLabel.sizeToFit()
        recruitmentStatusLabel.frame.origin.x = contentView.frame.width - 16 - recruitmentStatusLabel.frame.width
        recruitmentStatusLabel.frame.origin.y = contentView.frame.height - 18 - recruitmentStatusLabel.frame.height
    }

    // MARK: - Update
    internal func update(viewModel: GameMatchListViewModel) {
        self.dateLabel.text = viewModel.date
        self.timeLabel.text = viewModel.time
        self.placeLabel.text = viewModel.address
        self.contentsLabel.text = viewModel.description
        self.teamNameLabel.text = viewModel.teamName
        self.checkbutton.isSelected = viewModel.isFavorite
        
        if viewModel.isRecruiting {
            self.recruitmentStatusLabel.text = "모집중"
            self.recruitmentStatusLabel.textColor = UIColor(red: 77/255, green: 152/255, blue: 52/255, alpha: 1.0) // Green
        } else {
            self.recruitmentStatusLabel.text = "마감"
            self.recruitmentStatusLabel.textColor = .gray
        }
        
        // Update tint color based on selection
        let didSelectedColor = UIColor(red: 236.0/255.0, green: 95.0/255.0, blue: 95.0/255.0, alpha: 1)
        let didDeSelectedColor = UIColor.black
        checkbutton.tintColor = checkbutton.isSelected ? didSelectedColor : didDeSelectedColor
        
        self.setNeedsLayout()
    }

    @objc private func checkButtonDidSelected(sender: UIButton) {
        sender.isSelected.toggle()
        let didSelectedColor = UIColor(red: 236.0/255.0, green: 95.0/255.0, blue: 95.0/255.0, alpha: 1)
        let didDeSelectedColor = UIColor.black
        sender.tintColor = sender.isSelected ? didSelectedColor : didDeSelectedColor
        
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
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
