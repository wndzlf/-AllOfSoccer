//
//  TableViewFilterringView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/01.
//

import UIKit

enum SortMode: Int {
    case distance
    case registration
    case dateAndTime

    var sortModeTitle: String {
        switch self {
        case .distance: return "거리순"
        case .registration: return "최신 등록순"
        case .dateAndTime: return "경기 날짜/시간순"
        }
    }
}

protocol TableViewFilterViewDelegate: AnyObject {
    func cancelButtonDidSelected(sender: TableViewFilterView)
    func okButtonDidSelected(sender: TableViewFilterView, sortMode: SortMode)
}

class TableViewFilterView: UIView {

    weak var delegate: TableViewFilterViewDelegate?

    private var sortMode: SortMode?

    private var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 12

        return view
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "정렬기준"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)

        return label
    }()

    private var firstSelectableButton: SeletableButton = {
        let button = SeletableButton()
        button.setTitle(SortMode.distance.sortModeTitle, for: .normal)
        button.normalImage = UIImage(systemName: "checkmark.circle")
        button.selectImage = UIImage(systemName: "checkmark.circle.fill")
        button.normalBackgroundColor = UIColor.clear
        button.selectBackgroundColor = UIColor.clear
        button.normalBorderColor = UIColor.clear
        button.selectBorderColor = UIColor.clear
        button.normalTintColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
        button.selectTintColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.normalTitleColor = UIColor.black
        button.selectTitleColor = UIColor.black
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left

        button.addTarget(self, action: #selector(firstSelectableButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private var secondSelectableButton: SeletableButton = {
        let button = SeletableButton()
        button.setTitle(SortMode.registration.sortModeTitle, for: .normal)
        button.normalImage = UIImage(systemName: "checkmark.circle")
        button.selectImage = UIImage(systemName: "checkmark.circle.fill")
        button.normalBackgroundColor = UIColor.clear
        button.selectBackgroundColor = UIColor.clear
        button.normalBorderColor = UIColor.clear
        button.selectBorderColor = UIColor.clear
        button.normalTintColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
        button.selectTintColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.normalTitleColor = UIColor.black
        button.selectTitleColor = UIColor.black
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left

        button.addTarget(self, action: #selector(secondSelectableButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private var thirdSelectableButton: SeletableButton = {
        let button = SeletableButton()
        button.setTitle(SortMode.dateAndTime.sortModeTitle, for: .normal)
        button.normalImage = UIImage(systemName: "checkmark.circle")
        button.selectImage = UIImage(systemName: "checkmark.circle.fill")
        button.normalBackgroundColor = UIColor.clear
        button.selectBackgroundColor = UIColor.clear
        button.normalBorderColor = UIColor.clear
        button.selectBorderColor = UIColor.clear
        button.normalTintColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
        button.selectTintColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.normalTitleColor = UIColor.black
        button.selectTitleColor = UIColor.black
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left

        button.addTarget(self, action: #selector(thirdSelectableButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private lazy var selectableButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.firstSelectableButton, self.secondSelectableButton, self.thirdSelectableButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually

        return stackView
    }()

    private var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(UIColor.black, for: .normal)
        let backgroundColor = UIColor(red: 246/255, green: 247/255, blue: 250/255, alpha: 1)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true

        button.addTarget(self, action: #selector(cancelButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private var okButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("선택", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(UIColor.white, for: .normal)
        let backgroundColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true

        button.addTarget(self, action: #selector(okButtonTouchUp), for: .touchUpInside)

        return button
    }()

    lazy private var okAndCancelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.cancelButton, self.okButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually

        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }

    private func loadView() {

        setSuperView()
        setViewConstraint()
    }

    private func setSuperView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }

    private func setViewConstraint() {

        self.addsubviews(self.baseView)
        self.baseView.addsubviews(self.okAndCancelStackView, self.titleLabel, self.selectableButtonStackView)

        NSLayoutConstraint.activate([

            self.baseView.widthAnchor.constraint(equalToConstant: 336),
            self.baseView.heightAnchor.constraint(equalToConstant: 276),
            self.baseView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.baseView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            self.okAndCancelStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),
            self.okAndCancelStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -32),
            self.okAndCancelStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -24),
            self.okAndCancelStackView.heightAnchor.constraint(equalToConstant: 40),

            self.titleLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 24),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 29),

            self.selectableButtonStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 28),
            self.selectableButtonStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 28)
        ])
    }

    @objc func firstSelectableButtonTouchUp(_ sender: SeletableButton) {
        self.sortMode = SortMode.distance

        sender.isSelected = sender.isSelected ? false : true

        if sender.isSelected {
            self.secondSelectableButton.isSelected = false
            self.thirdSelectableButton.isSelected = false
        }
    }

    @objc func secondSelectableButtonTouchUp(_ sender: SeletableButton) {
        self.sortMode = SortMode.registration

        sender.isSelected = sender.isSelected ? false : true

        if sender.isSelected {
            self.firstSelectableButton.isSelected = false
            self.thirdSelectableButton.isSelected = false
        }
    }

    @objc func thirdSelectableButtonTouchUp(_ sender: SeletableButton) {
        self.sortMode = SortMode.dateAndTime

        sender.isSelected = sender.isSelected ? false : true

        if sender.isSelected {
            self.firstSelectableButton.isSelected = false
            self.secondSelectableButton.isSelected = false
        }
    }

    @objc private func cancelButtonTouchUp(sender: UIButton) {
        self.delegate?.cancelButtonDidSelected(sender: self)
    }

    @objc private func okButtonTouchUp(sender: UIButton) {
        guard let sortMode = self.sortMode else { return }
        self.delegate?.okButtonDidSelected(sender: self, sortMode: sortMode)
    }
}
