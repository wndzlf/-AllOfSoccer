//
//  LoginViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/06/13.
//

import UIKit
import AuthenticationServices

class SignInViewController: UIViewController {

    @IBOutlet weak var kakaotalkLogInView: RoundView!
    @IBOutlet weak var appleLogInView: RoundView!

    private let appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .whiteOutline)
        button.addTarget(self, action: #selector(handleAppleSignButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setConstraint()
    }

    private func setConstraint() {

        guard let signInView = self.appleLogInView else { return }

        signInView.addsubviews(self.appleButton)

        NSLayoutConstraint.activate([
            self.appleButton.leadingAnchor.constraint(equalTo: signInView.leadingAnchor, constant: 0),
            self.appleButton.trailingAnchor.constraint(equalTo: signInView.trailingAnchor, constant: 0),
            self.appleButton.topAnchor.constraint(equalTo: signInView.topAnchor, constant: 0),
            self.appleButton.bottomAnchor.constraint(equalTo: signInView.bottomAnchor, constant: 0)
        ])
    }

    @objc func handleAppleSignButton() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email

            // Apple은 최초 로그인에만 이름/이메일을 제공
            let displayName = [fullName?.familyName, fullName?.givenName]
                .compactMap { $0 }
                .joined()
            let nameToSend = displayName.isEmpty ? nil : displayName

            // userIdentifier 로컬 저장
            Auth.updateUserIdentifierKey(userIdentifier: userIdentifier)

            // 서버에 로그인 요청
            APIService.shared.appleSignIn(
                appleId: userIdentifier,
                email: email,
                name: nameToSend
            ) { [weak self] result in
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        Auth.updateAcceessToken(token: data.accessToken)
                        Auth.updateRefreshToken(token: data.refreshToken)
                        self?.navigateToMainScreen()
                    } else {
                        self?.showAlert(message: response.message ?? "로그인에 실패했습니다.")
                    }
                case .failure(let error):
                    print("로그인 실패: \(error)")
                    self?.showAlert(message: "서버 연결에 실패했습니다.")
                }
            }
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple 로그인 실패: \(error)")
        showAlert(message: "로그인에 실패했습니다.")
    }

    private func navigateToMainScreen() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController()
        window.rootViewController = mainVC
        window.makeKeyAndVisible()
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window ?? UIWindow()
    }
}
