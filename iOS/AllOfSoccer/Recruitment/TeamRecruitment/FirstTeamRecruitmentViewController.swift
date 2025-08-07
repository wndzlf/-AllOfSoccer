//
//  SecondRecruitmentViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/12.
//

import UIKit

class FirstTeamRecruitmentViewController: UIViewController {

    @IBOutlet weak var sixMatchButton: IBSelectTableButton!
    @IBOutlet weak var elevenMatchButton: IBSelectTableButton!
    @IBOutlet weak var manMatchButton: IBSelectTableButton!
    @IBOutlet weak var womanMatchButton: IBSelectTableButton!
    @IBOutlet weak var mixMatchButton: IBSelectTableButton!
    @IBOutlet weak var futsalShoesButton: IBSelectTableButton!
    @IBOutlet weak var soccerShoesButton: IBSelectTableButton!

    @IBOutlet private weak var timeLabel: UILabel?
    @IBOutlet private weak var priceTextField: UITextField? {
        didSet {
            self.priceTextField?.keyboardType = .numberPad
            self.priceTextField?.delegate = self
        }
    }

    @IBAction private func calendarButtonTouchUp(_ sender: UIButton) {
        let recruitmentCalendarView = RecruitmentCalendarView()
        recruitmentCalendarView.delegate = self
        subviewConstraints(view: recruitmentCalendarView)
    }

    @IBAction private func placeButtonTouchUp(_ sender: UIButton) {
        let searchPlaceView = SearchPlaceView()
        searchPlaceView.delegate = self
        subviewConstraints(view: searchPlaceView)
    }

    @IBAction private func backButtonItemTouchUp(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction private func informationCheckButtonTouchUp(_ sender: IBSelectTableButton) {
        sender.isSelected = sender.isSelected ? false : true

    }

    @IBAction func callPreviousInformationButtonTouchUp(_ sender: UIButton) {
        let callPreviousInformationView = CallPreviusMatchingInformationView()
        callPreviousInformationView.delegate = self
        subviewConstraints(view: callPreviousInformationView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dismissKeyboard()
        setMatchButton()
    }

    private func setMatchButton() {
        [self.sixMatchButton, self.elevenMatchButton, self.manMatchButton, self.womanMatchButton, self.mixMatchButton, self.futsalShoesButton, self.soccerShoesButton].forEach { $0.addTarget(self, action: #selector(matchButtonTouchUp), for: .touchUpInside)
        }
    }

    private func subviewConstraints(view: UIView) {
        guard let navigationController = self.navigationController else { return }
        navigationController.view.addsubviews(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: navigationController.view.topAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor, constant: 0)
        ])
    }

    @objc func matchButtonTouchUp(_ sender: UIButton) {
        sender.isSelected = sender.isSelected ? false : true
    }
}

extension FirstTeamRecruitmentViewController:
    RecruitmentCalendarViewDelegate {

    func cancelButtonDidSelected(_ view: RecruitmentCalendarView) {
        view.removeFromSuperview()
    }

    func okButtonDidSelected(_ view: RecruitmentCalendarView, selectedDate: String) {
        self.timeLabel?.text = selectedDate
        view.removeFromSuperview()
    }
}

extension FirstTeamRecruitmentViewController: SearchPlaceViewDelegate {
    func cancelButtonDidSelected(_ view: SearchPlaceView) {
        view.removeFromSuperview()
    }

    func okButtonDidSelected(_ view: SearchPlaceView) {
        view.removeFromSuperview()
    }
}

extension FirstTeamRecruitmentViewController: CallPreviusMatchingInformationViewDelegate {

    func cancelButtonDidSelected(_ view: CallPreviusMatchingInformationView) {
        view.removeFromSuperview()
    }
    func OKButtonDidSelected(_ view: CallPreviusMatchingInformationView) {
        view.removeFromSuperview()
    }
}

extension FirstTeamRecruitmentViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.keyboardWillAppear()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension FirstTeamRecruitmentViewController {

    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
}

extension FirstTeamRecruitmentViewController {

    private func keyboardWillAppear() {

    }

    private func keyboardWillDisapper() {

    }
}
