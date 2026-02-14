//
//  MyTeamsViewController.swift
//  AllOfSoccer
//
//  Created by Assistant on 2026
//

import UIKit

final class MyTeamsViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "등록된 팀이 없습니다."
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var teams: [Team] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "내 팀 관리"
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)

        setupUI()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTeamTapped)
        )

        loadTeams()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTeams()
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.register(MyTeamCell.self, forCellReuseIdentifier: MyTeamCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
    }

    private func loadTeams() {
        loadingIndicator.startAnimating()
        APIService.shared.getMyTeams { [weak self] result in
            guard let self else { return }
            self.loadingIndicator.stopAnimating()

            switch result {
            case .success(let teams):
                self.teams = teams
                self.emptyLabel.isHidden = !teams.isEmpty
                self.tableView.reloadData()

            case .failure(let error):
                self.showAlert(title: "오류", message: "내 팀 목록을 불러오지 못했습니다.\n\(error.localizedDescription)")
            }
        }
    }

    @objc private func addTeamTapped() {
        let alert = UIAlertController(title: "팀 등록", message: "팀 이름과 소개를 입력하세요.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "팀 이름 (필수)"
        }
        alert.addTextField { textField in
            textField.placeholder = "팀 소개 (선택)"
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let intro = alert.textFields?.last?.text?.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !name.isEmpty else {
                self.showAlert(title: "입력 오류", message: "팀 이름은 필수입니다.")
                return
            }

            self.loadingIndicator.startAnimating()
            APIService.shared.createTeam(name: name, introduction: intro) { [weak self] result in
                guard let self else { return }
                self.loadingIndicator.stopAnimating()

                switch result {
                case .success:
                    self.loadTeams()
                case .failure(let error):
                    self.showAlert(title: "등록 실패", message: "팀 등록에 실패했습니다.\n\(error.localizedDescription)")
                }
            }
        }))

        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension MyTeamsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyTeamCell.identifier, for: indexPath) as? MyTeamCell else {
            return UITableViewCell()
        }
        cell.configure(team: teams[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        104
    }
}

private final class MyTeamCell: UITableViewCell {
    static let identifier = "MyTeamCell"

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 8
        return view
    }()

    private let teamNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let introLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(cardView)
        cardView.addSubview(teamNameLabel)
        cardView.addSubview(introLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            teamNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            teamNameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            teamNameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            introLabel.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: 8),
            introLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            introLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            introLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12)
        ])
    }

    func configure(team: Team) {
        teamNameLabel.text = team.name
        introLabel.text = team.introduction ?? team.description ?? "팀 소개가 없습니다."
    }
}
