//
//  UserProfileViewController.swift
//  AllOfSoccer
//
//  Created by iOS Developer on 2026/02/08
//

import UIKit

class UserProfileViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = UserProfileViewModel()
    private var observerTokens: [NSObjectProtocol] = []
    private var selectedImage: UIImage?

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

    // Profile Image Section
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .gray
        return imageView
    }()

    private let changeImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
        button.setTitle("사진 변경", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        return button
    }()

    // Form Container
    private let formContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()

    // Nickname
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "닉네임"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "닉네임 입력"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        return textField
    }()

    // Introduction
    private let introductionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "소개글"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let introductionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        textView.layer.cornerRadius = 4
        textView.text = "소개글을 입력하세요"
        textView.textColor = .lightGray
        textView.clipsToBounds = true
        return textView
    }()

    // Preferred Position
    private let preferredPositionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "선호 포지션"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let preferredPositionTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "예: GK, DF, MF"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        return textField
    }()

    // Preferred Skill Level
    private let preferredSkillLevelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "선호 실력"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let preferredSkillLevelSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["초급", "중급", "고급", "전문가"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1
        return control
    }()

    // Location
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "위치"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let locationTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "예: 강남구"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        return textField
    }()

    // Save Button
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        loadProfile()
    }

    deinit {
        observerTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Setup UI
    private func setupUI() {
        title = "프로필 설정"
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "내 팀 관리",
            style: .plain,
            target: self,
            action: #selector(manageTeamTapped)
        )

        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)

        scrollView.addSubview(contentView)

        // Profile image section
        contentView.addSubview(profileImageView)
        contentView.addSubview(changeImageButton)

        // Form container
        contentView.addSubview(formContainer)

        formContainer.addSubview(nicknameLabel)
        formContainer.addSubview(nicknameTextField)
        formContainer.addSubview(introductionLabel)
        formContainer.addSubview(introductionTextView)
        formContainer.addSubview(preferredPositionLabel)
        formContainer.addSubview(preferredPositionTextField)
        formContainer.addSubview(preferredSkillLevelLabel)
        formContainer.addSubview(preferredSkillLevelSegmentedControl)
        formContainer.addSubview(locationLabel)
        formContainer.addSubview(locationTextField)

        view.addSubview(saveButton)

        setupConstraints()
        setupActions()
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),

            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Profile image
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            changeImageButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            changeImageButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            changeImageButton.heightAnchor.constraint(equalToConstant: 32),
            changeImageButton.widthAnchor.constraint(equalToConstant: 100),

            // Form container
            formContainer.topAnchor.constraint(equalTo: changeImageButton.bottomAnchor, constant: 20),
            formContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            formContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Nickname
            nicknameLabel.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 16),
            nicknameLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),

            nicknameTextField.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            nicknameTextField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),
            nicknameTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 40),

            // Introduction
            introductionLabel.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 16),
            introductionLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),

            introductionTextView.topAnchor.constraint(equalTo: introductionLabel.bottomAnchor, constant: 8),
            introductionTextView.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),
            introductionTextView.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16),
            introductionTextView.heightAnchor.constraint(equalToConstant: 80),

            // Preferred Position
            preferredPositionLabel.topAnchor.constraint(equalTo: introductionTextView.bottomAnchor, constant: 16),
            preferredPositionLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),

            preferredPositionTextField.topAnchor.constraint(equalTo: preferredPositionLabel.bottomAnchor, constant: 8),
            preferredPositionTextField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),
            preferredPositionTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16),
            preferredPositionTextField.heightAnchor.constraint(equalToConstant: 40),

            // Preferred Skill Level
            preferredSkillLevelLabel.topAnchor.constraint(equalTo: preferredPositionTextField.bottomAnchor, constant: 16),
            preferredSkillLevelLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),

            preferredSkillLevelSegmentedControl.topAnchor.constraint(equalTo: preferredSkillLevelLabel.bottomAnchor, constant: 8),
            preferredSkillLevelSegmentedControl.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),
            preferredSkillLevelSegmentedControl.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16),
            preferredSkillLevelSegmentedControl.heightAnchor.constraint(equalToConstant: 32),

            // Location
            locationLabel.topAnchor.constraint(equalTo: preferredSkillLevelSegmentedControl.bottomAnchor, constant: 16),
            locationLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),

            locationTextField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            locationTextField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),
            locationTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16),
            locationTextField.heightAnchor.constraint(equalToConstant: 40),

            formContainer.bottomAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 16),

            // Save button
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Error label
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        changeImageButton.addTarget(self, action: #selector(changeImageButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        introductionTextView.delegate = self
    }

    private func bindViewModel() {
        let loadingToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UserProfileViewModelLoadingChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateLoadingState()
        }
        observerTokens.append(loadingToken)

        let profileToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UserProfileViewModelProfileChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateProfileDisplay()
        }
        observerTokens.append(profileToken)

        let errorToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UserProfileViewModelErrorChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateErrorState()
        }
        observerTokens.append(errorToken)
    }

    private func loadProfile() {
        viewModel.fetchProfile()
    }

    private func updateLoadingState() {
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
            scrollView.isHidden = true
            saveButton.isHidden = true
            errorLabel.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
            saveButton.isHidden = false
        }
    }

    private func updateProfileDisplay() {
        guard let profile = viewModel.profileDetail else { return }

        errorLabel.isHidden = true

        // Load profile image
        if let imageUrlStr = profile.profileImageUrl, let imageUrl = URL(string: imageUrlStr) {
            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                }
            }.resume()
        }

        nicknameTextField.text = profile.nickname

        if let bio = profile.bio, !bio.isEmpty {
            introductionTextView.text = bio
            introductionTextView.textColor = .black
        }

        if let positions = profile.preferredPositions {
            preferredPositionTextField.text = positions.joined(separator: ", ")
        }

        if let skillLevel = profile.preferredSkillLevel {
            let segments = ["초급", "중급", "고급", "전문가"]
            let skillMap = ["beginner": 0, "intermediate": 1, "advanced": 2, "expert": 3]
            if let index = skillMap[skillLevel] {
                preferredSkillLevelSegmentedControl.selectedSegmentIndex = index
            } else if let index = segments.firstIndex(of: skillLevel) {
                preferredSkillLevelSegmentedControl.selectedSegmentIndex = index
            }
        }

        locationTextField.text = profile.location
    }

    private func updateErrorState() {
        if let error = viewModel.errorMessage {
            errorLabel.text = "오류: \(error)"
            errorLabel.isHidden = false
            scrollView.isHidden = true
            saveButton.isHidden = true
        } else {
            errorLabel.isHidden = true
        }
    }

    // MARK: - Actions
    @objc private func changeImageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }

    @objc private func manageTeamTapped() {
        navigationController?.pushViewController(MyTeamsViewController(), animated: true)
    }

    @objc private func saveButtonTapped() {
        let nickname = nicknameTextField.text ?? ""

        // Validate nickname length
        if !nickname.isEmpty && (nickname.count < 2 || nickname.count > 50) {
            showAlert(title: "입력 오류", message: "닉네임은 2~50자 사이여야 합니다.")
            return
        }

        let introduction = introductionTextView.text != "소개글을 입력하세요" ? introductionTextView.text : ""

        if let bio = introduction, bio.count > 500 {
            showAlert(title: "입력 오류", message: "소개글은 500자 이하여야 합니다.")
            return
        }

        let position = preferredPositionTextField.text ?? ""
        let skillLevelLabel = preferredSkillLevelSegmentedControl.titleForSegment(at: preferredSkillLevelSegmentedControl.selectedSegmentIndex) ?? ""
        let skillLevelMap: [String: String] = [
            "초급": "beginner",
            "중급": "intermediate",
            "고급": "advanced",
            "전문가": "expert"
        ]
        let skillLevel = skillLevelMap[skillLevelLabel] ?? "intermediate"
        let location = locationTextField.text ?? ""

        viewModel.saveProfile(
            nickname: nickname,
            introduction: introduction,
            position: position,
            skillLevel: skillLevel,
            location: location,
            profileImage: selectedImage
        )

        // Observe for save completion
        let saveToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UserProfileViewModelProfileChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showAlert(title: "저장 완료", message: "프로필이 저장되었습니다.")
        }
        observerTokens.append(saveToken)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension UserProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "소개글을 입력하세요" {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "소개글을 입력하세요"
            textView.textColor = .lightGray
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            profileImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            profileImageView.image = originalImage
        }
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - UserProfileViewModel
class UserProfileViewModel {
    var userProfile: UserProfile?
    var profileDetail: UserProfileDetail?
    var isLoading = false
    var errorMessage: String?

