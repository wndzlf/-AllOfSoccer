//
//  GameMatchingDetailViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/15.
//

import UIKit

class GameMatchingDetailViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Date and Location Section
    private let dateLabel = UILabel()
    private let locationLabel = UILabel()
    private let mapPinImageView = UIImageView()
    private let addressLabel = UILabel()
    private let separatorView = UIView()
    private let copyAddressButton = UIButton(type: .system)
    
    // MARK: - Fee Section
    private let feeIconImageView = UIImageView()
    private let feeTitleLabel = UILabel()
    private let feeAmountLabel = UILabel()
    
    // MARK: - Game Format Section
    private let formatIconImageView = UIImageView()
    private let formatTitleLabel = UILabel()
    private let formatStackView = UIStackView()
    
    // MARK: - Team Info Section
    private let teamIconImageView = UIImageView()
    private let teamTitleLabel = UILabel()
    private let ageLabel = UILabel()
    private let ageValueLabel = UILabel()
    private let skillLabel = UILabel()
    private let skillValueLabel = UILabel()
    private let uniformLabel = UILabel()
    private let contactLabel = UILabel()
    private let contactValueLabel = UILabel()
    
    // MARK: - Uniform Stack Views
    private let topUniformStackView = UIStackView()
    private let bottomUniformStackView = UIStackView()
    
    // MARK: - Note Section
    private let noteArrowImageView = UIImageView()
    private let noteContainerView = RoundView()
    private let noteLabel = UILabel()
    
    // MARK: - Action Button
    private let messageButton = UIButton(type: .system)
    
    // MARK: - Navigation Bar Items
    private lazy var likeBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "HeartDeSeleded"), style: .plain, target: self, action: #selector(likeBarbuttonTouchUp(_:)))
        button.tintColor = .clear
        return button
    }()
    
    private lazy var shareBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "ShareNetwork"), style: .plain, target: self, action: #selector(shareBarButtonTouchup(_:)))
        button.tintColor = .black
        return button
    }()
    
    // MARK: - Data
    private var viewModel: [String] = []
    
    // MARK: - Layout Constants
    private enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let verticalSpacing: CGFloat = 5
        static let sectionSpacing: CGFloat = 16
        static let largeSpacing: CGFloat = 24
        static let extraLargeSpacing: CGFloat = 62
        
        static let iconSize: CGFloat = 16
        static let smallIconSize: CGFloat = 14
        static let mediumIconSize: CGFloat = 18
        static let largeIconSize: CGFloat = 20
        
        static let formatIconSize: CGFloat = 90
        static let formatIconHeight: CGFloat = 65
        
        static let buttonHeight: CGFloat = 62
        static let noteContainerHeight: CGFloat = 86.5
        static let noteContainerCornerRadius: CGFloat = 4
    }
    
    // MARK: - Colors
    private enum Colors {
        static let primaryGreen = UIColor(red: 0.302, green: 0.663, blue: 0.204, alpha: 1.0)
        static let grayText = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        static let lightGrayText = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        static let separatorColor = UIColor(red: 0.933, green: 0.937, blue: 0.945, alpha: 1.0)
        static let noteBackground = UIColor(red: 0.965, green: 0.969, blue: 0.980, alpha: 1.0)
        static let messageButtonColor = UIColor(red: 0.925, green: 0.373, blue: 0.373, alpha: 1.0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupUI()
        configureData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutUI()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationItem() {
        self.navigationItem.title = "팀 모집"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.rightBarButtonItems = [self.likeBarButton, self.shareBarButton]
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        setupScrollView()
        setupDateAndLocationSection()
        setupFeeSection()
        setupGameFormatSection()
        setupTeamInfoSection()
        setupNoteSection()
        setupMessageButton()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .white
    }
    
    private func setupDateAndLocationSection() {
        // Date Label
        dateLabel.text = "2021-06-26 (토) 10:00"
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        dateLabel.textColor = .black
        
        // Location Label
        locationLabel.text = "용산 아이파크몰"
        locationLabel.font = UIFont.systemFont(ofSize: 20)
        locationLabel.textColor = .black
        
        // Map Pin Icon
        mapPinImageView.image = UIImage(named: "MapPin")
        mapPinImageView.tintColor = Colors.grayText
        mapPinImageView.contentMode = .scaleAspectFit
        
        // Address Label
        addressLabel.text = "서울시 용산구 한강대로23길 55"
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = Colors.lightGrayText
        
        // Separator
        separatorView.backgroundColor = Colors.separatorColor
        
        // Copy Address Button
        copyAddressButton.setTitle("주소 복사", for: .normal)
        copyAddressButton.setTitleColor(Colors.primaryGreen, for: .normal)
        copyAddressButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(mapPinImageView)
        contentView.addSubview(addressLabel)
        contentView.addSubview(separatorView)
        contentView.addSubview(copyAddressButton)
    }
    
    private func setupFeeSection() {
        // Fee Icon
        feeIconImageView.image = UIImage(named: "wonmoney")
        feeIconImageView.contentMode = .scaleAspectFit
        
        // Fee Title
        feeTitleLabel.text = "참가비"
        feeTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        feeTitleLabel.textColor = .black
        
        // Fee Amount
        feeAmountLabel.text = "9,000원"
        feeAmountLabel.font = UIFont.boldSystemFont(ofSize: 20)
        feeAmountLabel.textColor = Colors.primaryGreen
        
        contentView.addSubview(feeIconImageView)
        contentView.addSubview(feeTitleLabel)
        contentView.addSubview(feeAmountLabel)
    }
    
    private func setupGameFormatSection() {
        // Format Icon
        formatIconImageView.image = UIImage(named: "football-soccer-equipment")
        formatIconImageView.contentMode = .scaleAspectFit
        
        // Format Title
        formatTitleLabel.text = "진행 방식"
        formatTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        formatTitleLabel.textColor = .black
        
        // Format Stack View
        formatStackView.axis = .horizontal
        formatStackView.distribution = .fillEqually
        formatStackView.spacing = 16
        
        // Create format items
        let formatItems = [
            ("6 vs 6", ""),
            ("남성 매치", ""),
            ("풋살화", "")
        ]
        
        for (title, _) in formatItems {
            let itemStackView = UIStackView()
            itemStackView.axis = .vertical
            itemStackView.alignment = .center
            itemStackView.spacing = 5
            
            let iconImageView = UIImageView()
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.frame = CGRect(x: 0, y: 0, width: Layout.formatIconSize, height: Layout.formatIconHeight)
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            titleLabel.textColor = .black
            titleLabel.textAlignment = .center
            
            itemStackView.addArrangedSubview(iconImageView)
            itemStackView.addArrangedSubview(titleLabel)
            
            formatStackView.addArrangedSubview(itemStackView)
        }
        
        contentView.addSubview(formatIconImageView)
        contentView.addSubview(formatTitleLabel)
        contentView.addSubview(formatStackView)
    }
    
    private func setupTeamInfoSection() {
        // Team Icon
        teamIconImageView.image = UIImage(named: "cloth")
        teamIconImageView.contentMode = .scaleAspectFit
        
        // Team Title
        teamTitleLabel.text = "모두의 축구"
        teamTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        teamTitleLabel.textColor = .black
        
        // Age Label
        ageLabel.text = "나이대"
        ageLabel.font = UIFont.systemFont(ofSize: 16)
        ageLabel.textColor = Colors.grayText
        
        // Age Value Label
        ageValueLabel.text = "20대 후반 - 30대 초반"
        ageValueLabel.font = UIFont.systemFont(ofSize: 16)
        ageValueLabel.textColor = .black
        
        // Skill Label
        skillLabel.text = "실력"
        skillLabel.font = UIFont.systemFont(ofSize: 16)
        skillLabel.textColor = Colors.grayText
        
        // Skill Value Label
        skillValueLabel.text = "중하"
        skillValueLabel.font = UIFont.systemFont(ofSize: 16)
        skillValueLabel.textColor = .black
        
        // Uniform Label
        uniformLabel.text = "유니폼"
        uniformLabel.font = UIFont.systemFont(ofSize: 16)
        uniformLabel.textColor = Colors.grayText
        
        // Top Uniform Stack
        topUniformStackView.axis = .horizontal
        topUniformStackView.spacing = 6
        
        let topLabel = UILabel()
        topLabel.text = "상의"
        topLabel.font = UIFont.systemFont(ofSize: 16)
        topLabel.textColor = .black
        
        let topIconStack = UIStackView()
        topIconStack.axis = .horizontal
        topIconStack.distribution = .fillEqually
        topIconStack.spacing = 2
        
        let topIcon1 = UIImageView()
        topIcon1.contentMode = .scaleAspectFit
        topIcon1.frame = CGRect(x: 0, y: 0, width: Layout.iconSize, height: Layout.iconSize)
        
        let topIcon2 = UIImageView()
        topIcon2.contentMode = .scaleAspectFit
        topIcon2.frame = CGRect(x: 0, y: 0, width: Layout.iconSize, height: Layout.iconSize)
        
        topIconStack.addArrangedSubview(topIcon1)
        topIconStack.addArrangedSubview(topIcon2)
        
        topUniformStackView.addArrangedSubview(topLabel)
        topUniformStackView.addArrangedSubview(topIconStack)
        
        // Bottom Uniform Stack
        bottomUniformStackView.axis = .horizontal
        bottomUniformStackView.spacing = 6
        
        let bottomLabel = UILabel()
        bottomLabel.text = "하의"
        bottomLabel.font = UIFont.systemFont(ofSize: 16)
        bottomLabel.textColor = .black
        
        let bottomIcon = UIImageView()
        bottomIcon.contentMode = .scaleAspectFit
        bottomIcon.frame = CGRect(x: 0, y: 0, width: Layout.iconSize, height: Layout.iconSize)
        
        bottomUniformStackView.addArrangedSubview(bottomLabel)
        bottomUniformStackView.addArrangedSubview(bottomIcon)
        
        // Contact Label
        contactLabel.text = "연락처"
        contactLabel.font = UIFont.systemFont(ofSize: 16)
        contactLabel.textColor = Colors.grayText
        
        // Contact Value Label
        contactValueLabel.text = "010-1234-1234"
        contactValueLabel.font = UIFont.systemFont(ofSize: 16)
        contactValueLabel.textColor = .black
        
        contentView.addSubview(teamIconImageView)
        contentView.addSubview(teamTitleLabel)
        contentView.addSubview(ageLabel)
        contentView.addSubview(ageValueLabel)
        contentView.addSubview(skillLabel)
        contentView.addSubview(skillValueLabel)
        contentView.addSubview(uniformLabel)
        contentView.addSubview(topUniformStackView)
        contentView.addSubview(bottomUniformStackView)
        contentView.addSubview(contactLabel)
        contentView.addSubview(contactValueLabel)
    }
    
    private func setupNoteSection() {
        // Note Arrow
        noteArrowImageView.image = UIImage(named: "Polygon")
        noteArrowImageView.contentMode = .scaleAspectFit
        
        // Note Container
        noteContainerView.backgroundColor = Colors.noteBackground
        noteContainerView.cornerRadius = Layout.noteContainerCornerRadius
        noteContainerView.borderWidth = 0
        
        // Note Label
        noteLabel.text = "혼자 또는 친구들 하고 오세요!ㅣㅏㅟㅏㄴㅁ위ㅏㅁㄴ우이ㅏㅁ눙ㅁ니ㅏㅜ미ㅏ우미ㅏ"
        noteLabel.font = UIFont.systemFont(ofSize: 14)
        noteLabel.textColor = .black
        noteLabel.numberOfLines = 0
        
        noteContainerView.addSubview(noteLabel)
        contentView.addSubview(noteArrowImageView)
        contentView.addSubview(noteContainerView)
    }
    
    private func setupMessageButton() {
        messageButton.setTitle("메세지 보내기", for: .normal)
        messageButton.setTitleColor(.white, for: .normal)
        messageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        messageButton.backgroundColor = Colors.messageButtonColor
        
        contentView.addSubview(messageButton)
    }
    
    private func layoutUI() {
        let screenWidth = view.frame.width
        let navigationBarHeight: CGFloat = 44 // 네비게이션 바 높이
        let statusBarHeight: CGFloat = 44 // 상태바 높이 (iPhone 14+ 기준)
        let topOffset = navigationBarHeight + statusBarHeight + 10 // 네비게이션 바 아래 여백
        var currentY: CGFloat = topOffset
        
        // Scroll View - 네비게이션 바 아래부터 시작
        scrollView.frame = CGRect(x: 0, y: topOffset, width: screenWidth, height: view.frame.height - topOffset)
        
        // 1. Date Label
        dateLabel.frame = CGRect(x: Layout.horizontalPadding, y: currentY, width: screenWidth - 32, height: 24)
        currentY += dateLabel.frame.height + 10
        
        // 2. Location Label
        locationLabel.frame = CGRect(x: Layout.horizontalPadding, y: currentY, width: screenWidth - 32, height: 24)
        currentY += locationLabel.frame.height + 8
        
        // 3. Map Pin Icon & Address
        mapPinImageView.frame = CGRect(x: Layout.horizontalPadding, y: currentY, width: Layout.mediumIconSize, height: Layout.mediumIconSize)
        addressLabel.frame = CGRect(x: mapPinImageView.frame.maxX + 4, y: currentY + 0.5, width: 179, height: 17)
        separatorView.frame = CGRect(x: addressLabel.frame.maxX + 10, y: currentY + 2, width: 1, height: 14)
        copyAddressButton.frame = CGRect(x: separatorView.frame.maxX + 10, y: currentY - 5.5, width: 53, height: 29)
        currentY += mapPinImageView.frame.height + 20
        
        // 4. Fee Section
        feeIconImageView.frame = CGRect(x: Layout.horizontalPadding + 1, y: currentY, width: Layout.iconSize, height: Layout.iconSize)
        feeTitleLabel.frame = CGRect(x: feeIconImageView.frame.maxX + 9, y: currentY - 0.5, width: 44.5, height: 20.5)
        currentY += feeTitleLabel.frame.height + 16
        feeAmountLabel.frame = CGRect(x: feeTitleLabel.frame.minX, y: currentY, width: 74.5, height: 24)
        currentY += feeAmountLabel.frame.height + 30
        
        // 5. Format Section
        formatIconImageView.frame = CGRect(x: Layout.horizontalPadding + 1, y: currentY, width: Layout.smallIconSize, height: Layout.smallIconSize)
        formatTitleLabel.frame = CGRect(x: formatIconImageView.frame.maxX + 9, y: currentY - 3, width: 63, height: 20.5)
        currentY += formatTitleLabel.frame.height + 20
        formatStackView.frame = CGRect(x: (screenWidth - 302) / 2, y: currentY, width: 302, height: 89.5)
        currentY += formatStackView.frame.height + 30
        
        // 6. Team Info Section
        teamIconImageView.frame = CGRect(x: Layout.horizontalPadding + 1, y: currentY, width: Layout.iconSize, height: Layout.smallIconSize)
        teamTitleLabel.frame = CGRect(x: teamIconImageView.frame.maxX + 9, y: currentY - 3.5, width: 77.5, height: 20.5)
        currentY += teamTitleLabel.frame.height + 20
        
        // 6-1. Age
        ageLabel.frame = CGRect(x: 40, y: currentY, width: 42, height: 19.5)
        ageValueLabel.frame = CGRect(x: ageLabel.frame.maxX + 34, y: currentY, width: 146, height: 19.5)
        currentY += ageLabel.frame.height + 15
        
        // 6-2. Skill
        skillLabel.frame = CGRect(x: 40, y: currentY, width: 28, height: 19.5)
        skillValueLabel.frame = CGRect(x: ageValueLabel.frame.minX, y: currentY, width: 28, height: 19.5)
        currentY += skillLabel.frame.height + 15
        
        // 6-3. Uniform
        uniformLabel.frame = CGRect(x: 40, y: currentY, width: 42, height: 19.5)
        topUniformStackView.frame = CGRect(x: skillValueLabel.frame.minX, y: currentY, width: 68, height: 16)
        bottomUniformStackView.frame = CGRect(x: topUniformStackView.frame.maxX + 10, y: currentY, width: 50, height: 16)
        currentY += uniformLabel.frame.height + 15
        
        // 6-4. Contact
        contactLabel.frame = CGRect(x: 40, y: currentY, width: 42, height: 19.5)
        contactValueLabel.frame = CGRect(x: ageValueLabel.frame.minX, y: currentY, width: 113.5, height: 19.5)
        currentY += contactLabel.frame.height + 25
        
        // 7. Note Section
        noteArrowImageView.frame = CGRect(x: 41, y: currentY - 10, width: Layout.largeIconSize, height: Layout.largeIconSize)
        noteContainerView.frame = CGRect(x: 42, y: currentY, width: screenWidth - 85, height: Layout.noteContainerHeight)
        noteLabel.frame = CGRect(x: 25, y: 18, width: noteContainerView.frame.width - 50, height: 50.5)
        currentY += noteContainerView.frame.height + 25
        
        // 8. Message Button
        messageButton.frame = CGRect(x: 0, y: currentY, width: screenWidth, height: Layout.buttonHeight)
        
        // Content View - 콘텐츠 크기에 맞게 동적 설정
        let contentHeight = messageButton.frame.maxY + 50 // 하단 여백 추가
        contentView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: contentHeight)
        
        // ScrollView contentSize 동적 설정
        scrollView.contentSize = CGSize(width: screenWidth, height: contentHeight)
        
        // 디버그용 로그
        print("Screen Width: \(screenWidth)")
        print("Content Height: \(contentHeight)")
        print("ScrollView Content Size: \(scrollView.contentSize)")
        print("ScrollView Frame: \(scrollView.frame)")
    }
    
    private func configureData() {
        // Configure any additional data or styling here
    }
    
    // MARK: - Actions
    @objc private func likeBarbuttonTouchUp(_ sender: UIControl) {
        print("likeBarButton이 찍혔습니다.")
        
        sender.isSelected.toggle()
        if sender.isSelected {
            self.likeBarButton.image = UIImage(named: "HeartSelected")
        } else {
            self.likeBarButton.image = UIImage(named: "HeartDeSeleded")
        }
    }
    
    @objc private func shareBarButtonTouchup(_ sender: UIBarButtonItem) {
        print("shareBarButton이 찍혔습니다.")
        
        for testString in 0...3 {
            self.viewModel.append(String(testString))
        }
        
        let activityViewController = UIActivityViewController(activityItems: self.viewModel, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
