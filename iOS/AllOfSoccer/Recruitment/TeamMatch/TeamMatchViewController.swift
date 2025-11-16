//
//  TeamMatchViewController.swift
//  AllOfSoccer
//
//  Created by Assistant on 2024
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
    
    // MARK: - Variables
    private var sampleData: [String] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        loadSampleData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "팀 매치"
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func loadSampleData() {
        // 샘플 데이터 생성
        sampleData = [
            "양원역 구장 - 20:00",
            "태릉종합운동장 - 19:00",
            "용산 아이파크몰 - 18:30",
            "잠실 종합운동장 - 21:00",
            "상암 월드컵경기장 - 19:30"
        ]
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TeamMatchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = sampleData[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: 상세 화면으로 이동
        print("선택된 팀 매치: \(sampleData[indexPath.row])")
    }
}

