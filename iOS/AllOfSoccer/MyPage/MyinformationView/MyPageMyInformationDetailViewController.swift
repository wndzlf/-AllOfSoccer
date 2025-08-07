//
//  MyPageMyInformationDetailViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/16.
//

import UIKit

class MyPageMyInformationDetailViewController: UIViewController {

    @IBOutlet private weak var myImageView: UIImageView!
    @IBOutlet private weak var cameraButton: RoundButton!

    @IBOutlet private weak var ageSlider: OneThumbSlider!
    @IBOutlet private var ageSliderLabels: [UILabel]!

    @IBOutlet private weak var skillSlider: OneThumbSlider!
    @IBOutlet private var skillSliderLabels: [UILabel]!


    @IBOutlet private weak var phoneNumberTextField: UITextField!

    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setCameraButton()
        setPhoneNumberTextField()
        setAgeSlider()
        setSkillSlider()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setAgeSliderLabelsLayout()
        setSkillSliderLabelsLayout()
    }

    private func setCameraButton() {
        self.cameraButton.addTarget(self, action: #selector(cameraButtonDidSelected), for: .touchUpInside)
    }

    private func setPhoneNumberTextField() {
        self.phoneNumberTextField.delegate = self
    }

    private func setAgeSlider() {
        self.ageSlider.addTarget(self, action: #selector(ageSliderValueChanged), for: .valueChanged)
    }

    private func setSkillSlider() {
        self.skillSlider.addTarget(self, action: #selector(skillSliderValueChanged), for: .valueChanged)
    }

    private func setAgeSliderLabelsLayout() {
        let ageSliderLabelsXPosition = createLabelXPositions(slider: self.ageSlider)
        setupLabelConstraint(labelXPositons: ageSliderLabelsXPosition, slider: self.ageSlider ,labels: self.ageSliderLabels)
    }

    private func setSkillSliderLabelsLayout() {
        let skillSliderLabelsXPosition = createLabelXPositions(slider: self.skillSlider)
        setupLabelConstraint(labelXPositons: skillSliderLabelsXPosition, slider: self.skillSlider, labels: self.skillSliderLabels)
    }

    private func setupLabelConstraint(labelXPositons: [CGFloat],slider: UISlider, labels: [UILabel]) {
        for index in 0..<labels.count {
            guard let label = labels[safe: index] else { return }
            guard let labelPosition = labelXPositons[safe: index] else { return }
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 4),
                label.centerXAnchor.constraint(equalTo: slider.leadingAnchor, constant: labelPosition)
            ])
        }
    }

    private func createLabelXPositions(slider: UISlider) -> [CGFloat] {
        let sliderLinePadding: CGFloat = (((slider.currentThumbImage?.size.width) ?? 1) / 2)
        let sliderLineWidth = slider.frame.width - ((sliderLinePadding) * 2)
        let offset = (sliderLineWidth / 6)
        let firstLabelXPosition = sliderLinePadding - 2

        var arrayLabelXPosition: [CGFloat] = []
        arrayLabelXPosition.append(firstLabelXPosition)
        for index in 1..<7 {
            let offset = (offset * CGFloat(index))
            let labelXPosition = firstLabelXPosition + offset
            arrayLabelXPosition.append(labelXPosition)
        }

        return arrayLabelXPosition
    }

    @objc private func cameraButtonDidSelected(sender: UIButton) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }

    @objc private func ageSliderValueChanged(sender: UISlider) {
        print(sender.value)
    }

    @objc private func skillSliderValueChanged(sender: UISlider) {
        print(sender.value)
    }
}

extension MyPageMyInformationDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.myImageView.image = originalImage
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension MyPageMyInformationDetailViewController: UITextFieldDelegate {
}
