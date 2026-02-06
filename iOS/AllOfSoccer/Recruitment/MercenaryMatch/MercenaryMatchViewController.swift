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
    private let monthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = .black
        return button
    }()

    private let filterTagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 500, height: 28)
        layout.minimumInteritemSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.allowsMultipleSelection = true
        collectionView.register(FilterButtonCollectionViewCell.self, forCellWithReuseIdentifier: "FilterButtonCell")
        return collectionView
    }()

    private let horizontalCalendarView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.register(HorizontalCalendarCollectionViewCell.self, forCellWithReuseIdentifier: "HorizontalCalendarCollectionViewCell")
        return collectionView
    }()

    private let resetButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.tintColor = .black
        return button
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.estimatedRowHeight = 140
        table.rowHeight = UITableView.automaticDimension
        return table
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("등록하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        return button
    }()

    // MARK: - Filter Data
    private var tagCellModel: [MercenaryFilterTagModel] = []
    private var selectedFilters: [String: String] = [:]

    var horizontalCalendarViewModel = HorizonralCalendarViewModel()

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
        setupFilterView()
        setupActions()
        fetchData()
        self.setupData()
    }

    private func setupData() {
        // Setup horizontal calendar data
        let dateRange = 90
        for nextDay in 0...dateRange {
            let cellData = HorizontalCalendarModel(date: makeDate(nextDay))
            self.horizontalCalendarViewModel.append(cellData)
        }

        // Setup filter tag data
        for filterType in MercenaryFilterType.allCases {
            let tagCellData = MercenaryFilterTagModel(filterType: filterType)
            self.tagCellModel.append(tagCellData)
        }
    }

    private func makeDate(_ nextDay: Int) -> Date {
        let calendar = Calendar.current
        let currentDate = Date()

        return calendar.date(byAdding: .day, value: nextDay, to: currentDate) ?? currentDate
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // viewDidLoad에서 이미 데이터를 로드하므로 여기서는 호출하지 않음
        // 무한 재귀 호출 방지
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white

        // Calendar header view
        let calendarHeaderView = UIView()
        calendarHeaderView.backgroundColor = .white
        view.addSubview(calendarHeaderView)
        calendarHeaderView.tag = 2001

        calendarHeaderView.addSubview(monthButton)

        // Horizontal calendar
        calendarHeaderView.addSubview(horizontalCalendarView)

        horizontalCalendarView.delegate = self
        horizontalCalendarView.dataSource = self

        // Filter tag container
        let filterTagContainer = UIView()
        filterTagContainer.backgroundColor = .systemBackground
        view.addSubview(filterTagContainer)
        filterTagContainer.tag = 2002

        filterTagContainer.addSubview(resetButtonView)
        resetButtonView.addSubview(resetButton)
        filterTagContainer.addSubview(filterTagCollectionView)

        // TableView
        view.addSubview(tableView)

        // Create Button
        view.addSubview(createButton)
    }

    private func setupLayout() {
        guard view.bounds.width > 0 else { return }

        let safeArea = view.safeAreaInsets
        let topOffset = safeArea.top
        let width = view.bounds.width

        guard let calendarHeaderView = view.viewWithTag(2001),
              let filterTagContainer = view.viewWithTag(2002) else { return }

        // Calendar header (팀 매치와 동일: 96pt)
        let calendarHeaderHeight: CGFloat = 96
        calendarHeaderView.frame = CGRect(
            x: 0,
            y: topOffset,
            width: width,
            height: calendarHeaderHeight
        )

        // Month button (왼쪽, 팀 매치와 동일)
        monthButton.frame = CGRect(x: 16, y: 15, width: 30, height: 34)

        // Horizontal calendar (right side)
        horizontalCalendarView.frame = CGRect(
            x: 58,
            y: -20,
            width: width - 58 - 17,
            height: calendarHeaderHeight
        )

        // Update collection view layout
        if let layout = horizontalCalendarView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = (horizontalCalendarView.frame.width - (12*6) - 8) / 7
            layout.itemSize = CGSize(width: itemWidth, height: 70)
        }

        // Filter tag container (팀 매치와 동일: 52pt)
        let filterTagHeight: CGFloat = 52
        let filterTagY = topOffset + calendarHeaderHeight + 1
        filterTagContainer.frame = CGRect(
            x: 0,
            y: filterTagY,
            width: width,
            height: filterTagHeight
        )

        // Reset button view (팀 매치와 동일: 38pt width)
        resetButtonView.frame = CGRect(x: 0, y: -20, width: 38, height: filterTagHeight)
        resetButton.frame = CGRect(x: 16, y: 15, width: 22, height: 22)

        // Filter tag collection view (팀 매치와 동일)
        filterTagCollectionView.frame = CGRect(
            x: 38,
            y: -20,
            width: width - 38,
            height: filterTagHeight
        )

        // TableView (팀 매치와 동일: -20 오버랩으로 간격 축소)
        let tableViewY = filterTagY + filterTagHeight - 20
        let tableViewHeight = view.bounds.height - tableViewY
        tableView.frame = CGRect(
            x: 0,
            y: tableViewY,
            width: width,
            height: tableViewHeight
        )

        // Create Button (팀 매치의 recruitment 버튼 위치 참고)
        let buttonSize: CGFloat = 60
        createButton.frame = CGRect(
            x: width - 20 - buttonSize,
            y: view.bounds.height - 100 - buttonSize,
            width: buttonSize,
            height: buttonSize
        )
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MercenaryMatchTableViewCell.self, forCellReuseIdentifier: MercenaryMatchTableViewCell.identifier)
    }

    private func setupFilterView() {
        filterTagCollectionView.delegate = self
        filterTagCollectionView.dataSource = self
    }

    private func setupActions() {
        monthButton.addTarget(self, action: #selector(monthButtonTapped), for: .touchUpInside)
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

    @objc private func resetFilterButtonTapped() {
        selectedFilters.removeAll()
        filterTagCollectionView.reloadData()
        monthButton.setTitle("2월", for: .normal)
        fetchData()
    }

    @objc private func createButtonTapped() {
        let requestVC = MercenaryRequestViewController()
        navigationController?.pushViewController(requestVC, animated: true)
    }

    // MARK: - Data Fetching
    private func fetchData() {
        viewModel.fetchMercenaryRequests { [weak self] success in
            self?.tableView.reloadData()
        }
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
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "M월"
            monthFormatter.locale = Locale(identifier: "ko_KR")
            monthButton.setTitle(monthFormatter.string(from: date), for: .normal)
            fetchData()
        }

        view.removeFromSuperview()
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension MercenaryMatchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === horizontalCalendarView {
            return horizontalCalendarViewModel.horizontalCount
        } else {
            return tagCellModel.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === horizontalCalendarView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCalendarCollectionViewCell", for: indexPath) as! HorizontalCalendarCollectionViewCell
            let calendarModel = horizontalCalendarViewModel.getSelectedDateModel(with: indexPath)
            cell.configure(calendarModel)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterButtonCell", for: indexPath) as! FilterButtonCollectionViewCell
            let filterModel = tagCellModel[indexPath.item]
            let isSelected = selectedFilters[filterModel.filterType.tagTitle] != nil
            cell.configure(with: filterModel.filterType.tagTitle, isSelected: isSelected)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === filterTagCollectionView {
            showFilterPicker(for: tagCellModel[indexPath.item])
        }
    }

    private func showFilterPicker(for filterModel: MercenaryFilterTagModel) {
        let alert = UIAlertController(title: filterModel.filterType.tagTitle, message: "선택하세요", preferredStyle: .actionSheet)

        let options = filterModel.filterType.filterList
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default) { _ in
                self.selectedFilters[filterModel.filterType.tagTitle] = option
                self.filterTagCollectionView.reloadData()
                self.fetchData()
            })
        }

        alert.addAction(UIAlertAction(title: "전체", style: .default) { _ in
            self.selectedFilters.removeValue(forKey: filterModel.filterType.tagTitle)
            self.filterTagCollectionView.reloadData()
            self.fetchData()
        })

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
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

// MARK: - FilterButtonCollectionViewCell
class FilterButtonCollectionViewCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(label)
        contentView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        contentView.layer.cornerRadius = 6

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12)
        ])
    }

    func configure(with title: String, isSelected: Bool) {
        label.text = title + (isSelected ? " ✓" : " ▼")
        contentView.backgroundColor = isSelected ? UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.2) : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
    }
}

