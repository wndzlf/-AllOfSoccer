//
//  MercenaryDetailViewController.swift
//  AllOfSoccer
//
//  Created by iOS Developer on 2026/02/08
//

import UIKit

class MercenaryDetailViewController: UIViewController {
    // MARK: - Properties
    private let requestId: String
    private let viewModel = MercenaryDetailViewModel()
    private var mercenaryRequest: MercenaryRequest?
    private var observerTokens: [NSObjectProtocol] = []

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        return scroll
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 14)
        label.isHidden = true
        return label
    }()

    // Header Information
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()

    private let statusBadge: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.textColor = .white
        label.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        return label
    }()

    // Match Information Card
    private let matchInfoCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        return view
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    private let matchTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()

    private let genderTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()

    private let feeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        return label
    }()

    // Details Section
    private let detailsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()

    private let positionsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "필요 포지션"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let positionsValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()

    private let skillLevelTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "실력 레벨"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let skillLevelValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        return label
    }()

    private let shoesRequirementTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "신발 요구사항"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let shoesRequirementValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        return label
    }()

    private let participantsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "지원자 현황"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let participantsValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        return label
    }()

    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "상세 설명"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let descriptionValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()

    // Team Information Section
    private let teamInfoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()

    private let teamTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "등록자 정보"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let teamNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let teamDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()

    // Action Buttons
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
        button.setTitle("신청하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0).cgColor
        button.layer.borderWidth = 1
        return button
    }()

    // MARK: - Initialization
    init(requestId: String) {
        self.requestId = requestId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        observerTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        loadDetail()
    }

    // MARK: - Setup UI
    private func setupUI() {
        title = "용병 모집 상세"
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)

        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)

        scrollView.addSubview(contentView)

        // Setup content views
        contentView.addSubview(titleLabel)
        contentView.addSubview(statusBadge)
        contentView.addSubview(matchInfoCard)
        contentView.addSubview(detailsContainer)
        contentView.addSubview(teamInfoContainer)

        // Match Info Card contents
        matchInfoCard.addSubview(locationLabel)
        matchInfoCard.addSubview(dateLabel)
        matchInfoCard.addSubview(matchTypeLabel)
        matchInfoCard.addSubview(genderTypeLabel)
        matchInfoCard.addSubview(feeLabel)

        // Details Container
        detailsContainer.addSubview(positionsTitleLabel)
        detailsContainer.addSubview(positionsValueLabel)
        detailsContainer.addSubview(skillLevelTitleLabel)
        detailsContainer.addSubview(skillLevelValueLabel)
        detailsContainer.addSubview(shoesRequirementTitleLabel)
        detailsContainer.addSubview(shoesRequirementValueLabel)
        detailsContainer.addSubview(participantsTitleLabel)
        detailsContainer.addSubview(participantsValueLabel)
        detailsContainer.addSubview(descriptionTitleLabel)
        detailsContainer.addSubview(descriptionValueLabel)

        // Team Info Container
        teamInfoContainer.addSubview(teamTitleLabel)
        teamInfoContainer.addSubview(teamNameLabel)
        teamInfoContainer.addSubview(teamDescriptionLabel)

        // Add buttons
        view.addSubview(applyButton)
        view.addSubview(shareButton)

        setupConstraints()
        setupActions()
    }

    private func setupActions() {
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -16),

            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Title and status
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: -12),

            statusBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            statusBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusBadge.heightAnchor.constraint(equalToConstant: 28),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),

            // Match Info Card
            matchInfoCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            matchInfoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            matchInfoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            locationLabel.topAnchor.constraint(equalTo: matchInfoCard.topAnchor, constant: 16),
            locationLabel.leadingAnchor.constraint(equalTo: matchInfoCard.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: matchInfoCard.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: matchInfoCard.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: matchInfoCard.trailingAnchor, constant: -16),

            matchTypeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            matchTypeLabel.leadingAnchor.constraint(equalTo: matchInfoCard.leadingAnchor, constant: 16),
            matchTypeLabel.heightAnchor.constraint(equalToConstant: 28),
            matchTypeLabel.widthAnchor.constraint(equalToConstant: 60),

            genderTypeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            genderTypeLabel.leadingAnchor.constraint(equalTo: matchTypeLabel.trailingAnchor, constant: 8),
            genderTypeLabel.heightAnchor.constraint(equalToConstant: 28),
            genderTypeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

            feeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            feeLabel.trailingAnchor.constraint(equalTo: matchInfoCard.trailingAnchor, constant: -16),

            matchInfoCard.bottomAnchor.constraint(equalTo: genderTypeLabel.bottomAnchor, constant: 16),

            // Details Container
            detailsContainer.topAnchor.constraint(equalTo: matchInfoCard.bottomAnchor, constant: 16),
            detailsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            positionsTitleLabel.topAnchor.constraint(equalTo: detailsContainer.topAnchor, constant: 16),
            positionsTitleLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 16),

            positionsValueLabel.topAnchor.constraint(equalTo: positionsTitleLabel.bottomAnchor, constant: 6),
            positionsValueLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 16),
            positionsValueLabel.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor, constant: -16),

            skillLevelTitleLabel.topAnchor.constraint(equalTo: positionsValueLabel.bottomAnchor, constant: 16),
            skillLevelTitleLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 16),

            skillLevelValueLabel.topAnchor.constraint(equalTo: skillLevelTitleLabel.bottomAnchor, constant: 6),
            skillLevelValueLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 16),

            shoesRequirementTitleLabel.topAnchor.constraint(equalTo: skillLevelValueLabel.bottomAnchor, constant: 16),
            shoesRequirementTitleLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 16),

            shoesRequirementValueLabel.topAnchor.constraint(equalTo: shoesRequirementTitleLabel.bottomAnchor, constant: 6),
            shoesRequirementValueLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 16),

            participantsTitleLabel.topAnchor.constraint(equalTo: shoesRequirementValueLabel.bottomAnchor, constant: 16),
            participantsTitleLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 16),

            participantsValueLabel.topAnchor.constraint(equalTo: participantsTitleLabel.bottomAnchor, constant: 6),
            participantsValueLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 16),

            descriptionTitleLabel.topAnchor.constraint(equalTo: participantsValueLabel.bottomAnchor, constant: 16),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 16),

            descriptionValueLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 6),
            descriptionValueLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 16),
            descriptionValueLabel.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor, constant: -16),

            detailsContainer.bottomAnchor.constraint(equalTo: descriptionValueLabel.bottomAnchor, constant: 16),

            // Team Info Container
            teamInfoContainer.topAnchor.constraint(equalTo: detailsContainer.bottomAnchor, constant: 16),
            teamInfoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            teamInfoContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            teamTitleLabel.topAnchor.constraint(equalTo: teamInfoContainer.topAnchor, constant: 16),
            teamTitleLabel.leadingAnchor.constraint(equalTo: teamInfoContainer.leadingAnchor, constant: 16),

            teamNameLabel.topAnchor.constraint(equalTo: teamTitleLabel.bottomAnchor, constant: 12),
            teamNameLabel.leadingAnchor.constraint(equalTo: teamInfoContainer.leadingAnchor, constant: 16),
            teamNameLabel.trailingAnchor.constraint(equalTo: teamInfoContainer.trailingAnchor, constant: -16),

            teamDescriptionLabel.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: 8),
            teamDescriptionLabel.leadingAnchor.constraint(equalTo: teamInfoContainer.leadingAnchor, constant: 16),
            teamDescriptionLabel.trailingAnchor.constraint(equalTo: teamInfoContainer.trailingAnchor, constant: -16),

            teamInfoContainer.bottomAnchor.constraint(equalTo: teamDescriptionLabel.bottomAnchor, constant: 16),

            // ContentView bottom - required for scrollView content size
            contentView.bottomAnchor.constraint(equalTo: teamInfoContainer.bottomAnchor, constant: 16),

            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Error label
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Action buttons
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            applyButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 50),
            applyButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -12),

            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            shareButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func bindViewModel() {
        let loadingToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MercenaryDetailViewModelLoadingChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateLoadingState()
        }
        observerTokens.append(loadingToken)

        let detailToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MercenaryDetailViewModelDetailChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateDetailDisplay()
        }
        observerTokens.append(detailToken)

        let errorToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MercenaryDetailViewModelErrorChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateErrorState()
        }
        observerTokens.append(errorToken)
    }

    private func loadDetail() {
        viewModel.fetchMercenaryDetail(requestId: requestId)
    }

    private func updateLoadingState() {
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
            scrollView.isHidden = true
            errorLabel.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
        }
    }

    private func updateDetailDisplay() {
        mercenaryRequest = viewModel.mercenaryRequest
        guard let request = mercenaryRequest else { return }

        errorLabel.isHidden = true

        // Title and status
        titleLabel.text = request.title
        updateStatusBadge(request)

        // Match info
        locationLabel.text = "📍 위치: \(request.location)"
        dateLabel.text = "🕐 날짜: \(formatDate(request.date))"
        matchTypeLabel.text = request.matchType ?? "11v11"
        genderTypeLabel.text = formatGenderType(request.genderType)
        feeLabel.text = "₩\(request.fee)"

        // Details
        let positionsText = formatPositions(request.positionsNeeded)
        positionsValueLabel.text = positionsText.isEmpty ? "-" : positionsText

        skillLevelValueLabel.text = formatSkillLevel(request.skillLevelMin, request.skillLevelMax)

        shoesRequirementValueLabel.text = formatShoesRequirement(request.shoesRequirement)

        participantsValueLabel.text = "\(request.currentApplicants) / \(request.mercenaryCount)명"

        descriptionValueLabel.text = request.description ?? "상세 설명이 없습니다."

        // Team info
        if let team = request.team {
            teamNameLabel.text = team.name
            teamDescriptionLabel.text = team.introduction ?? team.description ?? "팀 소개가 없습니다."
        } else {
            teamNameLabel.text = "팀 정보 없음"
            teamDescriptionLabel.text = ""
        }
    }

    private func updateErrorState() {
        if let error = viewModel.errorMessage {
            errorLabel.text = "오류: \(error)"
            errorLabel.isHidden = false
            scrollView.isHidden = true
        } else {
            errorLabel.isHidden = true
        }
    }

    private func updateStatusBadge(_ request: MercenaryRequest) {
        let remainingPositions = request.mercenaryCount - request.currentApplicants
        if remainingPositions > 0 {
            statusBadge.text = "모집 중 (\(remainingPositions)명)"
            statusBadge.backgroundColor = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1.0)
        } else {
            statusBadge.text = "모집 완료"
            statusBadge.backgroundColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0)
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MM월 dd일 HH:mm"
            displayFormatter.locale = Locale(identifier: "ko_KR")
            return displayFormatter.string(from: date)
        }
        return dateString
    }

    private func formatPositions(_ positions: [String: Int]) -> String {
        return positions.map { "\($0.key)(\($0.value)명)" }.joined(separator: ", ")
    }

    private func formatSkillLevel(_ min: String?, _ max: String?) -> String {
        if let min = min, let max = max {
            return "\(min) ~ \(max)"
        } else if let min = min {
            return min
        } else if let max = max {
            return max
        }
        return "상관없음"
    }

    private func formatGenderType(_ genderType: String?) -> String {
        switch genderType {
        case "male": return "남성"
        case "female": return "여성"
        case "mixed": return "혼성"
        default: return "성별 무관"
        }
    }

    private func formatShoesRequirement(_ shoes: String?) -> String {
        switch shoes {
        case "futsal": return "풋살화"
        case "soccer": return "축구화"
        case "any": return "상관없음"
        default: return "상관없음"
        }
    }

    // MARK: - Actions
    @objc private func applyButtonTapped() {
        guard let request = mercenaryRequest else { return }
        print("신청: \(request.id)")
        // TODO: 신청 로직 구현
        showAlert(title: "신청 완료", message: "용병 신청이 완료되었습니다.")
    }

    @objc private func shareButtonTapped() {
        guard let request = mercenaryRequest else { return }
        let text = "\(request.title)\n위치: \(request.location)\n참가비: ₩\(request.fee)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MercenaryDetailViewModel
class MercenaryDetailViewModel {
    @Published var mercenaryRequest: MercenaryRequest?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchMercenaryDetail(requestId: String) {
        isLoading = true
        errorMessage = nil

        NotificationCenter.default.post(name: NSNotification.Name("MercenaryDetailViewModelLoadingChanged"), object: nil)

        APIService.shared.getMercenaryRequestDetail(requestId: requestId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                NotificationCenter.default.post(name: NSNotification.Name("MercenaryDetailViewModelLoadingChanged"), object: nil)

                switch result {
                case .success(let response):
                    self?.mercenaryRequest = response.data
                    NotificationCenter.default.post(name: NSNotification.Name("MercenaryDetailViewModelDetailChanged"), object: nil)

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    NotificationCenter.default.post(name: NSNotification.Name("MercenaryDetailViewModelErrorChanged"), object: nil)
                }
            }
        }
    }
}