    func fetchProfile() {
        isLoading = true
        errorMessage = nil

        NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelLoadingChanged"), object: nil)

        APIService.shared.getUserProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelLoadingChanged"), object: nil)

                switch result {
                case .success(let response):
                    self?.profileDetail = response.data
                    NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelProfileChanged"), object: nil)

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelErrorChanged"), object: nil)
                }
            }
        }
    }

    func saveProfile(
        nickname: String,
        introduction: String?,
        position: String?,
        skillLevel: String?,
        location: String?,
        profileImage: UIImage?
    ) {
        isLoading = true
        errorMessage = nil

        NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelLoadingChanged"), object: nil)

        let positions = position?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        // 1단계: 프로필 정보 업데이트
        APIService.shared.updateUserProfile(
            nickname: nickname.isEmpty ? nil : nickname,
            bio: introduction,
            preferredPositions: positions,
            preferredSkillLevel: skillLevel,
            location: location?.isEmpty == true ? nil : location
        ) { [weak self] result in
            switch result {
            case .success(let response):
                self?.profileDetail = response.data

                // 2단계: 이미지가 있으면 업로드
                if let image = profileImage {
                    APIService.shared.uploadProfileImage(image: image) { [weak self] imageResult in
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelLoadingChanged"), object: nil)

                            switch imageResult {
                            case .success(let imageResponse):
                                self?.profileDetail = imageResponse.data
                                NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelProfileChanged"), object: nil)

                            case .failure(let error):
                                self?.errorMessage = "프로필 정보는 저장되었으나 이미지 업로드 실패: \(error.localizedDescription)"
                                NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelErrorChanged"), object: nil)
                            }
                        }
                    }
                } else {
                    // 이미지 없으면 바로 완료
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelLoadingChanged"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelProfileChanged"), object: nil)
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isLoading = false
                    NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelLoadingChanged"), object: nil)
                    self?.errorMessage = error.localizedDescription
                    NotificationCenter.default.post(name: NSNotification.Name("UserProfileViewModelErrorChanged"), object: nil)
                }
            }
        }
    }
}
