

import UIKit

protocol DeleteTeamInformationViewDelegate: AnyObject {
    func cancelButtonDidSelected(_ view: DeleteTeamInformationView)
}

class DeleteTeamInformationView: UIView {

    weak var delegate: DeleteTeamInformationViewDelegate?

    private var tableViewModel: [TeamInfo] = []

    private var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12

        return view
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "팀 생성은 3개까지 가능합니다."
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black

        return label
    }()

    private var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "저장을 위해 팀을 하나 이상 삭제해야 합니다."
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 157/255, green: 159/255, blue: 160/255, alpha: 1)

        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DeleteTeamInformationTableViewCell.self, forCellReuseIdentifier: "DeleteTeamInformationTableViewCell")

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
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 246/255, green: 247/255, blue: 250/255, alpha: 1).cgColor
        button.clipsToBounds = true
        button.setBackgroundColor(UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonDidSelected), for: .touchUpInside)

        return button
    }()

    @objc func cancelButtonDidSelected(sender: UIButton) {
        print("cancelButton이 클릭되었습니다")
        self.delegate?.cancelButtonDidSelected(self)
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
        self.baseView.addsubviews(self.titleLabel, self.subTitleLabel, self.tableView, self.cancelButton)

        NSLayoutConstraint.activate([

            self.baseView.topAnchor.constraint(equalTo: self.topAnchor, constant: 235),
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -235),

            self.titleLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 30),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),

            self.subTitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 5),
            self.subTitleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),

            self.cancelButton.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -32),
            self.cancelButton.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -24),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 40),

            self.tableView.topAnchor.constraint(equalTo: self.subTitleLabel.bottomAnchor, constant: 14),
            self.tableView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),
            self.tableView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -32),
            self.tableView.bottomAnchor.constraint(equalTo: self.cancelButton.topAnchor, constant: -14)
        ])
    }
}

extension DeleteTeamInformationView: UITableViewDelegate {

}

extension DeleteTeamInformationView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteTeamInformationTableViewCell", for: indexPath) as? DeleteTeamInformationTableViewCell else { return UITableViewCell() }

        return cell
    }
}

extension DeleteTeamInformationView {

    class TeamInfo {
        let index: Int

        init(index: Int) {
            self.index = index
        }
    }
}
