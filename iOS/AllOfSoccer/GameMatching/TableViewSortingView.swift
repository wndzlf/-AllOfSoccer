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

protocol TableViewSortingViewDelegate: AnyObject {
    func sortingFinishButtonTapped(button: UIButton, sortMode: SortMode)
}

class TableViewSortingView: UIView {

    weak var delegate: TableViewSortingViewDelegate?

    private var sortMode: SortMode?
    private var firstCheckButton = UIButton()
    private var secondCheckButton = UIButton()
    private var thirdCheckButton = UIButton()
    private var tableViewSortingFinishButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "tagBackTouchUpColor")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("선택하기", for: .normal)

        button.addTarget(self, action: #selector(sortingFinishButtonTouchUp), for: .touchUpInside)
        return button
    }()

    private lazy var tableViewSortingContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.textColor = .black
        titleLabel.text = "정렬기준"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)

        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])

        self.firstCheckButton = checkButton(SortMode.distance)
        self.secondCheckButton = checkButton(SortMode.registration)
        self.thirdCheckButton = checkButton(SortMode.dateAndTime)

        let stackView = UIStackView(arrangedSubviews: [firstCheckButton, secondCheckButton, thirdCheckButton])
        stackView.axis = .vertical
        stackView.spacing = 23
        stackView.distribution = .fillEqually

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 19)
        ])

        return view
    }()

    private func checkButton(_ sortMode: SortMode) -> UIButton {
        let button = UIButton()

        let nonCheckedBoxImage = UIImage(systemName: "checkmark.circle")
        let checkedBoxImage = UIImage(systemName: "checkmark.circle.fill")
        button.setImage(nonCheckedBoxImage, for: .normal)
        button.setImage(checkedBoxImage, for: .selected)
        button.tintColor = UIColor(named: "checkBoxTintColor_NoneChecked")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(.black, for: .normal)
        button.setTitle(sortMode.sortModeTitle, for: .normal)
        button.contentHorizontalAlignment = .left
        button.tag = sortMode.rawValue
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)

        button.addTarget(self, action: #selector(checkButtonTouchUp), for: .touchUpInside)

        return button
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }

    private func loadView() {
        let tableViewSortingCheckButton = tableViewSortingFinishButton
        self.addSubview(tableViewSortingCheckButton)
        tableViewSortingCheckButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableViewSortingCheckButton.widthAnchor.constraint(equalTo: self.widthAnchor),
            tableViewSortingCheckButton.heightAnchor.constraint(equalToConstant: 63),
            tableViewSortingCheckButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])

        let tableViewSortingContentView = tableViewSortingContentView
        tableViewSortingContentView.backgroundColor = .white
        self.addSubview(tableViewSortingContentView)
        tableViewSortingContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableViewSortingContentView.widthAnchor.constraint(equalTo: self.widthAnchor),
            tableViewSortingContentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            tableViewSortingContentView.bottomAnchor.constraint(equalTo: tableViewSortingCheckButton.topAnchor, constant: 0)
        ])
    }

    @objc private func checkButtonTouchUp(sender: UIButton) {
        if sender.isSelected {
            self.sortMode = nil
            sender.tintColor = UIColor(named: "checkBoxTintColor_NoneChecked")
            sender.isSelected = false
        } else {
            if sender.tag == SortMode.distance.rawValue {
                self.sortMode = .distance
                self.secondCheckButton.isSelected = false
                self.thirdCheckButton.isSelected = false

                self.secondCheckButton.tintColor = UIColor(named: "checkBoxTintColor_NoneChecked")
                self.thirdCheckButton.tintColor = UIColor(named: "checkBoxTintColor_NoneChecked")
            } else if sender.tag == SortMode.registration.rawValue {
                self.sortMode = .registration
                self.firstCheckButton.isSelected = false
                self.thirdCheckButton.isSelected = false

                self.firstCheckButton.tintColor = UIColor(named: "checkBoxTintColor_NoneChecked")
                self.thirdCheckButton.tintColor = UIColor(named: "checkBoxTintColor_NoneChecked")
            } else if sender.tag == SortMode.dateAndTime.rawValue {
                self.sortMode = .dateAndTime
                self.firstCheckButton.isSelected = false
                self.secondCheckButton.isSelected = false

                self.firstCheckButton.tintColor = UIColor(named: "checkBoxTintColor_NoneChecked")
                self.secondCheckButton.tintColor = UIColor(named: "checkBoxTintColor_NoneChecked")
            }

            sender.tintColor = UIColor(named: "tagBackTouchUpColor")
            sender.isSelected = true
        }
    }

    @objc private func sortingFinishButtonTouchUp(sender: UIButton) {
        guard let sortMode = self.sortMode else { return }
        self.delegate?.sortingFinishButtonTapped(button: sender, sortMode: sortMode)
    }
}
