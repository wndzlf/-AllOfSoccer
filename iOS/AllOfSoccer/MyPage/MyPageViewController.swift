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

    override func viewDidLoad() {
        super.viewDidLoad()

        setWritingButton()
        setFavoriteButton()
        setQuestionsButton()
        setMailComposeView()
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
