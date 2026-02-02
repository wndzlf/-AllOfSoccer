//
//  MercenaryMatchViewController.swift
//  AllOfSoccer
//
//  Created by Assistant on 2024
//

import UIKit

class MercenaryMatchViewController: UIViewController {
    // MARK: - ViewModel
    private let viewModel = MercenaryMatchViewModel()

    // MARK: - UI Components
    private let filterStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemBackground
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()

    private let monthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()

    private let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("장소 ▼", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        button.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return button
    }()

    private let skillButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("실력 ▼", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        button.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return button
    }()

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.estimatedRowHeight = 140
        table.rowHeight = UITableView.automaticDimension
        return table
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("등록하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        return button
    }()

    // MARK: - Filter Variables
    private var selectedDate: Date?
    private var selectedLocation: String?
    private var selectedSkillLevel: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "용병 모집"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]

        setupUI()
        setupTableView()
        setupActions()
        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // viewDidLoad에서 이미 데이터를 로드하므로 여기서는 호출하지 않음
        // 무한 재귀 호출 방지
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Add subviews
        view.addSubview(filterStackView)
        filterStackView.addArrangedSubview(monthButton)
        filterStackView.addArrangedSubview(locationButton)
        filterStackView.addArrangedSubview(skillButton)
        filterStackView.addArrangedSubview(resetButton)

        view.addSubview(tableView)
        view.addSubview(createButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Filter Stack
            filterStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterStackView.heightAnchor.constraint(equalToConstant: 50),

            // TableView
            tableView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Create Button
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 80),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MercenaryMatchTableViewCell.self, forCellReuseIdentifier: MercenaryMatchTableViewCell.identifier)
    }

    private func setupActions() {
        monthButton.addTarget(self, action: #selector(monthButtonTapped), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        skillButton.addTarget(self, action: #selector(skillButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetFilterButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func monthButtonTapped() {
        let calendarView = RecruitmentCalendarView()
        calendarView.delegate = self
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func locationButtonTapped() {
        showLocationPicker()
    }

    @objc private func skillButtonTapped() {
        showSkillLevelPicker()
    }

    @objc private func resetFilterButtonTapped() {
        selectedDate = nil
        selectedLocation = nil
        selectedSkillLevel = nil
        monthButton.setTitle("2월", for: .normal)
        locationButton.setTitle("장소 ▼", for: .normal)
        skillButton.setTitle("실력 ▼", for: .normal)
        fetchData()
    }

    @objc private func createButtonTapped() {
        let requestVC = MercenaryRequestViewController()
        navigationController?.pushViewController(requestVC, animated: true)
    }

    // MARK: - Filter Pickers
    private func showLocationPicker() {
        let alert = UIAlertController(title: "장소 선택", message: nil, preferredStyle: .actionSheet)

        let locations = ["서울 노원구", "서울 강남구", "서울 마포구", "서울 종로구", "전체"]

        for location in locations {
            alert.addAction(UIAlertAction(title: location, style: .default) { _ in
                self.selectedLocation = location == "전체" ? nil : location
                self.locationButton.setTitle(location, for: .normal)
                self.fetchData()
            })
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    private func showSkillLevelPicker() {
        let alert = UIAlertController(title: "실력 선택", message: nil, preferredStyle: .actionSheet)

        let levels = ["초급", "중급", "고급", "고수", "전체"]

        for level in levels {
            alert.addAction(UIAlertAction(title: level, style: .default) { _ in
                self.selectedSkillLevel = level == "전체" ? nil : level
                self.skillButton.setTitle(level, for: .normal)
                self.fetchData()
            })
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Data Fetching
    private func fetchData() {
        viewModel.fetchMercenaryRequests { [weak self] success in
            self?.tableView.reloadData()
        }
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - RecruitmentCalendarViewDelegate
extension MercenaryMatchViewController: RecruitmentCalendarViewDelegate {
    func cancelButtonDidSelected(_ view: RecruitmentCalendarView) {
        view.removeFromSuperview()
    }

    func okButtonDidSelected(_ view: RecruitmentCalendarView, selectedDate: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")

        if let date = dateFormatter.date(from: selectedDate) {
            self.selectedDate = date
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "M월"
            monthFormatter.locale = Locale(identifier: "ko_KR")
            monthButton.setTitle(monthFormatter.string(from: date), for: .normal)
            fetchData()
        }

        view.removeFromSuperview()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension MercenaryMatchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getRequestCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MercenaryMatchTableViewCell.identifier, for: indexPath) as? MercenaryMatchTableViewCell else {
            return UITableViewCell()
        }

        if let request = viewModel.getRequest(at: indexPath.row) {
            cell.configureWithRequest(request, viewModel: viewModel)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let request = viewModel.getRequest(at: indexPath.row) {
            print("선택된 용병 모집: \(request.title)")
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let requestCount = viewModel.getRequestCount()
        if indexPath.row == requestCount - 1 {
            viewModel.loadNextPageOfRequests { [weak self] _ in
                self?.tableView.reloadData()
            }
        }
    }
}

