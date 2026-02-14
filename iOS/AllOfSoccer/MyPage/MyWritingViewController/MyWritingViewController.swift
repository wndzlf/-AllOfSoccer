//
//  MyWritingViewController.swift
//  AllOfSoccer
//
//  Created by iOS Developer on 2026/02/08
//

import UIKit

class MyWritingViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = MyWritingViewModel()
    private let mercenaryCellViewModel = MercenaryMatchViewModel()
    private var observerTokens: [NSObjectProtocol] = []
    private let teamMatchTableView = UITableView()
    private let mercenaryTableView = UITableView()

    // MARK: - UI Components
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["팀 매칭", "용병 모집"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        return control
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "작성한 글이 없습니다."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableViews()
        bindViewModel()
        loadData()
    }

    deinit {
        observerTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Setup
    private func setupUI() {
        title = "내가 쓴 글"
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)

        view.addSubview(segmentedControl)
        view.addSubview(teamMatchTableView)
        view.addSubview(mercenaryTableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32),

            teamMatchTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            teamMatchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            teamMatchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            teamMatchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            mercenaryTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            mercenaryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mercenaryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mercenaryTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        teamMatchTableView.translatesAutoresizingMaskIntoConstraints = false
        mercenaryTableView.translatesAutoresizingMaskIntoConstraints = false

        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
    }

    private func setupTableViews() {
        // Team Match Table View
        teamMatchTableView.delegate = self
        teamMatchTableView.dataSource = self
        teamMatchTableView.tag = 0
        teamMatchTableView.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        teamMatchTableView.separatorStyle = .none
        teamMatchTableView.register(TeamMatchCell.self, forCellReuseIdentifier: TeamMatchCell.identifier)
        teamMatchTableView.rowHeight = 120.0

        // Mercenary Table View
        mercenaryTableView.delegate = self
        mercenaryTableView.dataSource = self
        mercenaryTableView.tag = 1
        mercenaryTableView.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        mercenaryTableView.separatorStyle = .none
        mercenaryTableView.register(MercenaryMatchTableViewCell.self, forCellReuseIdentifier: MercenaryMatchTableViewCell.identifier)
        mercenaryTableView.estimatedRowHeight = 140
        mercenaryTableView.rowHeight = UITableView.automaticDimension

        // Initially show team match table
        mercenaryTableView.isHidden = true
    }

    private func bindViewModel() {
        let loadingToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MyWritingViewModelLoadingChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateLoadingState()
        }
        observerTokens.append(loadingToken)

        let dataToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MyWritingViewModelDataChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateDataDisplay()
        }
        observerTokens.append(dataToken)
    }

    private func loadData() {
        viewModel.fetchMyMatches()
        viewModel.fetchMyMercenaryRequests()
    }

    private func updateLoadingState() {
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
            teamMatchTableView.isHidden = true
            mercenaryTableView.isHidden = true
            emptyStateLabel.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            updateDataDisplay()
        }
    }

    private func updateDataDisplay() {
        emptyStateLabel.isHidden = true

        if segmentedControl.selectedSegmentIndex == 0 {
            // Team Match tab
            if viewModel.myMatches.isEmpty {
                teamMatchTableView.isHidden = true
                emptyStateLabel.isHidden = false
            } else {
                teamMatchTableView.isHidden = false
                teamMatchTableView.reloadData()
            }
            mercenaryTableView.isHidden = true
        } else {
            // Mercenary tab
            if viewModel.myMercenaryRequests.isEmpty {
                mercenaryTableView.isHidden = true
                emptyStateLabel.isHidden = false
            } else {
                mercenaryTableView.isHidden = false
                mercenaryTableView.reloadData()
            }
            teamMatchTableView.isHidden = true
        }
    }

    @objc private func segmentedControlChanged() {
        updateDataDisplay()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension MyWritingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return viewModel.myMatches.count
        } else {
            return viewModel.myMercenaryRequests.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamMatchCell.identifier, for: indexPath) as? TeamMatchCell else {
                return UITableViewCell()
            }
            let match = viewModel.myMatches[indexPath.row]
            cell.configure(with: match)
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MercenaryMatchTableViewCell.identifier, for: indexPath) as? MercenaryMatchTableViewCell else {
                return UITableViewCell()
            }
            let request = viewModel.myMercenaryRequests[indexPath.row]
            cell.configureWithRequest(request, viewModel: mercenaryCellViewModel)
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView.tag == 0 {
            let match = viewModel.myMatches[indexPath.row]
            navigateToMatchDetail(matchId: match.id)
        } else {
            let request = viewModel.myMercenaryRequests[indexPath.row]
            navigateToMercenaryDetail(requestId: request.id)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowCount = tableView.tag == 0 ? viewModel.myMatches.count : viewModel.myMercenaryRequests.count
        guard rowCount > 0 else { return }

        let rowsBeforeRefresh = max(rowCount - 5, 0)
        if indexPath.row == rowsBeforeRefresh {
            if tableView.tag == 0 {
                guard viewModel.hasMoreMatchPages && !viewModel.isLoading else { return }
                viewModel.loadNextPageOfMatches()
            } else {
                guard viewModel.hasMoreMercenaryPages && !viewModel.isLoading else { return }
                viewModel.loadNextPageOfMercenaryRequests()
            }
        }
    }

    // MARK: - Navigation
    private func navigateToMatchDetail(matchId: String) {
        let detailVC = TeamMatchDetailViewController(matchId: matchId)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func navigateToMercenaryDetail(requestId: String) {
        let detailVC = MercenaryDetailViewController(requestId: requestId)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - MyWritingViewModel
class MyWritingViewModel {
    @Published var myMatches: [Match] = []
    @Published var myMercenaryRequests: [MercenaryRequest] = []
    @Published var isLoading = false
    @Published var hasMoreMatchPages = true
    @Published var hasMoreMercenaryPages = true

    private var isMatchLoading = false
    private var isMercenaryLoading = false
    private var currentMatchPage = 1
    private var currentMercenaryPage = 1
    private let pageSize = 20

    func fetchMyMatches() {
        guard !isMatchLoading else { return }
        setMatchLoading(true)

        APIService.shared.getMyMatches(page: 1, limit: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.setMatchLoading(false)

                switch result {
                case .success(let response):
                    let pageSize = self?.pageSize ?? 20
                    self?.myMatches = response.data
                    self?.currentMatchPage = 1
                    self?.hasMoreMatchPages = response.data.count >= pageSize
                    NotificationCenter.default.post(name: NSNotification.Name("MyWritingViewModelDataChanged"), object: nil)

                case .failure:
                    break
                }
            }
        }
    }

    func fetchMyMercenaryRequests() {
        guard !isMercenaryLoading else { return }
        setMercenaryLoading(true)

        APIService.shared.getMyMercenaryRequests(page: 1, limit: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.setMercenaryLoading(false)

                switch result {
                case .success(let response):
                    let pageSize = self?.pageSize ?? 20
                    self?.myMercenaryRequests = response.data
                    self?.currentMercenaryPage = 1
                    self?.hasMoreMercenaryPages = response.data.count >= pageSize
                    NotificationCenter.default.post(name: NSNotification.Name("MyWritingViewModelDataChanged"), object: nil)

                case .failure:
                    break
                }
            }
        }
    }

    func loadNextPageOfMatches() {
        guard !isMatchLoading && hasMoreMatchPages else { return }
        setMatchLoading(true)

        APIService.shared.getMyMatches(page: currentMatchPage + 1, limit: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.setMatchLoading(false)

                switch result {
                case .success(let response):
                    let pageSize = self?.pageSize ?? 20
                    self?.myMatches.append(contentsOf: response.data)
                    self?.currentMatchPage += 1
                    self?.hasMoreMatchPages = response.data.count >= pageSize
                    NotificationCenter.default.post(name: NSNotification.Name("MyWritingViewModelDataChanged"), object: nil)

                case .failure:
                    break
                }
            }
        }
    }

    func loadNextPageOfMercenaryRequests() {
        guard !isMercenaryLoading && hasMoreMercenaryPages else { return }
        setMercenaryLoading(true)

        APIService.shared.getMyMercenaryRequests(page: currentMercenaryPage + 1, limit: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.setMercenaryLoading(false)

                switch result {
                case .success(let response):
                    let pageSize = self?.pageSize ?? 20
                    self?.myMercenaryRequests.append(contentsOf: response.data)
                    self?.currentMercenaryPage += 1
                    self?.hasMoreMercenaryPages = response.data.count >= pageSize
                    NotificationCenter.default.post(name: NSNotification.Name("MyWritingViewModelDataChanged"), object: nil)

                case .failure:
                    break
                }
            }
        }
    }

    private func setMatchLoading(_ loading: Bool) {
        isMatchLoading = loading
        updateGlobalLoading()
    }

    private func setMercenaryLoading(_ loading: Bool) {
        isMercenaryLoading = loading
        updateGlobalLoading()
    }

    private func updateGlobalLoading() {
        let next = isMatchLoading || isMercenaryLoading
        guard isLoading != next else { return }
        isLoading = next
        NotificationCenter.default.post(name: NSNotification.Name("MyWritingViewModelLoadingChanged"), object: nil)
    }
}
