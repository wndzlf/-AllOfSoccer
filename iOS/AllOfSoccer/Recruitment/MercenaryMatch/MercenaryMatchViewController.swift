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
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["용병 모집", "용병 지원"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        return control
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
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

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Variables
    private var currentDataType: MercenaryMatchViewModel.DataType = .request

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "용병 모집"
        setupUI()
        setupTableView()
        setupActions()
        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)

        // Segmented Control as title view
        navigationItem.titleView = segmentedControl

        // Add subviews
        view.addSubview(tableView)
        view.addSubview(createButton)
        view.addSubview(loadingIndicator)

        // Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 80),
            createButton.heightAnchor.constraint(equalToConstant: 50),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MercenaryMatchTableViewCell.self, forCellReuseIdentifier: MercenaryMatchTableViewCell.identifier)
    }

    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func segmentChanged() {
        currentDataType = segmentedControl.selectedSegmentIndex == 0 ? .request : .application
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
        fetchData()
    }

    @objc private func createButtonTapped() {
        if segmentedControl.selectedSegmentIndex == 0 {
            // 용병 모집하기
            let requestVC = MercenaryRequestViewController()
            navigationController?.pushViewController(requestVC, animated: true)
        } else {
            // 용병 지원하기
            let applicationVC = MercenaryApplicationViewController()
            navigationController?.pushViewController(applicationVC, animated: true)
        }
    }

    // MARK: - Data Fetching
    private func fetchData() {
        if currentDataType == .request {
            viewModel.fetchMercenaryRequests { [weak self] success in
                self?.tableView.reloadData()
            }
        } else {
            viewModel.fetchMercenaryApplications { [weak self] success in
                self?.tableView.reloadData()
            }
        }
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension MercenaryMatchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentDataType == .request {
            return viewModel.getRequestCount()
        } else {
            return viewModel.getApplicationCount()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MercenaryMatchTableViewCell.identifier, for: indexPath) as? MercenaryMatchTableViewCell else {
            return UITableViewCell()
        }

        if currentDataType == .request {
            if let request = viewModel.getRequest(at: indexPath.row) {
                cell.configureWithRequest(request, viewModel: viewModel)
            }
        } else {
            if let application = viewModel.getApplication(at: indexPath.row) {
                cell.configureWithApplication(application, viewModel: viewModel)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if currentDataType == .request {
            if let request = viewModel.getRequest(at: indexPath.row) {
                // TODO: Navigate to mercenary request detail
                print("선택된 용병 모집: \(request.title)")
            }
        } else {
            if let application = viewModel.getApplication(at: indexPath.row) {
                // TODO: Navigate to mercenary application detail
                print("선택된 용병 지원: \(application.title)")
            }
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load more when reaching the end
        let requestCount = viewModel.getRequestCount()
        let applicationCount = viewModel.getApplicationCount()
        let currentCount = currentDataType == .request ? requestCount : applicationCount

        if indexPath.row == currentCount - 1 {
            if currentDataType == .request {
                viewModel.loadNextPageOfRequests { [weak self] _ in
                    self?.tableView.reloadData()
                }
            } else {
                viewModel.loadNextPageOfApplications { [weak self] _ in
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

