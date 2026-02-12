//
//  TeamMatchDetailViewController.swift
//  AllOfSoccer
//
//  Created by iOS Developer on 2026/02/12
//

import UIKit

class TeamMatchDetailViewController: UIViewController {
    // MARK: - Properties
    private let matchId: String
    private let viewModel = TeamMatchDetailViewModel()
    private var observerTokens: [NSObjectProtocol] = []
    private var match: MatchDetail?

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        return scroll
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()

    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.92, green: 0.37, blue: 0.37, alpha: 1.0)
        button.setTitle("신청하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    // MARK: - Initializer
    init(matchId: String) {
        self.matchId = matchId
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        loadDetail()
    }

    deinit {
        observerTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Setup
    private func setupUI() {
        title = "팀 매칭 상세"
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)

        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        view.addSubview(applyButton)

        scrollView.addSubview(contentView)
        contentView.addSubview(infoLabel)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -16),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            infoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            applyButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 50),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        let loadingToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TeamMatchDetailViewModelLoadingChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateLoadingState()
        }
        observerTokens.append(loadingToken)

        let detailToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TeamMatchDetailViewModelDetailChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateDetailDisplay()
        }
        observerTokens.append(detailToken)
    }

    private func loadDetail() {
        viewModel.fetchMatchDetail(matchId: matchId)
    }

    private func updateLoadingState() {
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
            scrollView.isHidden = true
            applyButton.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
            applyButton.isHidden = false
        }
    }

    private func updateDetailDisplay() {
        guard let match = viewModel.matchDetail else { return }
        self.match = match

        var text = "제목: \(match.title)\n\n"
        text += "위치: \(match.location)\n"
        text += "날짜: \(match.date)\n"
        text += "경기유형: \(match.matchType)\n"
        text += "성별: \(formatGender(match.genderType))\n"
        text += "신발: \(formatShoes(match.shoesRequirement))\n"
        text += "참가비: ₩\(match.fee)\n"
        text += "현재인원: \(match.currentParticipants) / \(match.maxParticipants)\n"

        if let intro = match.teamIntroduction {
            text += "\n팀소개: \(intro)\n"
        }

        if let desc = match.description {
            text += "\n설명: \(desc)\n"
        }

        infoLabel.text = text
    }

    private func formatGender(_ gender: String) -> String {
        switch gender {
        case "male": return "남성"
        case "female": return "여성"
        case "mixed": return "혼성"
        default: return gender
        }
    }

    private func formatShoes(_ shoes: String) -> String {
        switch shoes {
        case "cleats", "soccer": return "축구화"
        case "indoor", "futsal": return "풋살화"
        case "any": return "상관없음"
        default: return shoes
        }
    }

    @objc private func applyButtonTapped() {
        showAlert(title: "신청 완료", message: "팀 매칭에 신청했습니다.")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TeamMatchDetailViewModel
class TeamMatchDetailViewModel {
    var matchDetail: MatchDetail?
    var isLoading = false

    func fetchMatchDetail(matchId: String) {
        isLoading = true
        NotificationCenter.default.post(name: NSNotification.Name("TeamMatchDetailViewModelLoadingChanged"), object: nil)

        APIService.shared.getMatchDetail(matchId: matchId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                NotificationCenter.default.post(name: NSNotification.Name("TeamMatchDetailViewModelLoadingChanged"), object: nil)

                switch result {
                case .success(let matchDetail):
                    self?.matchDetail = matchDetail
                    NotificationCenter.default.post(name: NSNotification.Name("TeamMatchDetailViewModelDetailChanged"), object: nil)

                case .failure(let error):
                    print("팀 매칭 상세 로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}
