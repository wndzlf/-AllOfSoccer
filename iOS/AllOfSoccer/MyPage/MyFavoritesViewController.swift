//
//  MyFavoritesViewController.swift
//  AllOfSoccer
//
//  Created by iOS Developer on 2026/02/08
//

import UIKit

class MyFavoritesViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = MyFavoritesViewModel()
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
        label.text = "찜한 글이 없습니다."
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data when returning to this view
        loadData()
    }

    deinit {
        observerTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Setup
    private func setupUI() {
        title = "관심 글"
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)

        view.addSubview(segmentedControl)
        view.addSubview(teamMatchTableView)
        view.addSubview(mercenaryTableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        teamMatchTableView.translatesAutoresizingMaskIntoConstraints = false
        mercenaryTableView.translatesAutoresizingMaskIntoConstraints = false

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

        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
    }

    private func setupTableViews() {
        // Team Match Table View
        teamMatchTableView.delegate = self
        teamMatchTableView.dataSource = self
        teamMatchTableView.tag = 0
        teamMatchTableView.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        teamMatchTableView.separatorStyle = .none
        teamMatchTableView.register(FavoriteTeamMatchCell.self, forCellReuseIdentifier: FavoriteTeamMatchCell.identifier)
        teamMatchTableView.rowHeight = 120.0

        // Mercenary Table View
        mercenaryTableView.delegate = self
        mercenaryTableView.dataSource = self
        mercenaryTableView.tag = 1
        mercenaryTableView.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        mercenaryTableView.separatorStyle = .none
        mercenaryTableView.register(FavoriteMercenaryCell.self, forCellReuseIdentifier: FavoriteMercenaryCell.identifier)
        mercenaryTableView.estimatedRowHeight = 140
        mercenaryTableView.rowHeight = UITableView.automaticDimension

        // Initially show team match table
        mercenaryTableView.isHidden = true
    }

    private func bindViewModel() {
        let loadingToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MyFavoritesViewModelLoadingChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateLoadingState()
        }
        observerTokens.append(loadingToken)

        let dataToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MyFavoritesViewModelDataChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateDataDisplay()
        }
        observerTokens.append(dataToken)
    }

    private func loadData() {
        viewModel.fetchFavoriteMatches()
        viewModel.fetchFavoriteMercenaryRequests()
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
            if viewModel.favoriteMatches.isEmpty {
                teamMatchTableView.isHidden = true
                emptyStateLabel.isHidden = false
            } else {
                teamMatchTableView.isHidden = false
                teamMatchTableView.reloadData()
            }
            mercenaryTableView.isHidden = true
        } else {
            // Mercenary tab
            if viewModel.favoriteMercenaryRequests.isEmpty {
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
extension MyFavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return viewModel.favoriteMatches.count
        } else {
            return viewModel.favoriteMercenaryRequests.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTeamMatchCell.identifier, for: indexPath) as? FavoriteTeamMatchCell else {
                return UITableViewCell()
            }
            let match = viewModel.favoriteMatches[indexPath.row]
            cell.configure(with: match, viewModel: viewModel)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMercenaryCell.identifier, for: indexPath) as? FavoriteMercenaryCell else {
                return UITableViewCell()
            }
            let request = viewModel.favoriteMercenaryRequests[indexPath.row]
            cell.configure(with: request, viewModel: viewModel)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView.tag == 0 {
            let match = viewModel.favoriteMatches[indexPath.row]
            navigateToMatchDetail(matchId: match.id)
        } else {
            let request = viewModel.favoriteMercenaryRequests[indexPath.row]
            navigateToMercenaryDetail(requestId: request.id)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowsBeforeRefresh = tableView.tag == 0 ? viewModel.favoriteMatches.count - 5 : viewModel.favoriteMercenaryRequests.count - 5
        if indexPath.row == rowsBeforeRefresh {
            if tableView.tag == 0 {
                viewModel.loadNextPageOfFavoriteMatches()
            } else {
                viewModel.loadNextPageOfFavoriteMercenaryRequests()
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

// MARK: - FavoriteCellDelegate
extension MyFavoritesViewController: FavoriteCellDelegate {
    func didTapUnlikeMatch(matchId: String) {
        APIService.shared.unlikeMatch(matchId: matchId) { [weak self] result in
            switch result {
            case .success:
                self?.viewModel.favoriteMatches.removeAll { $0.id == matchId }
                NotificationCenter.default.post(name: NSNotification.Name("MyFavoritesViewModelDataChanged"), object: nil)
            case .failure(let error):
                print("찜 해제 실패: \(error.localizedDescription)")
            }
        }
    }

    func didTapUnlikeMercenary(requestId: String) {
        APIService.shared.unlikeMercenaryRequest(requestId: requestId) { [weak self] result in
            switch result {
            case .success:
                self?.viewModel.favoriteMercenaryRequests.removeAll { $0.id == requestId }
                NotificationCenter.default.post(name: NSNotification.Name("MyFavoritesViewModelDataChanged"), object: nil)
            case .failure(let error):
                print("찜 해제 실패: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - FavoriteCellDelegate
protocol FavoriteCellDelegate: AnyObject {
    func didTapUnlikeMatch(matchId: String)
    func didTapUnlikeMercenary(requestId: String)
}

// MARK: - FavoriteTeamMatchCell
class FavoriteTeamMatchCell: UITableViewCell {
    static let identifier = "FavoriteTeamMatchCell"

    weak var delegate: FavoriteCellDelegate?
    private var matchId: String?

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

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        favoriteButton.tintColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        containerView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            locationLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -12),

            dateTimeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 6),
            dateTimeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),

            matchTypeLabel.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 8),
            matchTypeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            matchTypeLabel.widthAnchor.constraint(equalToConstant: 60),
            matchTypeLabel.heightAnchor.constraint(equalToConstant: 24),

            participantsLabel.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 8),
            participantsLabel.leadingAnchor.constraint(equalTo: matchTypeLabel.trailingAnchor, constant: 8),

            feeLabel.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 8),
            feeLabel.leadingAnchor.constraint(equalTo: participantsLabel.trailingAnchor, constant: 8),

            favoriteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(with match: Match, viewModel: MyFavoritesViewModel) {
        matchId = match.id
        locationLabel.text = match.location
        dateTimeLabel.text = formatDateTime(match.date)
        matchTypeLabel.text = match.matchType
        participantsLabel.text = "\(match.currentParticipants)/\(match.maxParticipants)명"
        feeLabel.text = "₩\(match.fee)"
    }

    @objc private func favoriteButtonTapped() {
        guard let matchId = matchId else { return }
        delegate?.didTapUnlikeMatch(matchId: matchId)
    }

    private func formatDateTime(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd HH:mm"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - FavoriteMercenaryCell
class FavoriteMercenaryCell: UITableViewCell {
    static let identifier = "FavoriteMercenaryCell"

    weak var delegate: FavoriteCellDelegate?
    private var requestId: String?

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let dateLabel = UILabel()
    private let feeLabel = UILabel()
    private let statusBadge = UILabel()
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
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(containerView)

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        locationLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        locationLabel.textColor = .gray
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(locationLabel)

        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)

        feeLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        feeLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        feeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(feeLabel)

        statusBadge.font = UIFont.boldSystemFont(ofSize: 11)
        statusBadge.textAlignment = .center
        statusBadge.layer.masksToBounds = true
        statusBadge.layer.cornerRadius = 4
        statusBadge.clipsToBounds = true
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(statusBadge)

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        favoriteButton.tintColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        containerView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -12),

            locationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            dateLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            feeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            feeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            statusBadge.topAnchor.constraint(equalTo: feeLabel.bottomAnchor, constant: 10),
            statusBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusBadge.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            statusBadge.heightAnchor.constraint(equalToConstant: 22),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

            favoriteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(with request: MercenaryRequest, viewModel: MyFavoritesViewModel) {
        requestId = request.id
        titleLabel.text = request.title
        locationLabel.text = "📍 \(request.location)"
        dateLabel.text = "🕐 \(viewModel.formatDate(request.date))"
        feeLabel.text = viewModel.formatFee(request.fee)

        let remainingPositions = request.mercenaryCount - request.currentApplicants
        if remainingPositions > 0 {
            statusBadge.text = "모집 중"
            statusBadge.textColor = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1.0)
            statusBadge.backgroundColor = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 0.1)
        } else {
            statusBadge.text = "모집 완료"
            statusBadge.textColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0)
            statusBadge.backgroundColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 0.1)
        }
    }

    @objc private func favoriteButtonTapped() {
        guard let requestId = requestId else { return }
        delegate?.didTapUnlikeMercenary(requestId: requestId)
    }
}

