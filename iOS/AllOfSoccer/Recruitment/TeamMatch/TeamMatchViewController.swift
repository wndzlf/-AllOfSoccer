//
//  TeamMatchViewController.swift
//  AllOfSoccer
//
//  Created by iOS Developer on 2026/02/06
//

import UIKit

class TeamMatchViewController: UIViewController {
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        table.separatorStyle = .none
        return table
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 14)
        label.isHidden = true
        return label
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "검색 결과가 없습니다."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()

    // MARK: - Properties
    private let viewModel = TeamMatchViewModel()
    private var observerTokens: [NSObjectProtocol] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
        bindViewModel()
    }

    deinit {
        observerTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Setup
    private func setupUI() {
        title = "팀 매치"
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TeamMatchCell.self, forCellReuseIdentifier: TeamMatchCell.identifier)
    }

    private func bindViewModel() {
        // Observe isLoading
        let loadingToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TeamMatchViewModelLoadingChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateLoadingState()
        }
        observerTokens.append(loadingToken)

        // Observe matches
        let matchesToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TeamMatchViewModelMatchesChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateMatchesDisplay()
        }
        observerTokens.append(matchesToken)

        // Observe errors
        let errorToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TeamMatchViewModelErrorChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateErrorState()
        }
        observerTokens.append(errorToken)
    }

    private func updateLoadingState() {
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            errorLabel.isHidden = true
            emptyStateLabel.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
        }
    }

    private func updateMatchesDisplay() {
        errorLabel.isHidden = true

        if viewModel.matches.isEmpty && !viewModel.isLoading {
            emptyStateLabel.isHidden = false
        } else {
            emptyStateLabel.isHidden = true
        }

        tableView.reloadData()
    }

    private func updateErrorState() {
        if let error = viewModel.errorMessage {
            errorLabel.text = "오류: \(error)"
            errorLabel.isHidden = false
            tableView.isHidden = true
            emptyStateLabel.isHidden = true
        } else {
            errorLabel.isHidden = true
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TeamMatchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamMatchCell.identifier, for: indexPath) as? TeamMatchCell else {
            return UITableViewCell()
        }

        let match = viewModel.matches[indexPath.row]
        cell.configure(with: match)
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedMatch = viewModel.matches[indexPath.row]
        navigateToDetailScreen(matchId: selectedMatch.id)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowsBeforeRefresh = viewModel.matches.count - 5
        if indexPath.row == rowsBeforeRefresh && viewModel.hasMorePages && !viewModel.isLoading {
            viewModel.loadNextPage()
        }
    }
}

// MARK: - Navigation
extension TeamMatchViewController {
    private func navigateToDetailScreen(matchId: String) {
        let detailViewController = TeamMatchDetailViewController(matchId: matchId)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - TeamMatchCell
class TeamMatchCell: UITableViewCell {
    static let identifier = "TeamMatchCell"

    private let containerView = UIView()
    private let locationLabel = UILabel()
    private let dateTimeLabel = UILabel()
    private let matchTypeLabel = UILabel()
    private let participantsLabel = UILabel()
    private let feeLabel = UILabel()
    private let favoriteButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        backgroundColor = .clear

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(containerView)

        // Setup labels
        locationLabel.font = UIFont.boldSystemFont(ofSize: 16)
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(locationLabel)

        dateTimeLabel.font = UIFont.systemFont(ofSize: 14)
        dateTimeLabel.textColor = .gray
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateTimeLabel)

        matchTypeLabel.font = UIFont.systemFont(ofSize: 12)
        matchTypeLabel.textColor = .white
        matchTypeLabel.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        matchTypeLabel.textAlignment = .center
        matchTypeLabel.layer.cornerRadius = 4
        matchTypeLabel.clipsToBounds = true
        matchTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(matchTypeLabel)

        participantsLabel.font = UIFont.systemFont(ofSize: 12)
        participantsLabel.textColor = .gray
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(participantsLabel)

        feeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        feeLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        feeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(feeLabel)

        // Setup constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            locationLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            dateTimeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 6),
            dateTimeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),

            matchTypeLabel.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 8),
            matchTypeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            matchTypeLabel.widthAnchor.constraint(equalToConstant: 60),
            matchTypeLabel.heightAnchor.constraint(equalToConstant: 24),

            participantsLabel.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 8),
            participantsLabel.leadingAnchor.constraint(equalTo: matchTypeLabel.trailingAnchor, constant: 8),

            feeLabel.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 8),
            feeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }

    func configure(with match: Match) {
        locationLabel.text = match.location
        dateTimeLabel.text = formatDateTime(match.date)
        matchTypeLabel.text = match.matchType
        participantsLabel.text = "\(match.currentParticipants)/\(match.maxParticipants)명"
        feeLabel.text = "₩\(match.fee)"
    }

    private func formatDateTime(_ dateString: String) -> String {
        // Parse ISO 8601 date and format
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd HH:mm"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}
