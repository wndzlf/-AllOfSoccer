//
//  MyPageChangeTeamInfoViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/20.
//

import UIKit
import ContactsUI

class MyPageChangeTeamInfoViewController: UIViewController {
    
    // MARK: - UI Components
    private let teamNameLabel = UILabel()
    private let teamNameContainerView = UIView()
    private let teamNameIcon = UIImageView()
    private let teamNameTextField = UITextField()

    private let ageLabel = UILabel()
    private let ageSlider = OneThumbSlider()
    private var ageSliderLabels: [UILabel] = []
    
    private let skillLabel = UILabel()
    private let skillSlider = OneThumbSlider()
    private var skillSliderLabels: [UILabel] = []
    
    private let contactLabel = UILabel()
    private let contactContainerView = UIView()
    private let contactIcon = UIImageView()
    private let contactTextField = UITextField()
    
    private let saveButton = UIButton()
    
    private var selectedContact: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.965, green: 0.969, blue: 0.980, alpha: 1.0)
        navigationController?.navigationBar.topItem?.title = "팀 정보 변경"
        
        setupUI()
        setupTextFields()
        setupContactPicker()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Team Name Label
        teamNameLabel.text = "팀이름"
        teamNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        view.addSubview(teamNameLabel)
        
        // Team Name Container
        teamNameContainerView.backgroundColor = .white
        teamNameContainerView.layer.cornerRadius = 6
        view.addSubview(teamNameContainerView)
        
        // Team Name Icon
        teamNameIcon.image = UIImage(systemName: "person.crop.circle")
        teamNameIcon.tintColor = .black
        teamNameIcon.contentMode = .scaleAspectFit
        teamNameContainerView.addSubview(teamNameIcon)
        
        // Team Name TextField
        teamNameTextField.placeholder = "팀이름을 적어주세요."
        teamNameTextField.font = UIFont.systemFont(ofSize: 17)
        teamNameTextField.textColor = .black
        teamNameContainerView.addSubview(teamNameTextField)
        
        // Age Label
        ageLabel.text = "나이대"
        ageLabel.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(ageLabel)
        
        // Age Slider
        ageSlider.minimumValue = 10
        ageSlider.maximumValue = 70
        ageSlider.value = 70
        ageSlider.minimumTrackTintColor = UIColor(red: 0.925, green: 0.925, blue: 0.925, alpha: 1.0)
        ageSlider.maximumTrackTintColor = UIColor(red: 0.925, green: 0.925, blue: 0.925, alpha: 1.0)
        ageSlider.thumbTintColor = UIColor(red: 0.925, green: 0.373, blue: 0.373, alpha: 0.0)
        view.addSubview(ageSlider)
        
        // Age Slider Labels
        let ageValues = ["10", "20", "30", "40", "50", "60", "70"]
        for value in ageValues {
            let label = UILabel()
            label.text = value
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(red: 0.439, green: 0.439, blue: 0.439, alpha: 1.0)
            label.textAlignment = .center
            ageSliderLabels.append(label)
            view.addSubview(label)
        }
        
        // Skill Label
        skillLabel.text = "실력"
        skillLabel.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(skillLabel)
        
        // Skill Slider
        skillSlider.minimumValue = 10
        skillSlider.maximumValue = 70
        skillSlider.value = 40
        skillSlider.minimumTrackTintColor = UIColor(red: 0.925, green: 0.925, blue: 0.925, alpha: 1.0)
        skillSlider.maximumTrackTintColor = UIColor(red: 0.925, green: 0.925, blue: 0.925, alpha: 1.0)
        skillSlider.thumbTintColor = UIColor(red: 0.925, green: 0.373, blue: 0.373, alpha: 0.0)
        view.addSubview(skillSlider)
        
        // Skill Slider Labels
        let skillValues = ["최하", "하", "중하", "중", "중상", "상", "최상"]
        for value in skillValues {
            let label = UILabel()
            label.text = value
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(red: 0.439, green: 0.439, blue: 0.439, alpha: 1.0)
            label.textAlignment = .center
            skillSliderLabels.append(label)
            view.addSubview(label)
        }
        
        // Contact Label
        contactLabel.text = "연락처"
        contactLabel.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(contactLabel)
        
        // Contact Container
        contactContainerView.backgroundColor = .white
        contactContainerView.layer.cornerRadius = 6
        view.addSubview(contactContainerView)
        
        // Contact Icon (placeholder, will be set later if needed)
        contactIcon.contentMode = .scaleAspectFit
        contactContainerView.addSubview(contactIcon)
        
        // Contact TextField
        contactTextField.placeholder = "대표 연락처를 입력해주세요."
        contactTextField.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        contactContainerView.addSubview(contactTextField)
        
        // Save Button
        saveButton.setTitle("저장하기", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = UIColor(red: 0.925, green: 0.373, blue: 0.373, alpha: 1.0)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        view.addSubview(saveButton)
    }
    
    private func layoutUI() {
        let safeArea = view.safeAreaInsets
        let screenWidth = view.bounds.width
        
        // Team Name Label
        teamNameLabel.frame = CGRect(x: 16, y: safeArea.top + 20, width: 100, height: 20)
        
        // Team Name Container
        teamNameContainerView.frame = CGRect(x: 16, y: teamNameLabel.frame.maxY + 12, width: screenWidth - 82, height: 50)
        
        // Team Name Icon
        teamNameIcon.frame = CGRect(x: 16, y: 16, width: 18, height: 18)
        
        // Team Name TextField
        teamNameTextField.frame = CGRect(x: 44, y: 14, width: teamNameContainerView.frame.width - 54, height: 22)
        
        // Profile Image Container
        
        // Profile Image
        
        // Camera Button
        
        // Age Label
        ageLabel.frame = CGRect(x: 16, y: teamNameContainerView.frame.maxY + 20, width: 100, height: 20)
        
        // Age Slider
        ageSlider.frame = CGRect(x: 16, y: ageLabel.frame.maxY + 12, width: screenWidth - 32, height: 30)
        
        // Age Slider Labels
        let agePositions = createLabelXPositions(slider: ageSlider)
        for (index, label) in ageSliderLabels.enumerated() {
            label.sizeToFit()
            let centerX = ageSlider.frame.minX + agePositions[index]
            label.frame = CGRect(x: centerX - label.frame.width / 2,
                                y: ageSlider.frame.maxY + 4,
                                width: label.frame.width,
                                height: label.frame.height)
        }
        
        // Skill Label
        skillLabel.frame = CGRect(x: 16, y: ageSliderLabels[0].frame.maxY + 20, width: 100, height: 20)
        
        // Skill Slider
        skillSlider.frame = CGRect(x: 16, y: skillLabel.frame.maxY + 12, width: screenWidth - 32, height: 30)
        
        // Skill Slider Labels
        let skillPositions = createLabelXPositions(slider: skillSlider)
        for (index, label) in skillSliderLabels.enumerated() {
            label.sizeToFit()
            let centerX = skillSlider.frame.minX + skillPositions[index]
            label.frame = CGRect(x: centerX - label.frame.width / 2,
                                y: skillSlider.frame.maxY + 4,
                                width: label.frame.width,
                                height: label.frame.height)
        }
        
        // Contact Label
        contactLabel.frame = CGRect(x: 16, y: skillSliderLabels[0].frame.maxY + 20, width: 100, height: 20)
        
        // Contact Container
        contactContainerView.frame = CGRect(x: 16, y: contactLabel.frame.maxY + 12, width: screenWidth - 32, height: 50)
        
        // Contact Icon
        contactIcon.frame = CGRect(x: 16, y: 16, width: 18, height: 18)
        
        // Contact TextField
        contactTextField.frame = CGRect(x: 44, y: 16, width: contactContainerView.frame.width - 54, height: 18.5)
        
        // Save Button
        saveButton.frame = CGRect(x: 0, y: view.bounds.height - safeArea.bottom - 62, width: screenWidth, height: 62)
    }
    
    private func createLabelXPositions(slider: UISlider) -> [CGFloat] {
        // Get the actual thumb size
        let thumbWidth = slider.currentThumbImage?.size.width ?? 28
        let thumbRadius = thumbWidth / 2
        
        // Calculate the actual track width (excluding thumb)
        let trackWidth = slider.frame.width - thumbWidth
        
        // Calculate spacing between each tick (6 intervals for 7 labels)
        let intervalWidth = trackWidth / 6
        
        // Starting position (center of first tick)
        let startX = thumbRadius
        
        var labelPositions: [CGFloat] = []
        
        // Calculate position for each label (7 labels total)
        for index in 0..<7 {
            let tickCenterX = startX + (intervalWidth * CGFloat(index))
            labelPositions.append(tickCenterX)
        }
        
        return labelPositions
    }
    
    // MARK: - Text Field Setup
    private func setupTextFields() {
        teamNameTextField.delegate = self
        contactTextField.delegate = self
        
        // Add done button to keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        
        teamNameTextField.inputAccessoryView = toolbar
        contactTextField.inputAccessoryView = toolbar
    }
    
    private func setupContactPicker() {
        // Add tap gesture to contact field to open contact picker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openContactPicker))
        contactTextField.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func openContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        present(contactPicker, animated: true)
    }
    
    @objc private func saveButtonTapped(_ sender: UIButton) {
        // Validate inputs
        guard let teamName = teamNameTextField.text, !teamName.isEmpty else {
            showAlert(message: "팀 이름을 입력해주세요.")
            return
        }
        
        guard let contact = contactTextField.text, !contact.isEmpty else {
            showAlert(message: "연락처를 입력해주세요.")
            return
        }
        
        // TODO: Save team information to backend
        // For now, just show success message
        showAlert(message: "팀 정보가 저장되었습니다.") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension MyPageChangeTeamInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == teamNameTextField {
            contactTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Prevent keyboard from showing for contact field, show picker instead
        if textField == contactTextField {
            openContactPicker()
            return false
        }
        return true
    }
}

// MARK: - CNContactPickerDelegate
extension MyPageChangeTeamInfoViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // Extract phone number from selected contact
        if let phoneNumber = contact.phoneNumbers.first {
            let number = phoneNumber.value.stringValue
            contactTextField.text = number
            selectedContact = number
        }
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        // User cancelled contact selection
        picker.dismiss(animated: true)
    }
}
