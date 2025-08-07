//
//  callPreviusMatchingInformationView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/11.
//

import UIKit

protocol CallPreviusMatchingInformationViewDelegate: AnyObject {
    func cancelButtonDidSelected(_ view: CallPreviusMatchingInformationView)
    func OKButtonDidSelected(_ view: CallPreviusMatchingInformationView)
}

class CallPreviusMatchingInformationView: UIView {

    weak var delegate: CallPreviusMatchingInformationViewDelegate?
    private var commentsModel: [Comment] = []

    private var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12

        return view
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "이전 글 불러오기"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black

        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CallPreviusMatchingInformationTableViewCell.self, forCellReuseIdentifier: "CallPreviusMatchingInformationTableViewCell")

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.allowsSelection = false

        return tableView
    }()


    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 246/255, green: 247/255, blue: 250/255, alpha: 1).cgColor
        button.clipsToBounds = true
        button.setBackgroundColor(UIColor(red: 246/255, green: 247/255, blue: 250/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonDidSelected), for: .touchUpInside)

        return button
    }()

    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("선택", for: .normal)
        button.setBackgroundColor(UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1).cgColor
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(OKButtonDidSelected), for: .touchUpInside)

        return button
    }()

    private lazy var OKCancelButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, okButton])

        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()

    @objc func cancelButtonDidSelected(sender: UIButton) {
        print("cancelButton이 클릭되었습니다")
        self.delegate?.cancelButtonDidSelected(self)
    }

    @objc func OKButtonDidSelected(sender: UIButton) {
        print("OKButton이 클릭되었습니다")
//        self.commentsModel = self.commentsButtons.filter { $0.isSelected }.compactMap { Comment(rawValue: $0.tag) }
        self.delegate?.OKButtonDidSelected(self)
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

        setSuperView()
        setTableView()
        setConstraint()
    }

    private func setSuperView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }

    private func setTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    private func setConstraint() {
        self.addsubviews(self.baseView)
        self.baseView.addsubviews(self.titleLabel, self.tableView, self.OKCancelButtonStackView)

        NSLayoutConstraint.activate([

            self.baseView.topAnchor.constraint(equalTo: self.topAnchor, constant: 167),
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -167),

            self.titleLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 30),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),

            self.OKCancelButtonStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),
            self.OKCancelButtonStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -32),
            self.OKCancelButtonStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -24),
            self.OKCancelButtonStackView.heightAnchor.constraint(equalToConstant: 40),

            self.tableView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 14),
            self.tableView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),
            self.tableView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -32),
            self.tableView.bottomAnchor.constraint(equalTo: self.OKCancelButtonStackView.topAnchor, constant: -14)
        ])
    }
}

extension CallPreviusMatchingInformationView: UITableViewDelegate {

}

extension CallPreviusMatchingInformationView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CallPreviusMatchingInformationTableViewCell", for: indexPath) as? CallPreviusMatchingInformationTableViewCell else { return UITableViewCell() }

        return cell
    }
}
