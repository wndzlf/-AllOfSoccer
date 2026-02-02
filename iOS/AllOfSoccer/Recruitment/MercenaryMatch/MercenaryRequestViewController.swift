//
//  MercenaryRequestViewController.swift
//  AllOfSoccer
//
//  Created by Assistant on 2026
//

import UIKit

class MercenaryRequestViewController: UIViewController {
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "용병 모집 제목"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()

    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.cornerRadius = 5
        tv.text = "상세 내용을 입력하세요"
        tv.textColor = .lightGray
        return tv
    }()

    private let datePickerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.preferredDatePickerStyle = .wheels
        picker.minimumDate = Date()
        return picker
    }()

    private let locationTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "경기 장소"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()

    private let feeTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "참가비 (원)"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.keyboardType = .numberPad
        return tf
    }()

    private let countTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "모집 인원"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.keyboardType = .numberPad
        return tf
    }()

    private let positionSelector: PositionSelectorView = {
        let selector = PositionSelectorView()
        return selector
    }()

    private let skillSelector: SkillLevelSelectorView = {
        let selector = SkillLevelSelectorView()
        return selector
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("등록하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "용병 모집하기"
        setupUI()
        setupActions()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Create stack view for content
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill

        contentView.addSubview(stackView)

        // Section: Basic Info
        let basicSection = createSection(title: "기본 정보", views: [titleTextField, descriptionTextView])
        stackView.addArrangedSubview(basicSection)

        // Section: Date & Location
        let dateLocationSection = createSection(title: "날짜 및 장소", views: [datePickerView, locationTextField])
        stackView.addArrangedSubview(dateLocationSection)

        // Add date picker to its container
        datePickerView.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: datePickerView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: datePickerView.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: datePickerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: datePickerView.trailingAnchor),
            datePickerView.heightAnchor.constraint(equalToConstant: 150)
        ])

        // Section: Fee & Count
        let feeCountSection = createSection(title: "참가비 및 모집 인원", views: [feeTextField, countTextField])
        stackView.addArrangedSubview(feeCountSection)

        // Section: Position
        let positionLabel = createSectionTitle("모집 포지션")
        stackView.addArrangedSubview(positionLabel)
        stackView.addArrangedSubview(positionSelector)

        // Section: Skill Level
        let skillLabel = createSectionTitle("실력 요구사항")
        stackView.addArrangedSubview(skillLabel)
        stackView.addArrangedSubview(skillSelector)

        // Submit Button
        stackView.addArrangedSubview(submitButton)
        submitButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 80),
            locationTextField.heightAnchor.constraint(equalToConstant: 44),
            feeTextField.heightAnchor.constraint(equalToConstant: 44),
            countTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func createSection(title: String, views: [UIView]) -> UIStackView {
        let section = UIStackView()
        section.translatesAutoresizingMaskIntoConstraints = false
        section.axis = .vertical
        section.spacing = 10
        section.distribution = .fill

        let titleLabel = createSectionTitle(title)
        section.addArrangedSubview(titleLabel)

        for view in views {
            section.addArrangedSubview(view)
        }

        return section
    }

    private func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        return label
    }

    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        descriptionTextView.delegate = self
    }

    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func submitButtonTapped() {
        // Validate inputs
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert("입력 오류", "제목을 입력하세요")
            return
        }

        guard let location = locationTextField.text, !location.isEmpty else {
            showAlert("입력 오류", "경기 장소를 입력하세요")
            return
        }

        guard let feeStr = feeTextField.text, !feeStr.isEmpty, let fee = Int(feeStr) else {
            showAlert("입력 오류", "참가비를 입력하세요")
            return
        }

        guard let countStr = countTextField.text, !countStr.isEmpty, let count = Int(countStr), count > 0 else {
            showAlert("입력 오류", "모집 인원을 입력하세요")
            return
        }

        let positions = positionSelector.getSelectedPositions()
        let (minLevel, maxLevel) = skillSelector.getSelectedLevels()

        let requestData: [String: Any] = [
            "title": title,
            "description": descriptionTextView.text != "상세 내용을 입력하세요" ? descriptionTextView.text ?? "" : "",
            "date": datePicker.date.toISO8601String(),
            "location": location,
            "fee": fee,
            "mercenary_count": count,
            "positions_needed": positions,
            "skill_level_min": minLevel,
            "skill_level_max": maxLevel,
            "team_name": "팀"
        ]

        // TODO: Call API to create mercenary request
        print("Submitting mercenary request:", requestData)
        showAlert("성공", "용병 모집이 등록되었습니다")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension MercenaryRequestViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "상세 내용을 입력하세요"
            textView.textColor = .lightGray
        }
    }
}

// MARK: - Helper
extension Date {
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}
