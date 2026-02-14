//
//  MyPageViewController.swift
//  AllOfSoccer
//

import UIKit
import MessageUI

class MyPageViewController: UIViewController {
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

    private let menuContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var myWritingButton: UIButton = makeMenuButton(title: "내가 쓴 글", icon: "square.and.pencil")
    private lazy var favoritesButton: UIButton = makeMenuButton(title: "관심 글", icon: "heart")
    private lazy var teamsButton: UIButton = makeMenuButton(title: "내 팀 관리", icon: "person.3")
    private lazy var profileButton: UIButton = makeMenuButton(title: "프로필 설정", icon: "person.crop.circle.badge.checkmark")
    private lazy var questionsButton: UIButton = makeMenuButton(title: "문의하기", icon: "envelope")
    private lazy var logoutButton: UIButton = {
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
        title = "마이페이지"
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)

        setupLayout()
        setupActions()
        fetchUserProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserProfile()
    }

    private func setupLayout() {
        view.addSubview(profileContainerView)
        profileContainerView.addSubview(profileImageView)
        profileContainerView.addSubview(nameLabel)
        profileContainerView.addSubview(emailLabel)

        view.addSubview(menuContainer)
        [myWritingButton, favoritesButton, teamsButton, profileButton, questionsButton, logoutButton].forEach { menuContainer.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            profileContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            profileContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileContainerView.heightAnchor.constraint(equalToConstant: 150),

            profileImageView.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 20),
            profileImageView.centerYAnchor.constraint(equalTo: profileContainerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -20),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            menuContainer.topAnchor.constraint(equalTo: profileContainerView.bottomAnchor, constant: 20),
            menuContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            menuContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        [myWritingButton, favoritesButton, teamsButton, profileButton, questionsButton, logoutButton].forEach { button in
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }

    private func setupActions() {
        myWritingButton.addTarget(self, action: #selector(myWritingTapped), for: .touchUpInside)
        favoritesButton.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
        teamsButton.addTarget(self, action: #selector(teamsTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        questionsButton.addTarget(self, action: #selector(questionsButtonDidSelected), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }

    private func makeMenuButton(title: String, icon: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("  \(title)", for: .normal)
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.tintColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func fetchUserProfile() {
        APIService.shared.getProfile { [weak self] result in
            switch result {
            case .success(let profile):
                self?.userProfile = profile
                self?.updateProfileUI(profile)
            case .failure:
                self?.nameLabel.text = "사용자"
                self?.emailLabel.text = "이메일 정보 없음"
            }
        }
    }

    private func updateProfileUI(_ profile: UserProfile) {
        nameLabel.text = profile.name
        emailLabel.text = profile.email ?? "이메일 정보 없음"

        if let imageUrlString = profile.profileImage, let imageUrl = URL(string: imageUrlString) {
            loadProfileImage(from: imageUrl)
        }
    }

    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        }.resume()
    }

    @objc private func myWritingTapped() {
        navigationController?.pushViewController(MyWritingViewController(), animated: true)
    }

    @objc private func favoritesTapped() {
        navigationController?.pushViewController(MyFavoritesViewController(), animated: true)
    }

    @objc private func teamsTapped() {
        navigationController?.pushViewController(MyTeamsViewController(), animated: true)
    }

    @objc private func profileTapped() {
        navigationController?.pushViewController(UserProfileViewController(), animated: true)
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
        APIService.shared.logout { [weak self] _ in
            Auth.clearAll()
            DispatchQueue.main.async {
                self?.navigateToLoginScreen()
            }
        }
    }

    private func navigateToLoginScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        let loginVC = UINavigationController(rootViewController: SignInViewController())

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = loginVC
        })
    }

    @objc private func questionsButtonDidSelected() {
        let recipient = "cws653@naver.com"

        guard MFMailComposeViewController.canSendMail() else {
            let encodedSubject = "탭탭매칭 문의 하기".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let encodedBody = "탭탭매칭 개발팀에게 전하고 싶은 것들을 보내주세요".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "mailto:\(recipient)?subject=\(encodedSubject)&body=\(encodedBody)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                let alert = UIAlertController(
                    title: "메일 앱 설정 필요",
                    message: "메일 앱을 설정한 뒤 다시 시도해주세요.\n문의 메일: \(recipient)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                alert.addAction(UIAlertAction(title: "메일 주소 복사", style: .default, handler: { _ in
                    UIPasteboard.general.string = recipient
                }))
                present(alert, animated: true)
            }
            return
        }

        let mailComposerViewController = MFMailComposeViewController()
        mailComposerViewController.mailComposeDelegate = self
        mailComposerViewController.setToRecipients([recipient])
        mailComposerViewController.setSubject("탭탭매칭 문의 하기")
        mailComposerViewController.setMessageBody("탭탭매칭 개발팀에게 전하고 싶은 것들을 보내주세요 🥳", isHTML: false)
        present(mailComposerViewController, animated: true)
    }
}

extension MyPageViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
