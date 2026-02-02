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

    // Section 1: Basic Info
    private let basicInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "기본 정보"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let titleView = RoundView()
    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "용병 모집 제목"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .black
        return tf
    }()

    private let descriptionView = RoundView()
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.text = "상세 내용을 입력하세요"
        tv.textColor = .lightGray
        tv.backgroundColor = .clear
        return tv
    }()

    // Section 2: Date & Location
    private let dateLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "일시/장소"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let dateTimeView = RoundView()
    private let calendarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = UIColor(red: 0.537, green: 0.556, blue: 0.580, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "날짜와 시간을 선택해주세요."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 0.537, green: 0.556, blue: 0.580, alpha: 1.0)
        return label
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.preferredDatePickerStyle = .wheels
        picker.minimumDate = Date()
        return picker
    }()

    private let placeView = RoundView()
    private let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "mappin.circle.fill")
        imageView.tintColor = UIColor(red: 0.537, green: 0.556, blue: 0.580, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let locationTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "경기 장소를 입력해주세요."
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .black
        return tf
    }()

    // Section 3: Fee & Count
    private let feeCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "참가비 및 모집 인원"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let feeView = RoundView()
    private let feeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "creditcard.fill")
        imageView.tintColor = UIColor(red: 0.537, green: 0.556, blue: 0.580, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let feeTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "참가비 (원)"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.keyboardType = .numberPad
        tf.textColor = .black
        return tf
    }()

    private let countView = RoundView()
    private let countImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.2.fill")
        imageView.tintColor = UIColor(red: 0.537, green: 0.556, blue: 0.580, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let countTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "모집 인원"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.keyboardType = .numberPad
        tf.textColor = .black
        return tf
    }()

    // Section 4: Positions
    private let positionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "모집 포지션"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let positionSelector = PositionSelectorView()

    // Section 5: Skill Level
    private let skillLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "실력 요구사항"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let skillSelector = SkillLevelSelectorView()

    // Submit Button
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("등록하기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        button.layer.cornerRadius = 8
        return button
    }()

    private var selectedDate: Date?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "용병 모집하기"
        setupUI()
        setupConstraints()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Section 1: Basic Info
        contentView.addSubview(basicInfoLabel)
        contentView.addSubview(titleView)
        titleView.addSubview(titleTextField)
        contentView.addSubview(descriptionView)
        descriptionView.addSubview(descriptionTextView)

        // Section 2: Date & Location
        contentView.addSubview(dateLocationLabel)
        contentView.addSubview(dateTimeView)
        dateTimeView.addSubview(calendarImageView)
        dateTimeView.addSubview(dateTimeLabel)
        contentView.addSubview(placeView)
        placeView.addSubview(locationImageView)
        placeView.addSubview(locationTextField)

        // Hidden date picker (for selection)
        contentView.addSubview(datePicker)
        datePicker.alpha = 0
        datePicker.isHidden = true

        // Section 3: Fee & Count
        contentView.addSubview(feeCountLabel)
        contentView.addSubview(feeView)
        feeView.addSubview(feeImageView)
        feeView.addSubview(feeTextField)
        contentView.addSubview(countView)
        countView.addSubview(countImageView)
        countView.addSubview(countTextField)

        // Section 4: Positions
        contentView.addSubview(positionLabel)
        contentView.addSubview(positionSelector)

        // Section 5: Skill Level
        contentView.addSubview(skillLabel)
        contentView.addSubview(skillSelector)

        // Submit Button
        view.addSubview(submitButton)

        // Configure RoundViews
        [titleView, descriptionView, dateTimeView, placeView, feeView, countView].forEach { view in
            view.backgroundColor = .white
            view.layer.cornerRadius = 6
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupConstraints() {
        let padding: CGFloat = 16

        // ScrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Section 1: Basic Info
        NSLayoutConstraint.activate([
            basicInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            basicInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            titleView.topAnchor.constraint(equalTo: basicInfoLabel.bottomAnchor, constant: 12),
            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            titleView.heightAnchor.constraint(equalToConstant: 50),

            titleTextField.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
            titleTextField.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),

            descriptionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 10),
            descriptionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            descriptionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            descriptionView.heightAnchor.constraint(equalToConstant: 100),

            descriptionTextView.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 12),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -12),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 12),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -12)
        ])

        // Section 2: Date & Location
        NSLayoutConstraint.activate([
            dateLocationLabel.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 24),
            dateLocationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            dateTimeView.topAnchor.constraint(equalTo: dateLocationLabel.bottomAnchor, constant: 12),
            dateTimeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            dateTimeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            dateTimeView.heightAnchor.constraint(equalToConstant: 50),

            calendarImageView.leadingAnchor.constraint(equalTo: dateTimeView.leadingAnchor, constant: 16),
            calendarImageView.centerYAnchor.constraint(equalTo: dateTimeView.centerYAnchor),
            calendarImageView.widthAnchor.constraint(equalToConstant: 18),
            calendarImageView.heightAnchor.constraint(equalToConstant: 18),

            dateTimeLabel.leadingAnchor.constraint(equalTo: calendarImageView.trailingAnchor, constant: 12),
            dateTimeLabel.centerYAnchor.constraint(equalTo: dateTimeView.centerYAnchor),

            placeView.topAnchor.constraint(equalTo: dateTimeView.bottomAnchor, constant: 10),
            placeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            placeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            placeView.heightAnchor.constraint(equalToConstant: 50),

            locationImageView.leadingAnchor.constraint(equalTo: placeView.leadingAnchor, constant: 16),
            locationImageView.centerYAnchor.constraint(equalTo: placeView.centerYAnchor),
            locationImageView.widthAnchor.constraint(equalToConstant: 18),
            locationImageView.heightAnchor.constraint(equalToConstant: 18),

            locationTextField.leadingAnchor.constraint(equalTo: locationImageView.trailingAnchor, constant: 12),
            locationTextField.trailingAnchor.constraint(equalTo: placeView.trailingAnchor, constant: -16),
            locationTextField.centerYAnchor.constraint(equalTo: placeView.centerYAnchor)
        ])

        // Hidden date picker
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 0)
        ])

        // Section 3: Fee & Count
        NSLayoutConstraint.activate([
            feeCountLabel.topAnchor.constraint(equalTo: placeView.bottomAnchor, constant: 24),
            feeCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            feeView.topAnchor.constraint(equalTo: feeCountLabel.bottomAnchor, constant: 12),
            feeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            feeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            feeView.heightAnchor.constraint(equalToConstant: 50),

            feeImageView.leadingAnchor.constraint(equalTo: feeView.leadingAnchor, constant: 16),
            feeImageView.centerYAnchor.constraint(equalTo: feeView.centerYAnchor),
            feeImageView.widthAnchor.constraint(equalToConstant: 16),
            feeImageView.heightAnchor.constraint(equalToConstant: 16),

            feeTextField.leadingAnchor.constraint(equalTo: feeImageView.trailingAnchor, constant: 12),
            feeTextField.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -padding/2),
            feeTextField.centerYAnchor.constraint(equalTo: feeView.centerYAnchor),

            countView.topAnchor.constraint(equalTo: feeCountLabel.bottomAnchor, constant: 12),
            countView.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: padding/2),
            countView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            countView.heightAnchor.constraint(equalToConstant: 50),

            countImageView.leadingAnchor.constraint(equalTo: countView.leadingAnchor, constant: 16),
            countImageView.centerYAnchor.constraint(equalTo: countView.centerYAnchor),
            countImageView.widthAnchor.constraint(equalToConstant: 16),
            countImageView.heightAnchor.constraint(equalToConstant: 16),

            countTextField.leadingAnchor.constraint(equalTo: countImageView.trailingAnchor, constant: 12),
            countTextField.trailingAnchor.constraint(equalTo: countView.trailingAnchor, constant: -16),
            countTextField.centerYAnchor.constraint(equalTo: countView.centerYAnchor)
        ])

        // Section 4: Positions
        NSLayoutConstraint.activate([
            positionLabel.topAnchor.constraint(equalTo: feeView.bottomAnchor, constant: 24),
            positionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            positionSelector.topAnchor.constraint(equalTo: positionLabel.bottomAnchor, constant: 12),
            positionSelector.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            positionSelector.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])

        // Section 5: Skill Level
        NSLayoutConstraint.activate([
            skillLabel.topAnchor.constraint(equalTo: positionSelector.bottomAnchor, constant: 24),
            skillLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            skillSelector.topAnchor.constraint(equalTo: skillLabel.bottomAnchor, constant: 12),
            skillSelector.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            skillSelector.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            skillSelector.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])

        // Submit Button
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 62)
        ])
    }

    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        descriptionTextView.delegate = self

        // Add tap gesture for date/time view
        let dateTimeTap = UITapGestureRecognizer(target: self, action: #selector(dateTimeViewTapped))
        dateTimeView.addGestureRecognizer(dateTimeTap)

        // Update date label when date picker changes
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)

        // Keyboard dismissal
        dismissKeyboard()
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func dateTimeViewTapped() {
        updateDateLabel()
    }

    @objc private func datePickerChanged() {
        updateDateLabel()
    }

    private func updateDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let dateString = dateFormatter.string(from: datePicker.date)
        dateTimeLabel.text = dateString
        dateTimeLabel.textColor = .black
        selectedDate = datePicker.date

        // Log the date being selected
        print("Selected date: \(dateString)")
        print("ISO8601 format: \(datePicker.date.toISO8601String())")
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

        guard selectedDate != nil else {
            showAlert("입력 오류", "날짜와 시간을 선택해주세요")
            return
        }

        let positions = positionSelector.getSelectedPositions()
        guard !positions.isEmpty else {
            showAlert("입력 오류", "최소 1개 이상의 포지션을 선택하세요")
            return
        }

        let (minLevel, maxLevel) = skillSelector.getSelectedLevels()
        let description = descriptionTextView.text != "상세 내용을 입력하세요" ? descriptionTextView.text ?? "" : ""

        // Show loading state
        submitButton.isEnabled = false
        let originalTitle = submitButton.titleLabel?.text
        submitButton.setTitle("등록 중...", for: .normal)

        let dateString = datePicker.date.toISO8601String()
        print("Submitting with date: \(dateString)")
        print("Positions: \(positions)")

        // Call API to create mercenary request
        APIService.shared.createMercenaryRequest(
            title: title,
            description: description.isEmpty ? nil : description,
            date: dateString,
            location: location,
            address: nil,
            fee: fee,
            mercenaryCount: count,
            positionsNeeded: positions,
            skillLevelMin: minLevel,
            skillLevelMax: maxLevel,
            teamName: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.submitButton.isEnabled = true
                self?.submitButton.setTitle(originalTitle ?? "등록하기", for: .normal)

                switch result {
                case .success:
                    self?.showAlert("성공", "용병 모집이 등록되었습니다")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    print("API Error: \(error)")
                    self?.showAlert("오류", "용병 모집 등록에 실패했습니다: \(error.localizedDescription)")
                }
            }
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

// MARK: - Keyboard Handling
extension MercenaryRequestViewController {
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
}

extension MercenaryRequestViewController {
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
