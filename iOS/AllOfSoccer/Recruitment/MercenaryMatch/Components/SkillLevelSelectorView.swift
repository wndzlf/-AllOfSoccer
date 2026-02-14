//
//  SkillLevelSelectorView.swift
//  AllOfSoccer
//
//  Created by Assistant on 2026
//

import UIKit

class SkillLevelSelectorView: UIView {
    private let levels = ["최하", "하", "중하", "중", "중상", "상", "최상"]

    private let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 6
        slider.value = 2
        slider.minimumTrackTintColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
        slider.maximumTrackTintColor = UIColor(red: 0.89, green: 0.89, blue: 0.90, alpha: 1.0)
        return slider
    }()

    private let selectedLevelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
        label.textAlignment = .right
        return label
    }()

    private let scaleLabelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()

    private var selectedIndex: Int = 2 {
        didSet {
            selectedLevelLabel.text = "요구 실력: \(levels[selectedIndex])"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateSelection(to: selectedIndex)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        updateSelection(to: selectedIndex)
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(selectedLevelLabel)
        addSubview(slider)
        addSubview(scaleLabelsStackView)

        levels.forEach { level in
            let label = UILabel()
            label.text = level
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label.textColor = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1.0)
            label.textAlignment = .center
            scaleLabelsStackView.addArrangedSubview(label)
        }

        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)

        NSLayoutConstraint.activate([
            selectedLevelLabel.topAnchor.constraint(equalTo: topAnchor),
            selectedLevelLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectedLevelLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            slider.topAnchor.constraint(equalTo: selectedLevelLabel.bottomAnchor, constant: 10),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),

            scaleLabelsStackView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 10),
            scaleLabelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scaleLabelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scaleLabelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 74)
        ])
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        let rounded = round(sender.value)
        sender.value = rounded
        updateSelection(to: Int(rounded))
    }

    private func updateSelection(to index: Int) {
        selectedIndex = max(0, min(index, levels.count - 1))
    }

    private func englishSkill(for index: Int) -> String {
        switch index {
        case 0...1:
            return "beginner"
        case 2...3:
            return "intermediate"
        case 4...5:
            return "advanced"
        default:
            return "expert"
        }
    }

    private func index(for englishSkill: String) -> Int {
        switch englishSkill.lowercased() {
        case "beginner":
            return 1
        case "intermediate":
            return 3
        case "advanced":
            return 5
        case "expert":
            return 6
        default:
            return 2
        }
    }

    func getSelectedLevels() -> (min: String, max: String) {
        let skill = englishSkill(for: selectedIndex)
        return (skill, skill)
    }

    func setSelectedLevels(min: String?, max: String?) {
        var candidates: [Int] = []

        if let min {
            candidates.append(index(for: min))
        }
        if let max {
            candidates.append(index(for: max))
        }

        let target = candidates.isEmpty ? 2 : Int(round(Double(candidates.reduce(0, +)) / Double(candidates.count)))
        slider.value = Float(target)
        updateSelection(to: target)
    }
}
