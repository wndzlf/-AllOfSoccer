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
    private let addressIconLabel = UILabel() // Replaces mapPinImageView
    private let addressLabel = UILabel()
    private let separatorView = UIView()
    private let copyAddressButton = UIButton(type: .system)
    
    // MARK: - Fee Section
    // private let feeIconImageView = UIImageView() // Removed
    private let feeTitleLabel = UILabel()
    private let feeAmountLabel = UILabel()
    
    // MARK: - Game Format Section
    // private let formatIconImageView = UIImageView() // Removed
    private let formatTitleLabel = UILabel()
    private let formatStackView = UIStackView()
    
    // MARK: - Team Info Section
    // private let teamIconImageView = UIImageView() // Removed
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
        fetchLatestData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // NavigationBar가 완전히 레이아웃된 후에만 레이아웃 업데이트
        layoutUI()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationItem() {
        self.navigationItem.title = "경기 정보"
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
        scrollView.contentInsetAdjustmentBehavior = .automatic // NavigationBar 자동 고려
        scrollView.backgroundColor = .white
        
        // 하단 버튼이 잘리지 않도록 contentInset 설정
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Layout.buttonHeight, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    private func setupDateAndLocationSection() {
        // Date Label
        dateLabel.text = "📅 " + viewModel.data.date
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        dateLabel.textColor = .black
        
        // Location Label
        locationLabel.text = "📍 " + viewModel.data.location
        locationLabel.font = UIFont.systemFont(ofSize: 20)
        locationLabel.textColor = .black
        
        // Address Icon Label
        addressIconLabel.text = "🗺"
        addressIconLabel.font = UIFont.systemFont(ofSize: 16)
        addressIconLabel.textColor = .black
        
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
        contentView.addSubview(addressIconLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(separatorView)
        contentView.addSubview(copyAddressButton)
    }
    
    private func setupFeeSection() {
        // Fee Title
        feeTitleLabel.text = "💰 참가비"
        feeTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        feeTitleLabel.textColor = .black
        
        // Fee Amount
        feeAmountLabel.text = viewModel.data.feeAmount
        feeAmountLabel.font = UIFont.boldSystemFont(ofSize: 20)
        feeAmountLabel.textColor = Colors.primaryGreen
        
        // contentView.addSubview(feeIconImageView) // Removed
        contentView.addSubview(feeTitleLabel)
        contentView.addSubview(feeAmountLabel)
    }
    
    private func setupGameFormatSection() {
        // Format Title
        formatTitleLabel.text = "⚽️ 진행 방식"
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
        
        // contentView.addSubview(formatIconImageView) // Removed
        contentView.addSubview(formatTitleLabel)
        contentView.addSubview(formatStackView)
    }
    
    private func setupTeamInfoSection() {
        // Team Title
        teamTitleLabel.text = "👕 " + viewModel.data.teamName
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
        
        // contentView.addSubview(teamIconImageView) // Removed
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
        noteLabel.lineBreakMode = .byWordWrapping
        
        noteContainerView.addSubview(noteLabel)
        contentView.addSubview(noteArrowImageView)
        contentView.addSubview(noteContainerView)
    }
    
    private func setupMessageButton() {
        messageButton.setTitle("참가 신청하기", for: .normal)
        messageButton.setTitleColor(.white, for: .normal)
        messageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        messageButton.backgroundColor = Colors.messageButtonColor
        messageButton.addTarget(self, action: #selector(participationButtonTapped), for: .touchUpInside)

        contentView.addSubview(messageButton)
    }
    
    private func layoutUI() {
        let screenWidth = view.frame.width
        var currentY: CGFloat = 15.0

        // Scroll View - 전체 view에 맞추고, contentInsetAdjustmentBehavior가 자동으로 NavigationBar를 고려
        scrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: view.frame.height)
        
        // 1. Date Label
        dateLabel.frame = CGRect(x: Layout.horizontalPadding, y: currentY, width: screenWidth - 32, height: 24)
        currentY += dateLabel.frame.height + 10
        
        // 2. Location Label
        locationLabel.frame = CGRect(x: Layout.horizontalPadding, y: currentY, width: screenWidth - 32, height: 24)
        currentY += locationLabel.frame.height + 8
        
        // 3. Map Pin Icon & Address (Replaced with Address Icon Label)
        addressIconLabel.frame = CGRect(x: Layout.horizontalPadding, y: currentY, width: 20, height: 20)
        addressLabel.frame = CGRect(x: addressIconLabel.frame.maxX + 4, y: currentY + 1.5, width: screenWidth - addressIconLabel.frame.maxX - 120, height: 17)
        separatorView.frame = CGRect(x: addressLabel.frame.maxX + 10, y: currentY + 3, width: 1, height: 14)
        copyAddressButton.frame = CGRect(x: separatorView.frame.maxX + 10, y: currentY - 4.5, width: 53, height: 29)
        currentY += addressIconLabel.frame.height + 20
        
        // 4. Fee Section
        // feeIconImageView removed
        feeTitleLabel.frame = CGRect(x: Layout.horizontalPadding, y: currentY, width: 100, height: 20.5)

        currentY += feeTitleLabel.frame.height + 12
        feeAmountLabel.frame = CGRect(x: feeTitleLabel.frame.minX, y: currentY, width: self.view.bounds.width - 50.0, height: 24)
        currentY += feeAmountLabel.frame.height + 25
        
        // 5. Format Section
        // formatIconImageView removed
        formatTitleLabel.frame = CGRect(x: Layout.horizontalPadding, y: currentY - 3, width: 150, height: 20.5)
        currentY += formatTitleLabel.frame.height + 20
        formatStackView.frame = CGRect(x: (screenWidth - 240) / 2, y: currentY, width: 240, height: 70)
        currentY += formatStackView.frame.height + 30
        
        // 6. Team Info Section
        // teamIconImageView removed
        teamTitleLabel.frame = CGRect(x: Layout.horizontalPadding, y: currentY - 3.5, width: screenWidth - Layout.horizontalPadding - 20, height: 20.5)
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
        
        // sizeThatFits를 사용하여 더 정확한 높이 계산
        let size = noteLabel.sizeThatFits(CGSize(width: noteTextWidth, height: .greatestFiniteMagnitude))
        let noteTextHeight = ceil(size.height)
        
        let noteContainerHeight = max(Layout.noteContainerHeight, noteTextHeight + 40) // 상하 패딩 20씩 추가 (여유있게)
        
        noteContainerView.frame = CGRect(x: 42, y: currentY, width: screenWidth - 85, height: noteContainerHeight)
        noteLabel.frame = CGRect(x: 25, y: 20, width: noteTextWidth, height: noteTextHeight)
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
    
    private func fetchLatestData() {
        // 서버에서 최신 데이터 가져오기
        viewModel.fetchLatestData { [weak self] result in
            switch result {
            case .success():
                // UI 업데이트
                self?.configureData()
            case .failure(let error):
                print("매칭 상세 데이터 가져오기 실패: \(error)")
                // 기존 데이터로 UI 표시
                self?.configureData()
            }
        }
    }

    private func configureData() {
        // ViewModel에서 데이터를 가져와서 UI를 업데이트
        let data = viewModel.data

        dateLabel.text = data.date
        locationLabel.text = data.location
        addressLabel.text = data.address
        feeAmountLabel.text = data.feeAmount
        ageValueLabel.text = data.ageRange
        skillValueLabel.text = data.skillLevel
        contactValueLabel.text = data.contactNumber
        noteLabel.text = data.noteText

        // 경기 형식 아이템 업데이트
        formatStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in data.formatItems {
            let itemView = createFormatItemView(title: item.title, iconName: item.iconName)
            formatStackView.addArrangedSubview(itemView)
        }

        // 참가 신청 버튼 텍스트 업데이트
        updateParticipationButton()

        // 레이아웃 업데이트
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func updateParticipationButton() {
        // 참가자 수 확인
        let participants = viewModel.participants
        let isParticipating = participants.contains { $0.status == "confirmed" }

        if isParticipating {
            messageButton.setTitle("참가 취소하기", for: .normal)
            messageButton.backgroundColor = UIColor.systemGray
        } else {
            messageButton.setTitle("참가 신청하기", for: .normal)
            messageButton.backgroundColor = Colors.messageButtonColor
        }
    }

    private func createFormatItemView(title: String, iconName: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = Colors.primaryGreen
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.formatIconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.formatIconHeight),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
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
        
        let shareText = viewModel.getFormattedShareText()
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Participation Actions
    @objc private func participationButtonTapped() {
        guard let matchId = viewModel.getMatchId() else {
            showAlert(title: "오류", message: "매칭 정보를 찾을 수 없습니다.")
            return
        }

        // 현재 참가 중인지 확인
        let participants = viewModel.participants
        let isParticipating = participants.contains { $0.status == "confirmed" }

        if isParticipating {
            // 참가 취소
            cancelParticipation(matchId: matchId)
        } else {
            // 참가 신청
            applyForMatch(matchId: matchId)
        }
    }

    private func applyForMatch(matchId: String) {
        messageButton.isEnabled = false
        messageButton.setTitle("신청 중...", for: .normal)

        APIService.shared.applyForMatch(matchId: matchId) { [weak self] result in
            self?.messageButton.isEnabled = true

            switch result {
            case .success(let response):
                if response.success {
                    self?.showAlert(title: "성공", message: "참가 신청이 완료되었습니다.") {
                        self?.fetchLatestData()
                    }
                } else {
                    self?.showAlert(title: "실패", message: response.message ?? "참가 신청에 실패했습니다.")
                }
            case .failure(let error):
                self?.showAlert(title: "오류", message: "네트워크 오류: \(error.localizedDescription)")
            }
        }
    }

    private func cancelParticipation(matchId: String) {
        messageButton.isEnabled = false
        messageButton.setTitle("취소 중...", for: .normal)

        APIService.shared.cancelMatchApplication(matchId: matchId) { [weak self] result in
            self?.messageButton.isEnabled = true

            switch result {
            case .success(let response):
                if response.success {
                    self?.showAlert(title: "성공", message: "참가가 취소되었습니다.") {
                        self?.fetchLatestData()
                    }
                } else {
                    self?.showAlert(title: "실패", message: response.message ?? "참가 취소에 실패했습니다.")
                }
            case .failure(let error):
                self?.showAlert(title: "오류", message: "네트워크 오류: \(error.localizedDescription)")
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
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
