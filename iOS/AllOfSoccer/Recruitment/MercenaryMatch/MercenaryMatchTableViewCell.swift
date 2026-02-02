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
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        return label
    }()

    private let feeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        return label
    }()

    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 6
        stack.distribution = .fill
        return stack
    }()

    private let bottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillProportionally
        return stack
    }()

    private let tagsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fillProportionally
        return stack
    }()

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

        containerView.addSubview(titleLabel)
        containerView.addSubview(infoStackView)
        containerView.addSubview(bottomStackView)

        infoStackView.addArrangedSubview(locationLabel)
        infoStackView.addArrangedSubview(dateLabel)

        bottomStackView.addArrangedSubview(tagsStackView)
        bottomStackView.addArrangedSubview(feeLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            // Info Stack
            infoStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            infoStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            infoStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            // Bottom Stack
            bottomStackView.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 8),
            bottomStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            bottomStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            bottomStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Configure
    func configureWithRequest(_ request: MercenaryRequest, viewModel: MercenaryMatchViewModel) {
        titleLabel.text = request.title
        locationLabel.text = "📍 \(request.location)"
        dateLabel.text = "🕐 \(viewModel.formatDate(request.date))"
        feeLabel.text = viewModel.formatFee(request.fee)

        // Clear previous tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add position tags
        if !request.positionsNeeded.isEmpty {
            let positionText = viewModel.formatPositions(request.positionsNeeded)
            let positionTag = createTag(text: positionText)
            tagsStackView.addArrangedSubview(positionTag)
        }

        // Add applicant count
        let applicantText = "지원자: \(request.currentApplicants)/\(request.mercenaryCount)"
        let applicantTag = createTag(text: applicantText)
        tagsStackView.addArrangedSubview(applicantTag)
    }

    func configureWithApplication(_ application: MercenaryApplication, viewModel: MercenaryMatchViewModel) {
        titleLabel.text = application.title
        let locations = application.preferredLocations.joined(separator: ", ")
        locationLabel.text = "📍 \(locations.isEmpty ? "지역 미지정" : locations)"
        dateLabel.text = "🎯 실력: \(application.skillLevel)"

        if let minFee = application.preferredFeeMin, let maxFee = application.preferredFeeMax {
            feeLabel.text = "\(viewModel.formatFee(minFee)) ~ \(viewModel.formatFee(maxFee))"
        } else {
            feeLabel.text = "비용 협의"
        }

        // Clear previous tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add position tags
        if !application.positions.isEmpty {
            let positionText = application.positions.joined(separator: ", ")
            let positionTag = createTag(text: positionText)
            tagsStackView.addArrangedSubview(positionTag)
        }

        // Add status
        let statusText = getApplicationStatusText(application.status)
        let statusTag = createTag(text: statusText)
        tagsStackView.addArrangedSubview(statusTag)
    }

    private func createTag(text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        label.numberOfLines = 1

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.1)
        view.layer.cornerRadius = 4

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            view.heightAnchor.constraint(equalToConstant: 20)
        ])

        containerView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        return containerView
    }

    private func getApplicationStatusText(_ status: String) -> String {
        switch status {
        case "available": return "구인 중"
        case "matched": return "매칭됨"
        case "unavailable": return "불가능"
        default: return status
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        locationLabel.text = nil
        dateLabel.text = nil
        feeLabel.text = nil
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
