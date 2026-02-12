//
//  SkillLevelSelectorView.swift
//  AllOfSoccer
//
//  Created by Assistant on 2026
//

import UIKit

class SkillLevelSelectorView: UIView {
    enum SkillLevel: String, CaseIterable {
        case beginner = "초급"
        case intermediate = "중급"
        case advanced = "고급"
        case expert = "고수"

        var englishValue: String {
            switch self {
            case .beginner: return "beginner"
            case .intermediate: return "intermediate"
            case .advanced: return "advanced"
            case .expert: return "expert"
            }
        }
    }

    // MARK: - Properties
    var selectedMinLevel: SkillLevel = .beginner
    var selectedMaxLevel: SkillLevel = .expert
    private var minButtons: [SkillLevel: UIButton] = [:]
    private var maxButtons: [SkillLevel: UIButton] = [:]

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
        backgroundColor = .clear

        let mainStack = UIStackView()
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.distribution = .fillEqually
        addSubview(mainStack)

        // Min Level
        let minStack = createLevelStack(title: "최소 실력", buttons: &minButtons, isMin: true)
        mainStack.addArrangedSubview(minStack)

        // Max Level
        let maxStack = createLevelStack(title: "최대 실력", buttons: &maxButtons, isMin: false)
        mainStack.addArrangedSubview(maxStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func createLevelStack(title: String, buttons: inout [SkillLevel: UIButton], isMin: Bool) -> UIStackView {
        let container = UIStackView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        container.spacing = 6
        container.distribution = .fill

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .darkGray
        container.addArrangedSubview(titleLabel)

        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually

        for level in SkillLevel.allCases {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(level.rawValue, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            button.backgroundColor = .white
            button.setTitleColor(.darkGray, for: .normal)
            button.layer.cornerRadius = 6
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor

            // Set initial selection
            if isMin && level == .beginner {
                button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
                button.setTitleColor(.white, for: .normal)
            } else if !isMin && level == .expert {
                button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
                button.setTitleColor(.white, for: .normal)
            }

            button.tag = isMin ? SkillLevel.allCases.firstIndex(of: level) ?? 0 : 100 + (SkillLevel.allCases.firstIndex(of: level) ?? 0)
            button.addTarget(self, action: isMin ? #selector(minLevelSelected(_:)) : #selector(maxLevelSelected(_:)), for: .touchUpInside)

            buttons[level] = button
            buttonStack.addArrangedSubview(button)
        }

        container.addArrangedSubview(buttonStack)
        return container
    }

    @objc private func minLevelSelected(_ sender: UIButton) {
        minButtons.forEach { level, button in
            button.backgroundColor = button == sender ? UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0) : .white
            button.setTitleColor(button == sender ? .white : .darkGray, for: .normal)
        }

        if let selectedLevel = minButtons.first(where: { $0.value == sender })?.key {
            selectedMinLevel = selectedLevel
        }
    }

    @objc private func maxLevelSelected(_ sender: UIButton) {
        maxButtons.forEach { level, button in
            button.backgroundColor = button == sender ? UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0) : .white
            button.setTitleColor(button == sender ? .white : .darkGray, for: .normal)
        }

        if let selectedLevel = maxButtons.first(where: { $0.value == sender })?.key {
            selectedMaxLevel = selectedLevel
        }
    }

    func getSelectedLevels() -> (min: String, max: String) {
        return (selectedMinLevel.englishValue, selectedMaxLevel.englishValue)
    }

    func setSelectedLevels(min: String?, max: String?) {
        if let min = min,
           let minLevel = SkillLevel.allCases.first(where: { $0.englishValue == min }),
           let minButton = minButtons[minLevel] {
            minLevelSelected(minButton)
        }

        if let max = max,
           let maxLevel = SkillLevel.allCases.first(where: { $0.englishValue == max }),
           let maxButton = maxButtons[maxLevel] {
            maxLevelSelected(maxButton)
        }
    }
}
