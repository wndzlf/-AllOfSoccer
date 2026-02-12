//
//  PositionSelectorView.swift
//  AllOfSoccer
//
//  Created by Assistant on 2026
//

import UIKit

class PositionSelectorView: UIView {
    enum Position: String, CaseIterable {
        case GK = "GK"
        case DF = "DF"
        case MF = "MF"
        case FW = "FW"
    }

    // MARK: - Properties
    var selectedPositions: [String: Int] = [:]
    private var positionButtons: [Position: PositionButtonView] = [:]

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually

        for position in Position.allCases {
            let buttonView = PositionButtonView(position: position)
            buttonView.delegate = self
            positionButtons[position] = buttonView
            stackView.addArrangedSubview(buttonView)
        }

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    func getSelectedPositions() -> [String: Int] {
        var result: [String: Int] = [:]
        for (position, buttonView) in positionButtons {
            if buttonView.count > 0 {
                result[position.rawValue] = buttonView.count
            }
        }
        return result
    }

    func setSelectedPositions(_ positions: [String: Int]) {
        for (position, buttonView) in positionButtons {
            let value = positions[position.rawValue] ?? 0
            buttonView.setCount(value)
        }
        selectedPositions = positions
    }
}

// MARK: - PositionButtonView
class PositionButtonView: UIView {
    let position: PositionSelectorView.Position
    var count: Int = 0
    weak var delegate: PositionSelectorView?

    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let containerView = UIView()

    init(position: PositionSelectorView.Position) {
        self.position = position
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor

        addSubview(containerView)

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = position.rawValue
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)

        // Minus Button
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.setTitle("−", for: .normal)
        minusButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        minusButton.addTarget(self, action: #selector(minusPressed), for: .touchUpInside)
        containerView.addSubview(minusButton)

        // Count Label
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.text = "0"
        countLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        countLabel.textAlignment = .center
        containerView.addSubview(countLabel)

        // Plus Button
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        plusButton.addTarget(self, action: #selector(plusPressed), for: .touchUpInside)
        containerView.addSubview(plusButton)

        // Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),

            minusButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            minusButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2),
            minusButton.widthAnchor.constraint(equalToConstant: 20),
            minusButton.heightAnchor.constraint(equalToConstant: 20),

            countLabel.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),
            countLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            countLabel.widthAnchor.constraint(equalToConstant: 20),

            plusButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            plusButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2),
            plusButton.widthAnchor.constraint(equalToConstant: 20),
            plusButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    @objc private func minusPressed() {
        if count > 0 {
            count -= 1
            countLabel.text = "\(count)"
        }
    }

    @objc private func plusPressed() {
        count += 1
        countLabel.text = "\(count)"
    }

    func setCount(_ newValue: Int) {
        count = max(0, newValue)
        countLabel.text = "\(count)"
    }
}
