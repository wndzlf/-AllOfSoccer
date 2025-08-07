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
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email

            if let authorizationCode = appleIDCredential.authorizationCode,
               let identityToken = appleIDCredential.identityToken,
               let authString = String(data: authorizationCode, encoding: .utf8),
               let tokenString = String(data: identityToken, encoding: .utf8) {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("authString: \(authString)")
                print("tokenString: \(tokenString)")
            }

            print("useridentifier: \(userIdentifier)")
            print("fullName: \(fullName)")
            print("email: \(email)")

            //        case let passwordCredential as ASPasswordCredential:
            //            // Sign in using an existing iCloud Keychain credential.
            //            let username = passwordCredential.user
            //            let password = passwordCredential.password
            //
            //            print("username: \(username)")
            //            print("password: \(password)")
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("로그인에 실패했습니다.")
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window ?? UIWindow()
    }
}
