//
//  MercenaryApplicationViewController.swift
//  AllOfSoccer
//
//  Created by Assistant on 2026
//

import UIKit

class MercenaryApplicationViewController: UIViewController {
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
        tf.placeholder = "지원 제목"
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
        tv.text = "자기소개를 입력하세요"
        tv.textColor = .lightGray
        return tv
    }()

    private let locationsTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "선호 지역 (쉼표로 구분)"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()

    private let positionsTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "가능 포지션 (예: GK,MF,FW)"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()

    private let skillSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["초급", "중급", "고급", "고수"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1
        return control
    }()

    private let minFeeTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "최소 비용 (원)"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.keyboardType = .numberPad
        return tf
    }()

    private let maxFeeTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "최대 비용 (원)"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.keyboardType = .numberPad
        return tf
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("지원하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "용병 지원하기"
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

        // Section: Location & Positions
        let locAndPosSection = createSection(title: "선호 조건", views: [locationsTextField, positionsTextField])
        stackView.addArrangedSubview(locAndPosSection)

        // Section: Skill Level
        let skillLabel = createSectionTitle("실력 레벨")
        stackView.addArrangedSubview(skillLabel)
        stackView.addArrangedSubview(skillSegmentedControl)
        skillSegmentedControl.heightAnchor.constraint(equalToConstant: 32).isActive = true

        // Section: Fee Range
        let feeLabel = createSectionTitle("희망 비용")
        stackView.addArrangedSubview(feeLabel)
        let feeStack = UIStackView()
        feeStack.translatesAutoresizingMaskIntoConstraints = false
        feeStack.axis = .horizontal
        feeStack.spacing = 8
        feeStack.distribution = .fillEqually
        feeStack.addArrangedSubview(minFeeTextField)
        feeStack.addArrangedSubview(maxFeeTextField)
        stackView.addArrangedSubview(feeStack)
        minFeeTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        maxFeeTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true

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
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            locationsTextField.heightAnchor.constraint(equalToConstant: 44),
            positionsTextField.heightAnchor.constraint(equalToConstant: 44)
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

        let description = descriptionTextView.text != "자기소개를 입력하세요" ? descriptionTextView.text ?? "" : ""

        let locations = locationsTextField.text?
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty } ?? []

        let positions = positionsTextField.text?
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces).uppercased() }
            .filter { !$0.isEmpty } ?? []

        let skillLevels = ["beginner", "intermediate", "advanced", "expert"]
        let skillLevel = skillLevels[skillSegmentedControl.selectedSegmentIndex]

        let minFee = Int(minFeeTextField.text ?? "0") ?? 0
        let maxFee = Int(maxFeeTextField.text ?? "100000") ?? 100000

        let applicationData: [String: Any] = [
            "title": title,
            "description": description,
            "preferred_locations": locations,
            "positions": positions,
            "skill_level": skillLevel,
            "preferred_fee_min": minFee,
            "preferred_fee_max": maxFee
        ]

        // TODO: Call API to create mercenary application
        print("Submitting mercenary application:", applicationData)
        showAlert("성공", "용병 지원이 등록되었습니다")

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
extension MercenaryApplicationViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "자기소개를 입력하세요"
            textView.textColor = .lightGray
        }
    }
}
