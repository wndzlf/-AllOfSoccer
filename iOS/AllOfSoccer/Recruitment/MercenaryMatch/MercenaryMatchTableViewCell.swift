//
//  MercenaryMatchTableViewCell.swift
//  AllOfSoccer
//
//  Created by Assistant on 2026
//

import UIKit

class MercenaryMatchTableViewCell: UITableViewCell {
    static let identifier = "MercenaryMatchTableViewCell"

    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        return view
    }()

    private let leftDateStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(red: 0.40, green: 0.40, blue: 0.40, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private let rightContentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let metaChipStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        stack.distribution = .fillProportionally
        return stack
    }()

    private let matchTypeChip: PaddedLabel = {
        let label = PaddedLabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor(red: 46/255, green: 108/255, blue: 225/255, alpha: 1.0)
        label.backgroundColor = UIColor(red: 46/255, green: 108/255, blue: 225/255, alpha: 0.12)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.contentInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return label
    }()

    private let skillChip: PaddedLabel = {
        let label = PaddedLabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
        label.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 0.12)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.contentInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return label
    }()

    private let feeChip: PaddedLabel = {
        let label = PaddedLabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1.0)
        label.backgroundColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 0.12)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.contentInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return label
    }()

    private let teamNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1.0)
        return label
    }()

    private let statusRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }()

    private let statusBadge: PaddedLabel = {
        let label = PaddedLabel()
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.contentInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return label
    }()

    private let formerPlayerBadge: PaddedLabel = {
        let label = PaddedLabel()
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.contentInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return label
    }()

    private let positionBadge: PaddedLabel = {
        let label = PaddedLabel()
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.contentInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        label.textColor = UIColor(red: 86/255, green: 86/255, blue: 86/255, alpha: 1.0)
        label.backgroundColor = UIColor(red: 86/255, green: 86/255, blue: 86/255, alpha: 0.12)
        return label
    }()

    private let statusSpacerView = UIView()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        selectionStyle = .none

        contentView.addSubview(containerView)

        containerView.addSubview(leftDateStackView)
        containerView.addSubview(rightContentStackView)

        leftDateStackView.addArrangedSubview(dateLabel)
        leftDateStackView.addArrangedSubview(timeLabel)

        [matchTypeChip, skillChip, feeChip].forEach {
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .horizontal)
            metaChipStackView.addArrangedSubview($0)
        }

        statusBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
        formerPlayerBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
        positionBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
        statusBadge.setContentHuggingPriority(.required, for: .horizontal)
        formerPlayerBadge.setContentHuggingPriority(.required, for: .horizontal)
        positionBadge.setContentHuggingPriority(.required, for: .horizontal)

        rightContentStackView.addArrangedSubview(locationLabel)
        rightContentStackView.addArrangedSubview(metaChipStackView)
        rightContentStackView.addArrangedSubview(teamNameLabel)
        rightContentStackView.addArrangedSubview(statusRowStackView)

        statusRowStackView.addArrangedSubview(statusBadge)
        statusRowStackView.addArrangedSubview(formerPlayerBadge)
        statusRowStackView.addArrangedSubview(positionBadge)
        statusRowStackView.addArrangedSubview(statusSpacerView)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            leftDateStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            leftDateStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            leftDateStackView.widthAnchor.constraint(equalToConstant: 92),
            leftDateStackView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 12),
            leftDateStackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),

            rightContentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            rightContentStackView.leadingAnchor.constraint(equalTo: leftDateStackView.trailingAnchor, constant: 14),
            rightContentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            rightContentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14)
        ])
    }

    // MARK: - Configure
    func configureWithRequest(_ request: MercenaryRequest, viewModel: MercenaryMatchViewModel) {
        let dateParts = viewModel.formatDateTimeComponents(request.date)
        dateLabel.text = dateParts.date
        timeLabel.text = dateParts.time.isEmpty ? "--:--" : dateParts.time

        locationLabel.text = viewModel.formatLocationTitle(location: request.location, address: request.address)
        teamNameLabel.text = request.team?.name ?? "팀 정보 미등록"

        matchTypeChip.text = viewModel.formatMatchType(request.matchType)
        skillChip.text = viewModel.formatSkillChip(min: request.skillLevelMin, max: request.skillLevelMax)
        feeChip.text = viewModel.formatFeeChip(request.fee)

        let remainingPositions = max(request.mercenaryCount - request.currentApplicants, 0)
        if request.status == "closed" || remainingPositions <= 0 {
            configureStatusBadge(text: "모집 완료", isRecruiting: false)
        } else {
            configureStatusBadge(text: "용병 \(remainingPositions)명 모집중", isRecruiting: true)
        }

        configureFormerPlayerBadge(text: viewModel.formatFormerPlayerType(request.hasFormerPlayer), hasFormerPlayer: request.hasFormerPlayer)

        let positionsText = viewModel.formatPositionSummary(request.positionsNeeded)
        positionBadge.text = positionsText
        positionBadge.isHidden = positionsText.isEmpty
    }

    func configureWithApplication(_ application: MercenaryApplication, viewModel: MercenaryMatchViewModel) {
        if let firstDate = application.availableDates.sorted().first {
            let dateParts = viewModel.formatDateTimeComponents(firstDate)
            dateLabel.text = dateParts.date
            timeLabel.text = dateParts.time.isEmpty ? "--:--" : dateParts.time
        } else {
            dateLabel.text = "날짜 미정"
            timeLabel.text = "--:--"
        }

        let location = application.preferredLocations.first ?? "지역 미지정"
        locationLabel.text = viewModel.formatLocationTitle(location: location, address: nil)
        teamNameLabel.text = application.user?.name ?? "개인 용병"

        matchTypeChip.text = "용병 지원"
        skillChip.text = "실력 \(viewModel.formatSkillRange(min: application.skillLevel, max: nil))"

        if let minFee = application.preferredFeeMin, let maxFee = application.preferredFeeMax {
            feeChip.text = "희망비 \(viewModel.formatFee(minFee))~\(viewModel.formatFee(maxFee))"
        } else {
            feeChip.text = "희망비 협의"
        }

        switch application.status {
        case "available":
            configureStatusBadge(text: "구인 중", isRecruiting: true)
        case "matched":
            configureStatusBadge(text: "매칭됨", isRecruiting: false)
        case "unavailable":
            statusBadge.text = "불가능"
            statusBadge.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
            statusBadge.backgroundColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 0.12)
            statusBadge.isHidden = false
        default:
            statusBadge.isHidden = true
        }

        formerPlayerBadge.isHidden = true
        let positionsText = application.positions.isEmpty ? "" : "포지션 \(application.positions.joined(separator: ", "))"
        positionBadge.text = positionsText
        positionBadge.isHidden = positionsText.isEmpty
    }

    private func configureStatusBadge(text: String, isRecruiting: Bool) {
        statusBadge.text = text
        statusBadge.isHidden = false

        if isRecruiting {
            statusBadge.textColor = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1.0)
            statusBadge.backgroundColor = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 0.12)
        } else {
            statusBadge.textColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0)
            statusBadge.backgroundColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 0.12)
        }
    }

    private func configureFormerPlayerBadge(text: String, hasFormerPlayer: Bool?) {
        formerPlayerBadge.text = text
        formerPlayerBadge.isHidden = false

        guard let hasFormerPlayer else {
            formerPlayerBadge.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
            formerPlayerBadge.backgroundColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 0.12)
            return
        }

        if hasFormerPlayer {
            formerPlayerBadge.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
            formerPlayerBadge.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 0.12)
        } else {
            formerPlayerBadge.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
            formerPlayerBadge.backgroundColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 0.12)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        timeLabel.text = nil
        locationLabel.text = nil
        teamNameLabel.text = nil
        matchTypeChip.text = nil
        skillChip.text = nil
        feeChip.text = nil
        statusBadge.text = nil
        formerPlayerBadge.text = nil
        positionBadge.text = nil
        statusBadge.isHidden = true
        formerPlayerBadge.isHidden = true
        positionBadge.isHidden = true
    }
}

private final class PaddedLabel: UILabel {
    var contentInsets = UIEdgeInsets.zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + contentInsets.left + contentInsets.right,
            height: size.height + contentInsets.top + contentInsets.bottom
        )
    }
}