// MARK: - MyFavoritesViewModel
class MyFavoritesViewModel {
    @Published var favoriteMatches: [Match] = []
    @Published var favoriteMercenaryRequests: [MercenaryRequest] = []
    @Published var isLoading = false

    private var currentMatchPage = 1
    private var currentMercenaryPage = 1
    private let pageSize = 20

    func fetchFavoriteMatches() {
        isLoading = true
        NotificationCenter.default.post(name: NSNotification.Name("MyFavoritesViewModelLoadingChanged"), object: nil)

        APIService.shared.getMyFavoriteMatches(page: 1, limit: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                NotificationCenter.default.post(name: NSNotification.Name("MyFavoritesViewModelLoadingChanged"), object: nil)

                switch result {
                case .success(let response):
                    self?.favoriteMatches = response.data
                    self?.currentMatchPage = 1
                    NotificationCenter.default.post(name: NSNotification.Name("MyFavoritesViewModelDataChanged"), object: nil)

                case .failure(let error):
                    print("찜한 팀 매칭 로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchFavoriteMercenaryRequests() {
        isLoading = true
        NotificationCenter.default.post(name: NSNotification.Name("MyFavoritesViewModelLoadingChanged"), object: nil)

        APIService.shared.getMyFavoriteMercenaryRequests(page: 1, limit: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                NotificationCenter.default.post(name: NSNotification.Name("MyFavoritesViewModelLoadingChanged"), object: nil)

                switch result {
                case .success(let response):
                    self?.favoriteMercenaryRequests = response.data
                    self?.currentMercenaryPage = 1
                    NotificationCenter.default.post(name: NSNotification.Name("MyFavoritesViewModelDataChanged"), object: nil)

                case .failure(let error):
                    print("찜한 용병 모집 로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func loadNextPageOfFavoriteMatches() {
        APIService.shared.getMyFavoriteMatches(page: currentMatchPage + 1, limit: pageSize) { [weak self] result in
            switch result {
            case .success(let response):
                self?.favoriteMatches.append(contentsOf: response.data)
                self?.currentMatchPage += 1
                NotificationCenter.default.post(name: NSNotification.Name("MyFavoritesViewModelDataChanged"), object: nil)

            case .failure(let error):
                print("팀 매칭 다음 페이지 로드 실패: \(error.localizedDescription)")
            }
        }
    }

    func loadNextPageOfFavoriteMercenaryRequests() {
        APIService.shared.getMyFavoriteMercenaryRequests(page: currentMercenaryPage + 1, limit: pageSize) { [weak self] result in
            switch result {
            case .success(let response):
                self?.favoriteMercenaryRequests.append(contentsOf: response.data)
                self?.currentMercenaryPage += 1
                NotificationCenter.default.post(name: NSNotification.Name("MyFavoritesViewModelDataChanged"), object: nil)

            case .failure(let error):
                print("용병 모집 다음 페이지 로드 실패: \(error.localizedDescription)")
            }
        }
    }

    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MM월 dd일 HH:mm"
            displayFormatter.locale = Locale(identifier: "ko_KR")
            return displayFormatter.string(from: date)
        }
        return dateString
    }

    func formatFee(_ fee: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        return (formatter.string(from: NSNumber(value: fee)) ?? "0") + "원"
    }
}
