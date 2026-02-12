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
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
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
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let dateTimeView = RoundView()
    private let calendarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
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

    private let placeView = RoundView()
    private let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "mappin.circle.fill")
        imageView.tintColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
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
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let feeView = RoundView()
    private let feeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "creditcard.fill")
        imageView.tintColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
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
        imageView.tintColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
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
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let positionSelector = PositionSelectorView()

    // Section 5: Skill Level
    private let skillLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "실력 요구사항"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let skillSelector = SkillLevelSelectorView()

    // Submit Button
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("등록하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
        button.layer.cornerRadius = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var selectedDate: Date?
    private var selectedTeamName: String = "개인 모집"

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
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "이전 글 불러오기",
            style: .plain,
            target: self,
            action: #selector(loadPreviousRequestTapped)
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

        // Configure RoundViews with subtle borders
        let borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 1.0)
        [titleView, descriptionView, dateTimeView, placeView, feeView, countView].forEach { view in
            view.backgroundColor = .white
            view.layer.cornerRadius = 8
            view.borderColor = borderColor
            view.borderWidth = 1
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

            descriptionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 12),
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
            dateLocationLabel.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 32),
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

            placeView.topAnchor.constraint(equalTo: dateTimeView.bottomAnchor, constant: 12),
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

        // Section 3: Fee & Count
        NSLayoutConstraint.activate([
            feeCountLabel.topAnchor.constraint(equalTo: placeView.bottomAnchor, constant: 32),
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
            positionLabel.topAnchor.constraint(equalTo: feeView.bottomAnchor, constant: 32),
            positionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            positionSelector.topAnchor.constraint(equalTo: positionLabel.bottomAnchor, constant: 12),
            positionSelector.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            positionSelector.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])

        // Section 5: Skill Level
        NSLayoutConstraint.activate([
            skillLabel.topAnchor.constraint(equalTo: positionSelector.bottomAnchor, constant: 32),
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

        // Add tap gesture for date/time view to open calendar
        let dateTimeTap = UITapGestureRecognizer(target: self, action: #selector(dateTimeViewTapped))
        dateTimeView.addGestureRecognizer(dateTimeTap)

        // Keyboard dismissal
        dismissKeyboard()
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func loadPreviousRequestTapped() {
        APIService.shared.getMyMercenaryRequests(page: 1, limit: 20) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard !response.data.isEmpty else {
                        self?.showAlert("안내", "불러올 이전 용병 모집 글이 없습니다")
                        return
                    }
                    self?.presentPreviousRequestActionSheet(requests: response.data)
                case .failure(let error):
                    self?.showAlert("오류", "이전 글을 불러오지 못했습니다: \(error.localizedDescription)")
                }
            }
        }
    }

    private func presentPreviousRequestActionSheet(requests: [MercenaryRequest]) {
        let sheet = UIAlertController(title: "이전 글 불러오기", message: "불러올 게시글을 선택하세요.", preferredStyle: .actionSheet)
        let recentRequests = Array(requests.prefix(8))

        for request in recentRequests {
            let teamName = request.team?.name ?? "내 팀"
            let actionTitle = "[\(teamName)] \(request.title)"
            sheet.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { [weak self] _ in
                self?.applyPreviousRequestDraft(request)
            }))
        }

        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(sheet, animated: true)
    }

    private func applyPreviousRequestDraft(_ request: MercenaryRequest) {
        titleTextField.text = request.title
        locationTextField.text = request.location
        feeTextField.text = "\(request.fee)"
        countTextField.text = "\(request.mercenaryCount)"
        selectedTeamName = request.team?.name ?? "개인 모집"

        if let description = request.description, !description.isEmpty {
            descriptionTextView.text = description
            descriptionTextView.textColor = .black
        } else {
            descriptionTextView.text = "상세 내용을 입력하세요"
            descriptionTextView.textColor = .lightGray
        }

        if let date = parseServerDate(request.date) {
            selectedDate = date
            dateTimeLabel.text = formattedDisplayDate(date)
            dateTimeLabel.textColor = .black
        }

        positionSelector.setSelectedPositions(request.positionsNeeded)
        skillSelector.setSelectedLevels(min: request.skillLevelMin, max: request.skillLevelMax)

        showAlert("안내", "이전 글을 불러왔습니다. 날짜/장소만 수정 후 등록하세요.")
    }

    @objc private func dateTimeViewTapped() {
        let recruitmentCalendarView = RecruitmentCalendarView()
        recruitmentCalendarView.delegate = self
        addSubviewWithConstraints(view: recruitmentCalendarView)
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

        let dateString = selectedDate?.toISO8601String() ?? ""
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
            teamName: selectedTeamName
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

    private func parseServerDate(_ dateString: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        let fallback = DateFormatter()
        fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        fallback.locale = Locale(identifier: "en_US_POSIX")
        return fallback.date(from: dateString)
    }

    private func formattedDisplayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    private func addSubviewWithConstraints(view: UIView) {
        guard let navigationController = self.navigationController else { return }
        navigationController.view.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: navigationController.view.topAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor, constant: 0)
        ])
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

// MARK: - RecruitmentCalendarViewDelegate
extension MercenaryRequestViewController: RecruitmentCalendarViewDelegate {
    func cancelButtonDidSelected(_ view: RecruitmentCalendarView) {
        view.removeFromSuperview()
    }

    func okButtonDidSelected(_ view: RecruitmentCalendarView, selectedDate: String) {
        // 선택된 날짜와 시간을 표시
        dateTimeLabel.text = selectedDate
        dateTimeLabel.textColor = .black

        // Date 객체로 파싱 (format: "yyyy년 MM월 dd일 HH:mm")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        if let parsedDate = dateFormatter.date(from: selectedDate) {
            self.selectedDate = parsedDate
        }

        view.removeFromSuperview()
    }
}

// MARK: - Keyboard Handling
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
