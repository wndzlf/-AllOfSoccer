//
//  GameMatchingDetailViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/15.
//

import UIKit
import MessageUI

class GameMatchingDetailViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
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
    private let viewModel: GameMatchingDetailViewModel

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
        
        // 진행방식 아이콘 크기 조정
        static let formatIconSize: CGFloat = 60
        static let formatIconHeight: CGFloat = 45
        
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

    init(viewModel: GameMatchingDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        // 하단 버튼이 잘리지 않도록 contentInset 설정
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Layout.buttonHeight, right: 0)
    }
    
    private func setupDateAndLocationSection() {
        // Date Label
        dateLabel.text = viewModel.data.date
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        dateLabel.textColor = .black
        
        // Location Label
        locationLabel.text = viewModel.data.location
        locationLabel.font = UIFont.systemFont(ofSize: 20)
        locationLabel.textColor = .black
        
        // Map Pin Icon
        mapPinImageView.image = UIImage(named: "MapPin")
        mapPinImageView.tintColor = Colors.grayText
        mapPinImageView.contentMode = .scaleAspectFit
        
        // Address Label
        addressLabel.text = viewModel.data.address
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = Colors.lightGrayText
        
        // Separator
        separatorView.backgroundColor = Colors.separatorColor
        
        // Copy Address Button
        copyAddressButton.setTitle("주소 복사", for: .normal)
        copyAddressButton.setTitleColor(Colors.primaryGreen, for: .normal)
        copyAddressButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        copyAddressButton.addTarget(self, action: #selector(copyAddressButtonTapped), for: .touchUpInside)
        
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
        feeAmountLabel.text = viewModel.data.feeAmount
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
        formatStackView.spacing = 8
        
        // Create format items from ViewModel
        for formatItem in viewModel.data.formatItems {
            let itemStackView = UIStackView()
            itemStackView.axis = .vertical
            itemStackView.alignment = .center
            itemStackView.spacing = 8
            
            let iconImageView = UIImageView()
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.frame = CGRect(x: 0, y: 0, width: Layout.formatIconSize, height: Layout.formatIconHeight)
            
            // Set SF Symbol icon
            if !formatItem.iconName.isEmpty {
                iconImageView.image = UIImage(systemName: formatItem.iconName)
                iconImageView.tintColor = Colors.primaryGreen
            }
            
            let titleLabel = UILabel()
            titleLabel.text = formatItem.title
            titleLabel.font = UIFont.systemFont(ofSize: 14)
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
        teamTitleLabel.text = viewModel.data.teamName
        teamTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        teamTitleLabel.textColor = .black
        
        // Age Label
        ageLabel.text = "나이대"
        ageLabel.font = UIFont.systemFont(ofSize: 16)
        ageLabel.textColor = Colors.grayText
        
        // Age Value Label
        ageValueLabel.text = viewModel.data.ageRange
        ageValueLabel.font = UIFont.systemFont(ofSize: 16)
        ageValueLabel.textColor = .black
        
        // Skill Label
        skillLabel.text = "실력"
        skillLabel.font = UIFont.systemFont(ofSize: 16)
        skillLabel.textColor = Colors.grayText
        
        // Skill Value Label
        skillValueLabel.text = viewModel.data.skillLevel
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
        
        // Create top uniform icons from ViewModel data
        for uniformItem in viewModel.data.uniformInfo.topUniform {
            let topIcon = UIImageView()
            topIcon.contentMode = .scaleAspectFit
            topIcon.frame = CGRect(x: 0, y: 0, width: Layout.iconSize, height: Layout.iconSize)
            topIcon.image = UIImage(systemName: uniformItem.iconName)
            topIcon.tintColor = uniformItem.color
            topIconStack.addArrangedSubview(topIcon)
        }
        
        topUniformStackView.addArrangedSubview(topLabel)
        topUniformStackView.addArrangedSubview(topIconStack)
        
        // Contact Label
        contactLabel.text = "연락처"
        contactLabel.font = UIFont.systemFont(ofSize: 16)
        contactLabel.textColor = Colors.grayText
        
        // Contact Value Label
        contactValueLabel.text = viewModel.data.contactNumber
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
        noteLabel.text = viewModel.data.noteText
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
        messageButton.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(messageButton)
    }
    
    private func layoutUI() {
        let screenWidth = view.frame.width
        let navigationBarHeight: CGFloat = 44 // 네비게이션 바 높이
        let statusBarHeight: CGFloat = 44 // 상태바 높이 (iPhone 14+ 기준)
        let topOffset = navigationBarHeight + statusBarHeight + 5 // 네비게이션 바 아래 여백 줄임
        var currentY: CGFloat = 15.0

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
        addressLabel.frame = CGRect(x: mapPinImageView.frame.maxX + 4, y: currentY + 0.5, width: screenWidth - mapPinImageView.frame.maxX - 120, height: 17)
        separatorView.frame = CGRect(x: addressLabel.frame.maxX + 10, y: currentY + 2, width: 1, height: 14)
        copyAddressButton.frame = CGRect(x: separatorView.frame.maxX + 10, y: currentY - 5.5, width: 53, height: 29)
        currentY += mapPinImageView.frame.height + 20
        
        // 4. Fee Section
        feeIconImageView.frame = CGRect(x: Layout.horizontalPadding + 1, y: currentY, width: Layout.iconSize, height: Layout.iconSize)
        feeTitleLabel.frame = CGRect(x: feeIconImageView.frame.maxX + 9, y: currentY - 0.5, width: 44.5, height: 20.5)
        currentY += feeTitleLabel.frame.height + 12
        feeAmountLabel.frame = CGRect(x: feeTitleLabel.frame.minX, y: currentY, width: 74.5, height: 24)
        currentY += feeAmountLabel.frame.height + 25
        
        // 5. Format Section
        formatIconImageView.frame = CGRect(x: Layout.horizontalPadding + 1, y: currentY, width: Layout.smallIconSize, height: Layout.smallIconSize)
        formatTitleLabel.frame = CGRect(x: formatIconImageView.frame.maxX + 9, y: currentY - 3, width: 63, height: 20.5)
        currentY += formatTitleLabel.frame.height + 20
        formatStackView.frame = CGRect(x: (screenWidth - 240) / 2, y: currentY, width: 240, height: 70)
        currentY += formatStackView.frame.height + 30
        
        // 6. Team Info Section
        teamIconImageView.frame = CGRect(x: Layout.horizontalPadding + 1, y: currentY, width: Layout.iconSize, height: Layout.smallIconSize)
        teamTitleLabel.frame = CGRect(x: teamIconImageView.frame.maxX + 9, y: currentY - 3.5, width: screenWidth - teamIconImageView.frame.maxX - 20, height: 20.5)
        teamTitleLabel.sizeToFit()
        currentY += teamTitleLabel.frame.height + 20
        
        // 6-1. Age
        ageLabel.frame = CGRect(x: 40, y: currentY, width: 42, height: 19.5)
        ageValueLabel.frame = CGRect(x: ageLabel.frame.maxX + 34, y: currentY, width: screenWidth - ageLabel.frame.maxX - 50, height: 19.5)
        currentY += ageLabel.frame.height + 12
        
        // 6-2. Skill
        skillLabel.frame = CGRect(x: 40, y: currentY, width: 28, height: 19.5)
        skillValueLabel.frame = CGRect(x: ageValueLabel.frame.minX, y: currentY, width: screenWidth - ageValueLabel.frame.minX - 20, height: 19.5)
        currentY += skillLabel.frame.height + 12
        
        // 6-3. Uniform
        uniformLabel.frame = CGRect(x: 40, y: currentY, width: 42, height: 19.5)
        topUniformStackView.frame = CGRect(x: skillValueLabel.frame.minX, y: currentY, width: 68, height: 16)
        currentY += uniformLabel.frame.height + 12
        
        // 6-4. Contact
        contactLabel.frame = CGRect(x: 40, y: currentY, width: 42, height: 19.5)
        contactValueLabel.frame = CGRect(x: ageValueLabel.frame.minX, y: currentY, width: screenWidth - ageValueLabel.frame.minX - 20, height: 19.5)
        currentY += contactLabel.frame.height + 20
        
        // 7. Note Section - 동적 높이 계산
        noteArrowImageView.frame = CGRect(x: 41, y: currentY - 10, width: Layout.largeIconSize, height: Layout.largeIconSize)
        
        // Note 텍스트의 실제 높이 계산
        let noteTextWidth = screenWidth - 85 - 50 // noteContainerView 너비 - 좌우 패딩
        let noteTextHeight = calculateTextHeight(text: viewModel.data.noteText, width: noteTextWidth, font: noteLabel.font)
        let noteContainerHeight = max(Layout.noteContainerHeight, noteTextHeight + 36) // 상하 패딩 18씩 추가
        
        noteContainerView.frame = CGRect(x: 42, y: currentY, width: screenWidth - 85, height: noteContainerHeight)
        noteLabel.frame = CGRect(x: 25, y: 18, width: noteTextWidth, height: noteTextHeight)
        currentY += noteContainerView.frame.height + 25
        
        // 8. Message Button
        messageButton.frame = CGRect(x: 0, y: currentY, width: screenWidth, height: Layout.buttonHeight)
        
        // Content View - 콘텐츠 크기에 맞게 동적 설정
        let contentHeight = messageButton.frame.maxY + 20 // 하단 여백 줄임
        contentView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: contentHeight)
        
        // ScrollView contentSize 동적 설정
        scrollView.contentSize = CGSize(width: screenWidth, height: contentHeight)
        
        // 디버그용 로그
        print("Screen Width: \(screenWidth)")
        print("Content Height: \(contentHeight)")
        print("ScrollView Content Size: \(scrollView.contentSize)")
        print("ScrollView Frame: \(scrollView.frame)")
    }
    
    // MARK: - Helper Methods
    private func calculateTextHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
    
    private func configureData() {
        // ViewModel에서 데이터를 가져와서 UI를 업데이트
        // 현재는 setupUI() 메서드에서 이미 ViewModel 데이터를 사용하고 있음
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
        
        // Clear previous share items
        viewModel.clearShareItems()
        
        // Add current data to share items
        for testString in 0...3 {
            viewModel.addShareItem(String(testString))
        }
        
        let activityViewController = UIActivityViewController(activityItems: viewModel.getShareItems(), applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Message Actions
    @objc private func messageButtonTapped() {
        print("메세지 보내기 버튼이 탭되었습니다.")
        
        // 연락처 번호에서 하이픈 제거
        let phoneNumber = viewModel.data.contactNumber.replacingOccurrences(of: "-", with: "")
        
        // SMS 기능이 사용 가능한지 확인
        if MFMessageComposeViewController.canSendText() {
            let messageComposer = MFMessageComposeViewController()
            messageComposer.messageComposeDelegate = self
            messageComposer.recipients = [phoneNumber]
            messageComposer.body = "안녕하세요! \(viewModel.data.teamName) 팀 모집 글을 보고 연락드립니다."
            
            self.present(messageComposer, animated: true, completion: nil)
        } else {
            // SMS 기능이 사용 불가능한 경우 (시뮬레이터 등)
            showSMSNotAvailableAlert()
        }
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            switch result {
            case .cancelled:
                print("메시지 작성이 취소되었습니다.")
            case .failed:
                print("메시지 전송에 실패했습니다.")
                self.showMessageErrorAlert()
            case .sent:
                print("메시지가 성공적으로 전송되었습니다.")
                self.showMessageSuccessAlert()
            @unknown default:
                break
            }
        }
    }
    
    // MARK: - Alert Methods
    private func showSMSNotAvailableAlert() {
        let alert = UIAlertController(
            title: "SMS 사용 불가",
            message: "이 기기에서는 SMS를 보낼 수 없습니다. 실제 기기에서 시도해주세요.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showMessageErrorAlert() {
        let alert = UIAlertController(
            title: "메시지 전송 실패",
            message: "메시지 전송에 실패했습니다. 다시 시도해주세요.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showMessageSuccessAlert() {
        let alert = UIAlertController(
            title: "메시지 전송 완료",
            message: "메시지가 성공적으로 전송되었습니다.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Copy Address Action
    @objc private func copyAddressButtonTapped() {
        print("주소 복사 버튼이 탭되었습니다.")
        
        // 주소 텍스트를 클립보드에 복사
        UIPasteboard.general.string = viewModel.data.address
        
        // 복사 완료 피드백 제공
        showAddressCopiedAlert()
    }
    
    private func showAddressCopiedAlert() {
        let alert = UIAlertController(
            title: "주소 복사 완료",
            message: "주소가 클립보드에 복사되었습니다.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
