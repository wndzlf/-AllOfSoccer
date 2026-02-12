//
//  MyPageViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/04.
//

import UIKit
import MessageUI

class MyPageViewController: UIViewController {

    @IBOutlet private weak var mywritingButton: UIButton!
    @IBOutlet private weak var myfavoriteButton: UIButton!
    @IBOutlet private weak var questionsButton: UIButton!

    // 프로필 섹션
    private let profileContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.text = "사용자"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.text = "이메일 정보 없음"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var userProfile: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupProfileSection()
        setWritingButton()
        setFavoriteButton()
        setQuestionsButton()
        setMailComposeView()
        fetchUserProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 프로필 정보 갱신
        fetchUserProfile()
    }

    private func setupProfileSection() {
        view.addSubview(profileContainerView)
        profileContainerView.addSubview(profileImageView)
        profileContainerView.addSubview(nameLabel)
        profileContainerView.addSubview(emailLabel)
        profileContainerView.addSubview(logoutButton)

        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            profileContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            profileContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileContainerView.heightAnchor.constraint(equalToConstant: 200),

            profileImageView.topAnchor.constraint(equalTo: profileContainerView.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -20),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            logoutButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            logoutButton.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func fetchUserProfile() {
        APIService.shared.getProfile { [weak self] result in
            switch result {
            case .success(let profile):
                self?.userProfile = profile
                self?.updateProfileUI(profile)
            case .failure(let error):
                print("프로필 가져오기 실패: \(error)")
                // 실패해도 기본 UI는 표시
            }
        }
    }

    private func updateProfileUI(_ profile: UserProfile) {
        nameLabel.text = profile.name
        emailLabel.text = profile.email ?? "이메일 정보 없음"

        // 프로필 이미지 로드 (URL이 있는 경우)
        if let imageUrlString = profile.profileImage, let imageUrl = URL(string: imageUrlString) {
            loadProfileImage(from: imageUrl)
        }
    }

    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        }.resume()
    }

    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        APIService.shared.logout { [weak self] result in
            // 서버 응답과 관계없이 로컬 토큰 삭제
            Auth.clearAll()

            // 로그인 화면으로 전환
            DispatchQueue.main.async {
                self?.navigateToLoginScreen()
            }
        }
    }

    private func navigateToLoginScreen() {
        guard let window = UIApplication.shared.windows.first else { return }

        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
        let loginVC = storyboard.instantiateInitialViewController()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = loginVC
        })
    }

    private func setWritingButton() {
        self.mywritingButton.centerVertically(4)
    }

    private func setFavoriteButton() {
        self.myfavoriteButton.centerVertically(4)
    }

    private func setQuestionsButton() {
        self.questionsButton.addTarget(self, action: #selector(questionsButtonDidSelected), for: .touchUpInside)
    }

    private func setMailComposeView() {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
    }

    @objc private func questionsButtonDidSelected(sender: UIButton) {

        let mailComposerViewController = configureMailComposeController()
        self.present(mailComposerViewController, animated: true, completion: nil)
    }

    private func configureMailComposeController() -> MFMailComposeViewController {
        let mailComposerViewController = MFMailComposeViewController()
        mailComposerViewController.mailComposeDelegate = self
        mailComposerViewController.setToRecipients(["cws653@naver.com"])
        mailComposerViewController.setSubject("탭탭매칭 문의 하기")
        mailComposerViewController.setMessageBody("탭탭매칭 개발팀에게 전하고 싶은 것들을 보내주세요 🥳", isHTML: false)

        return mailComposerViewController
    }
}

extension MyPageViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
