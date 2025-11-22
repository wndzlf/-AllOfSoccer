//
//  NoticeTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/03.
//

import UIKit

// MARK: - Match Status Type
enum MatchStatusType {
    case mercenaryRecruitment(count: Int)
    case teamMatched
    
    var text: String {
        switch self {
        case .mercenaryRecruitment(let count):
            return "용병 \(count)명 모집중"
        case .teamMatched:
            return "매칭 완료"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .mercenaryRecruitment:
            return UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1.0)
        case .teamMatched:
            return UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0)
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .mercenaryRecruitment:
            return UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 0.1)
        case .teamMatched:
            return UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 0.1)
        }
    }
}

class NoticeTableViewCell: UITableViewCell {

    // MARK: - UI Components
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.08
        return view
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let placeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    private let contentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        label.numberOfLines = 2
        return label
    }()
    
    private let teamNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        return label
    }()
    
    private let checkbutton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1.0)
        return button
    }()
    
    private let recruitmentStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        return label
    }()
    
    private let secondaryStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.isHidden = true
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
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(cardView)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(placeLabel)
        self.contentView.addSubview(contentsLabel)
        self.contentView.addSubview(teamNameLabel)
        contentView.addSubview(checkbutton)
        contentView.addSubview(recruitmentStatusLabel)
        contentView.addSubview(secondaryStatusLabel)
        
        checkbutton.addTarget(self, action: #selector(checkButtonDidSelected), for: .touchUpInside)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Card View Layout
        let cardMargin: CGFloat = 16
        let cardVerticalMargin: CGFloat = 8
        cardView.frame = CGRect(x: cardMargin,
                                y: cardVerticalMargin,
                                width: contentView.frame.width - (cardMargin * 2),
                                height: contentView.frame.height - (cardVerticalMargin * 2))
        
        // Shadow Path Optimization
        cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: cardView.layer.cornerRadius).cgPath
        
        // Layout Constants
        let leftPadding: CGFloat = cardMargin + 20 // Inside card
        let rightColumnX: CGFloat = cardMargin + 100 // Start of right column
        let rightPadding: CGFloat = cardMargin + 16
        let contentWidth = contentView.frame.width - rightColumnX - rightPadding
        
        // Date Label
        dateLabel.sizeToFit()
        dateLabel.frame.origin = CGPoint(x: leftPadding, y: cardVerticalMargin + 24)
        
        // Time Label
        timeLabel.sizeToFit()
        timeLabel.frame.origin = CGPoint(x: leftPadding, y: dateLabel.frame.maxY + 6)
        // Align centers of date and time
        if dateLabel.frame.width > timeLabel.frame.width {
            timeLabel.center.x = dateLabel.center.x
        } else {
            dateLabel.center.x = timeLabel.center.x
        }
        
        // Check Button (Top Right)
        let buttonSize: CGFloat = 24
        checkbutton.frame = CGRect(x: contentView.frame.width - rightPadding - buttonSize,
                                   y: cardVerticalMargin + 20,
                                   width: buttonSize,
                                   height: buttonSize)
        
        // Place Label
        placeLabel.frame = CGRect(x: rightColumnX,
                                  y: cardVerticalMargin + 20,
                                  width: contentWidth - buttonSize - 8,
                                  height: 22)
        
        // Contents Label
        contentsLabel.frame = CGRect(x: rightColumnX,
                                     y: placeLabel.frame.maxY + 8,
                                     width: contentWidth,
                                     height: 40)
        contentsLabel.sizeToFit()
        // Limit width
        if contentsLabel.frame.width > contentWidth {
            contentsLabel.frame.size.width = contentWidth
            contentsLabel.sizeToFit()
        }
        
        // Team Name Label
        teamNameLabel.sizeToFit()
        teamNameLabel.frame.origin = CGPoint(x: rightColumnX, y: contentsLabel.frame.maxY + 10)
        
        // Recruitment Status Labels (Below Team Name)
        // 텍스트 길이에 따라 너비 조정
        recruitmentStatusLabel.sizeToFit()
        let primaryWidth = recruitmentStatusLabel.frame.width + 16
        let statusHeight: CGFloat = 24
        let spacing: CGFloat = 6
        let statusY = teamNameLabel.frame.maxY + 8 // 팀 이름 아래 8pt 간격
        
        if !secondaryStatusLabel.isHidden {
            secondaryStatusLabel.sizeToFit()
            let secondaryWidth = secondaryStatusLabel.frame.width + 16
            
            // 두 개의 라벨을 나란히 배치 (팀 이름과 같은 X 시작 위치)
            recruitmentStatusLabel.frame = CGRect(
                x: rightColumnX,
                y: statusY,
                width: primaryWidth,
                height: statusHeight
            )
            
            secondaryStatusLabel.frame = CGRect(
                x: recruitmentStatusLabel.frame.maxX + spacing,
                y: statusY,
                width: secondaryWidth,
                height: statusHeight
            )
        } else {
            // 하나의 라벨만 표시 (팀 이름과 같은 X 시작 위치)
            recruitmentStatusLabel.frame = CGRect(
                x: rightColumnX,
                y: statusY,
                width: primaryWidth,
                height: statusHeight
            )
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let cardVerticalMargin: CGFloat = 12
        let rightColumnX: CGFloat = 100
        
        // 기본 컨텐츠 높이 계산
        var totalHeight: CGFloat = cardVerticalMargin // 상단 여백
        totalHeight += 20 // 날짜 라벨
        totalHeight += 8  // 간격
        totalHeight += 22 // 장소 라벨
        totalHeight += 8  // 간격
        
        // 내용 라벨 높이 (최대 2줄)
        contentsLabel.sizeToFit()
        let contentsHeight = min(contentsLabel.frame.height, 40)
        totalHeight += contentsHeight
        totalHeight += 10 // 간격
        
        // 팀 이름 라벨
        teamNameLabel.sizeToFit()
        totalHeight += teamNameLabel.frame.height
        totalHeight += 8  // 팀 이름과 상태 라벨 간격
        
        // 상태 라벨 높이
        totalHeight += 24 // 상태 라벨 높이
        totalHeight += cardVerticalMargin // 하단 여백
        
        return CGSize(width: size.width, height: totalHeight)
    }

    // MARK: - Update
    internal var didTapLikeButton: (() -> Void)?

    internal func update(viewModel: GameMatchListViewModel) {
        self.dateLabel.text = viewModel.date
        self.timeLabel.text = viewModel.time
        self.placeLabel.text = viewModel.address
        self.contentsLabel.text = viewModel.description
        self.teamNameLabel.text = viewModel.teamName
        self.checkbutton.isSelected = viewModel.isFavorite
        
        // 상태 라벨 업데이트
        if let primaryStatus = viewModel.primaryStatus {
            self.recruitmentStatusLabel.text = primaryStatus.text
            self.recruitmentStatusLabel.textColor = primaryStatus.textColor
            self.recruitmentStatusLabel.backgroundColor = primaryStatus.backgroundColor
            
            if let secondaryStatus = viewModel.secondaryStatus {
                self.secondaryStatusLabel.text = secondaryStatus.text
                self.secondaryStatusLabel.textColor = secondaryStatus.textColor
                self.secondaryStatusLabel.backgroundColor = secondaryStatus.backgroundColor
                self.secondaryStatusLabel.isHidden = false
            } else {
                self.secondaryStatusLabel.isHidden = true
            }
        } else {
            // 상태가 없으면 숨김
            self.recruitmentStatusLabel.isHidden = true
            self.secondaryStatusLabel.isHidden = true
        }
        
        self.setNeedsLayout()
    }

    @objc private func checkButtonDidSelected(sender: UIButton) {
        // UI 업데이트는 ViewModel의 응답에 따라 처리되거나, 낙관적 업데이트를 할 수 있음
        // 여기서는 버튼 액션을 ViewController로 전달
        didTapLikeButton?()
        
        // Animation (피드백)
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
    internal let id: Int
    internal let date: String
    internal let time: String
    internal let address: String
    internal let description: String
    internal let isFavorite: Bool
    internal let isRecruiting: Bool
    internal let teamName: String
    internal let primaryStatus: MatchStatusType?
    internal let secondaryStatus: MatchStatusType?

    internal init(
        id: Int,
        date: String,
        time: String,
        address: String,
        description: String,
        isFavorite: Bool,
        isRecruiting: Bool,
        teamName: String,
        primaryStatus: MatchStatusType?,
        secondaryStatus: MatchStatusType?
    ) {
        self.id = id
        self.date = date
        self.time = time
        self.address = address
        self.description = description
        self.isFavorite = isFavorite
        self.isRecruiting = isRecruiting
        self.teamName = teamName
        self.primaryStatus = primaryStatus
        self.secondaryStatus = secondaryStatus
    }
}

// 목데이터는 GameMatchingViewModel에서 통합 관리하므로 제거
