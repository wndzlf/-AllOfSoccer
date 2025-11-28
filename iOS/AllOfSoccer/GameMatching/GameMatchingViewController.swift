//
//  GameMatchingViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/04.
//

import UIKit
import FSCalendar

class GameMatchingViewController: UIViewController {
    // MARK: - ViewModel
    private var gameMatchingModel: GameMatchingViewModel = GameMatchingViewModel()
    var horizontalCalendarViewModel = HorizonralCalendarViewModel()

    // MARK: - HorizontalCalendar Variable
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
    
    // MARK: - FilterDetailView
    private let filterDetailView = FilterDetailView()
    private lazy var filterDetailBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        return view
    }()

    // MARK: - NoticeTableView Variable
    private let noticeTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 162
        tableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: "NoticeTableViewCell")
        return tableView
    }()

    // MARK: - FilterTagCollectionView Variable
    private var tagCellModel: [FilterTagModel] = []
    private var didSelectedFilterList: [String: FilterType] = [:]

    private let filterTagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 500, height: 28)
        layout.minimumInteritemSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.allowsMultipleSelection = true
        collectionView.register(FilterTagCollectionViewCell.self, forCellWithReuseIdentifier: "FilterTagCollectionViewCell")
        return collectionView
    }()
    
    private let resetButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ArrowsClockwise"), for: .normal)
        button.tintColor = .black
        return button
    }()

    // MARK: - NormalCalendarView Variable
//    private var norMalCalendarView = GameMatchingCalendarView()
    private var norMalCalendarDidSelectedDate: [Date] = []

    private let monthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = .black
        return button
    }()

    // MARK: - TableViewFilterView Variable
    private var sortMode = SortMode.distance

    // MARK: - RecruitmentButtonAction
    private lazy var recruitmentButton: RoundButton = {
        let button = RoundButton()
        button.setImage(UIImage(named: "cloth.fill"), for: .normal)
        button.cornerRadius = 30
        button.normalBackgroundColor = UIColor(named: "tagBackTouchUpColor") ?? UIColor()
        button.normalTitleColor = .white
        button.addTarget(self, action: #selector(teamRecruitmentButtonTouchUp(_:)), for: .touchUpInside)
        return button
    }()
    
    private let manRecruitmentButton: RoundButton = {
        let button = RoundButton()
        button.cornerRadius = 25
        button.setImage(UIImage(named: "man"), for: .normal)
        button.normalBackgroundColor = UIColor(named: "tagBackTouchUpColor") ?? UIColor()
        button.normalTitleColor = .white
        return button
    }()
    
    private let teamRecruitmentButton: RoundButton = {
        let button = RoundButton()
        button.cornerRadius = 25
        button.setImage(UIImage(named: "cloth.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "tagBackTouchUpColor")
        button.normalBackgroundColor = UIColor(named: "tagBackTouchUpColor") ?? UIColor()
        button.normalTitleColor = .white
        return button
    }()
    private var manRecruitmentButtonLabel: UILabel = {
        let label = UILabel()
        label.text = "용병 모집"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private var teamRecruitmentButtonLabel: UILabel = {
        let label = UILabel()
        label.text = "팀 모집"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private var recruitmentBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)

        return view
    }()

    // MARK: - CalendarMonthButtonAction
    @objc private func monthButtonTouchUp(_ sender: UIButton) {
        //중현: 추후에 기능 추가
//        let norMalCalendarView = GameMatchingCalendarView.make(selectedDates: self.gameMatchingModel.selectedDate, delegate: self)
//        self.setSubViewConstraints(view: norMalCalendarView)
    }

    @objc private func resetTagButtonTouchUp(_ sender: UIButton) {
        self.didSelectedFilterList.removeAll()
        self.filterDetailView.didSelectedFilterList.removeAll()
        self.filterTagCollectionView.reloadData()
        self.tagCollectionViewCellIsNotSelectedViewSetting()
        
        // 필터 초기화
        self.gameMatchingModel.clearFilters()
    }

    // MARK: - RecruitmentButtonAction
    @objc private func recruitmentButtonTouchUp(_ sender: UIButton) {
        self.didSelectedRecruitmentButtonSetting(sender.isSelected)
    }

    // 뷰 완성시 코드 추가할 예정
    @objc private func teamRecruitmentButtonTouchUp(_ sender: UIButton) {
        let vc = FirstTeamRecruitmentViewController()
        self.didSelectedRecruitmentButtonSetting(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func manRecruitmentButtonTouchUp(_ sender: UIButton) {
        let vc = FirstTeamRecruitmentViewController()
        self.didSelectedRecruitmentButtonSetting(true)
        self.navigationController?.pushViewController(vc, animated: true)

    }

    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "팀 매치"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]

        self.gameMatchingModel.presenter = self
        
        setupUI()
        setupActions()
        setupData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.title = "팀 매치"
        self.navigationController?.setNavigationBarHidden(false, animated: animated)

        self.recruitmentButton.isHidden = false
        self.manRecruitmentButton.isHidden = false
        self.teamRecruitmentButton.isHidden = false
        self.tabBarController?.view.insertSubview(self.recruitmentButton, at: self.tabBarController?.view.subviews.count ?? 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.recruitmentButton.isHidden = true
//        self.manRecruitmentButton.isHidden = true
//        self.teamRecruitmentButton.isHidden = true
        self.tabBarController?.view.insertSubview(self.recruitmentButton, at: self.tabBarController?.view.subviews.count ?? 0)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.933, green: 0.937, blue: 0.945, alpha: 1)
        
        // Calendar header view (contains month button and horizontal calendar)
        let calendarHeaderView = UIView()
        calendarHeaderView.backgroundColor = .white
        view.addSubview(calendarHeaderView)
        calendarHeaderView.tag = 1001 // Tag for later reference
        
        // Month button
        calendarHeaderView.addSubview(monthButton)
        monthButton.setTitle(makeMonthButtonText(), for: .normal)
        
        // Horizontal calendar
        calendarHeaderView.addSubview(horizontalCalendarView)
        
        // Filter tag container (contains reset button and filter collection view)
        let filterTagContainer = UIView()
        filterTagContainer.backgroundColor = .systemBackground
        view.addSubview(filterTagContainer)
        filterTagContainer.tag = 1002 // Tag for later reference
        
        // Reset button view
        filterTagContainer.addSubview(resetButtonView)
        resetButtonView.addSubview(resetButton)
        
        // Filter tag collection view
        filterTagContainer.addSubview(filterTagCollectionView)
        
        // Notice table view
        view.addSubview(noticeTableView)
        
        // Recruitment buttons (added to tabBarController view later)
        setupRecruitmentButtons()
        
        // Filter detail view setup
        setupFilterDetailView()
        
        // Delegates
        horizontalCalendarView.delegate = self
        horizontalCalendarView.dataSource = self
        
        filterTagCollectionView.delegate = self
        filterTagCollectionView.dataSource = self
        
        noticeTableView.delegate = self
        noticeTableView.dataSource = self
    }
    
    private func setupLayout() {
        guard view.bounds.width > 0 else { return }
        
        let safeArea = view.safeAreaInsets
        let topOffset = safeArea.top
        let width = view.bounds.width
        
        // Get the calendar header view and filter container
        guard let calendarHeaderView = view.viewWithTag(1001),
              let filterTagContainer = view.viewWithTag(1002) else { return }
        
        // Calendar header view (96pt height) - positioned right after safe area
        let calendarHeaderHeight: CGFloat = 96
        calendarHeaderView.frame = CGRect(
            x: 0,
            y: topOffset,
            width: width,
            height: calendarHeaderHeight
        )
        
        // Month button (left side, vertically centered)
        monthButton.frame = CGRect(x: 16, y: 31, width: 30, height: 34)
        
        // Horizontal calendar (right side)
        horizontalCalendarView.frame = CGRect(
            x: 58,
            y: 0,
            width: width - 58 - 17,
            height: calendarHeaderHeight
        )
        
        // Update collection view layout
        if let layout = horizontalCalendarView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = (horizontalCalendarView.frame.width - (12*6) - 8) / 7
            layout.itemSize = CGSize(width: itemWidth, height: 70)
        }
        
        // Filter tag container (52pt height) - positioned right after calendar header
        let filterTagHeight: CGFloat = 52
        let filterTagY = topOffset + calendarHeaderHeight + 1
        filterTagContainer.frame = CGRect(
            x: 0,
            y: filterTagY,
            width: width,
            height: filterTagHeight
        )
        
        // Reset button view (left side, 38pt width)
        resetButtonView.frame = CGRect(x: 0, y: 0, width: 38, height: filterTagHeight)
        resetButton.frame = CGRect(x: 16, y: 15, width: 22, height: 22)
        
        // Filter tag collection view (right side)
        filterTagCollectionView.frame = CGRect(
            x: 38,
            y: 0,
            width: width - 38,
            height: filterTagHeight
        )
        
        // Notice table view (remaining space) - positioned after filter container
        let tableViewY = filterTagY + filterTagHeight
        let tableViewHeight = view.bounds.height - tableViewY - safeArea.bottom
        noticeTableView.frame = CGRect(
            x: 0,
            y: tableViewY,
            width: width,
            height: tableViewHeight
        )
        
        // Setup recruitment button layout if tabBarController is available
        if let tabBarController = self.tabBarController {
            setupRecruitmentButtonLayout(in: tabBarController.view)
            setupFilterDetailViewLayout(in: tabBarController.view)
        }
    }
    
    private func setupRecruitmentButtons() {
        // Setup button properties
//        recruitmentButton.setImage(UIImage(systemName: "plus"), for: .normal)
//        recruitmentButton.setImage(UIImage(systemName: "xmark"), for: .selected)
        recruitmentButton.setBackgroundColor(UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1), for: .normal)
//        recruitmentButton.setBackgroundColor(.white, for: .selected)
        recruitmentButton.clipsToBounds = true
        recruitmentButton.tintColor = .white
    }
    
    private func setupRecruitmentButtonLayout(in parentView: UIView) {
        // Add to parent view if not already added
        if recruitmentButton.superview == nil {
            parentView.addSubview(recruitmentBackgroundView)
            parentView.addSubview(recruitmentButton)
            parentView.addSubview(manRecruitmentButton)
            parentView.addSubview(teamRecruitmentButton)
            parentView.addSubview(manRecruitmentButtonLabel)
            parentView.addSubview(teamRecruitmentButtonLabel)
        }
        
        recruitmentBackgroundView.frame = parentView.bounds
        recruitmentBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        recruitmentBackgroundView.isHidden = true
        
        // Main recruitment button (60x60, bottom-right)
        let buttonSize: CGFloat = 60
        recruitmentButton.frame = CGRect(
            x: parentView.bounds.width - 20 - buttonSize,
            y: parentView.bounds.height - 100 - buttonSize,
            width: buttonSize,
            height: buttonSize
        )
        
        // Man recruitment button (50x50)
        let smallButtonSize: CGFloat = 50
        manRecruitmentButton.frame = CGRect(
            x: parentView.bounds.width - 25 - smallButtonSize,
            y: parentView.bounds.height - 105 - smallButtonSize,
            width: smallButtonSize,
            height: smallButtonSize
        )
        manRecruitmentButton.isHidden = true
        
        // Team recruitment button (50x50)
        teamRecruitmentButton.frame = CGRect(
            x: parentView.bounds.width - 25 - smallButtonSize,
            y: parentView.bounds.height - 105 - smallButtonSize,
            width: smallButtonSize,
            height: smallButtonSize
        )
        teamRecruitmentButton.isHidden = true
        
        // Labels
        manRecruitmentButtonLabel.sizeToFit()
        manRecruitmentButtonLabel.frame.origin = CGPoint(
            x: manRecruitmentButton.frame.minX - manRecruitmentButtonLabel.frame.width - 10,
            y: manRecruitmentButton.frame.midY - manRecruitmentButtonLabel.frame.height / 2
        )
        manRecruitmentButtonLabel.isHidden = true
        
        teamRecruitmentButtonLabel.sizeToFit()
        teamRecruitmentButtonLabel.frame.origin = CGPoint(
            x: teamRecruitmentButton.frame.minX - teamRecruitmentButtonLabel.frame.width - 10,
            y: teamRecruitmentButton.frame.midY - teamRecruitmentButtonLabel.frame.height / 2
        )
        teamRecruitmentButtonLabel.isHidden = true
    }
    
    private func setupActions() {
        monthButton.addTarget(self, action: #selector(monthButtonTouchUp(_:)), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTagButtonTouchUp(_:)), for: .touchUpInside)
        recruitmentButton.addTarget(self, action: #selector(recruitmentButtonTouchUp(_:)), for: .touchUpInside)
        manRecruitmentButton.addTarget(self, action: #selector(manRecruitmentButtonTouchUp(_:)), for: .touchUpInside)
        teamRecruitmentButton.addTarget(self, action: #selector(teamRecruitmentButtonTouchUp(_:)), for: .touchUpInside)
    }
    
    private func setupData() {
        // Setup horizontal calendar data
        let dateRange = 90
        for nextDay in 0...dateRange {
            let cellData = HorizontalCalendarModel(date: makeDate(nextDay))
            self.horizontalCalendarViewModel.append(cellData)
        }
        
        // Setup filter tag data
        for filterType in FilterType.allCases {
            let tagCellData = FilterTagModel(filterType: filterType)
            self.tagCellModel.append(tagCellData)
        }
    }

    // MARK: - Setup View (Deprecated methods - kept for compatibility)
    private func setupHorizontalCalendarView() {
        // This method is now handled in setupUI and setupLayout
    }

    private func setupFilterTagCollectionView() {
        // This method is now handled in setupUI and setupLayout
    }

    private func setupFilterDetailView() {
        self.filterDetailView.delegate = self

        self.filterDetailView.isHidden = true
        self.filterDetailBackgroundView.isHidden = true
        
        // 배경 탭 제스처 추가 (필터 콘텐츠 영역 제외)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterDetailBackgroundTapped))
        tapGesture.delegate = self
        self.filterDetailBackgroundView.addGestureRecognizer(tapGesture)
    }
    
    private func setupFilterDetailViewLayout(in parentView: UIView) {
        // Add to parent view if not already added
        if filterDetailBackgroundView.superview == nil {
            parentView.addSubview(filterDetailBackgroundView)
            filterDetailBackgroundView.addSubview(filterDetailView)
        }
        
        // Background view fills entire parent
        filterDetailBackgroundView.frame = parentView.bounds
        filterDetailBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Filter detail view at bottom with initial height
        let initialHeight: CGFloat = 244
        let detailWidth = parentView.bounds.width
        let detailY = parentView.bounds.height - initialHeight
        
        filterDetailView.frame = CGRect(
            x: 0,
            y: detailY,
            width: detailWidth,
            height: initialHeight
        )
    }

    private func makeDate(_ nextDay: Int) -> Date {
        let calendar = Calendar.current
        let currentDate = Date()

        return calendar.date(byAdding: .day, value: nextDay, to: currentDate) ?? currentDate
    }

    private func makeMonthButtonText() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월"
        let monthString = dateFormatter.string(from: currentDate)
        
        return monthString
    }

    private func tagCollectionViewCellIsNotSelectedViewSetting() {
        // 리셋 버튼은 항상 표시되므로 애니메이션 제거
    }

    private func tagCollectionViewCellIsSelectedViewSetting() {
        // 리셋 버튼은 항상 표시되므로 애니메이션 제거
    }

    private func setSubViewConstraints(view: UIView) {

        guard let tabBarController = self.tabBarController else { return }

        tabBarController.view.addsubviews(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: tabBarController.view.topAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: tabBarController.view.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: tabBarController.view.trailingAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: tabBarController.view.bottomAnchor, constant: 0)
        ])
    }

    private func setupRecruitmentButtonIsSelected() {
        self.recruitmentBackgroundView.isHidden = false
        self.manRecruitmentButton.isHidden = false
        self.teamRecruitmentButton.isHidden = false

        self.manRecruitmentButton.translatesAutoresizingMaskIntoConstraints = true
        self.teamRecruitmentButton.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.manRecruitmentButton.frame = CGRect(x: self.manRecruitmentButton.frame.minX, y: self.recruitmentButton.frame.minY - self.manRecruitmentButton.frame.height - 16, width: self.manRecruitmentButton.frame.width, height: self.manRecruitmentButton.frame.height)
            self.teamRecruitmentButton.frame = CGRect(x: self.teamRecruitmentButton.frame.minX, y: self.recruitmentButton.frame.minY - self.manRecruitmentButton.frame.height - self.teamRecruitmentButton.frame.height - 32, width: self.manRecruitmentButton.frame.width, height: self.manRecruitmentButton.frame.height)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.teamRecruitmentButtonLabel.isHidden = false
            self.manRecruitmentButtonLabel.isHidden = false
        }

        self.tabBarController?.view.insertSubview(self.recruitmentButton, at: self.tabBarController?.view.subviews.count ?? 0)
    }

    private func setupRecruitmentButtonIsDeSelected() {

        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }

            self.manRecruitmentButton.frame = CGRect(x: self.recruitmentButton.frame.minX + 5, y: self.recruitmentButton.frame.minY + 5, width: self.manRecruitmentButton.frame.width, height: self.manRecruitmentButton.frame.height)
            self.teamRecruitmentButton.frame = CGRect(x: self.recruitmentButton.frame.minX + 5, y: self.recruitmentButton.frame.minY + 5, width: self.teamRecruitmentButton.frame.width, height: self.teamRecruitmentButton.frame.height)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.recruitmentBackgroundView.isHidden = true
            self.teamRecruitmentButton.isHidden = true
            self.manRecruitmentButton.isHidden = true
            self.tabBarController?.view.insertSubview(self.recruitmentButton, at: self.tabBarController?.view.subviews.count ?? 0)
        }

        self.manRecruitmentButtonLabel.isHidden = true
        self.teamRecruitmentButtonLabel.isHidden = true
    }

    @objc private func filterDetailBackgroundTapped() {
        // 배경 탭 시 필터 닫기 (X버튼과 동일한 동작)
        self.cancelButtonDidSelected(self.filterDetailView, selectedList: [])
    }
}

// MARK: - CollectionViewDelegate
extension GameMatchingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.horizontalCalendarView {
            self.monthButton.setTitle(self.horizontalCalendarViewModel.makeMonthText(indexPath: indexPath), for: .normal)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.horizontalCalendarView {
            let seletedHorizontalDate = self.horizontalCalendarViewModel.getSelectedDateModel(with: indexPath).date
            self.gameMatchingModel.append([], seletedHorizontalDate)
            print("중현: 날짜가 선택됨, 선택된 날짜에 따라 필터 필요함. \(self.gameMatchingModel.selectedDate)")
        } else if collectionView == self.filterTagCollectionView {
            self.filterDetailView.filterType = self.tagCellModel[indexPath.item].filterType
            self.appearFilterDetailView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == self.horizontalCalendarView {
            // 데이터 처리
            let deSeletedHorizontalDate = self.horizontalCalendarViewModel.getSelectedDateModel(with: indexPath).date
            self.gameMatchingModel.delete(deSeletedHorizontalDate)
        } else if collectionView == self.filterTagCollectionView {
            // 데이터 처리
        }
    }

    private func appearFilterDetailView() {
        guard let tabbar = self.tabBarController else { return }
        
        self.filterDetailView.isHidden = false
        self.filterDetailBackgroundView.isHidden = false
        self.filterDetailBackgroundView.alpha = 0 // 초기 투명도 설정
        
        self.recruitmentButton.isHidden = true
        self.manRecruitmentButton.isHidden = true
        self.teamRecruitmentButton.isHidden = true

        // 초기 위치를 화면 밖(하단)으로 설정
        let viewHeight: CGFloat = 244
        let viewWidth = tabbar.view.bounds.width
        filterDetailView.frame = CGRect(
            x: 0,
            y: tabbar.view.bounds.height,
            width: viewWidth,
            height: viewHeight
        )
        
        // Spring Animation 적용
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            
            // 하단에서 올라오도록 frame 업데이트
            self.filterDetailView.frame = CGRect(
                x: 0,
                y: tabbar.view.bounds.height - viewHeight,
                width: viewWidth,
                height: viewHeight
            )
            
            // 배경 투명도 애니메이션
            self.filterDetailBackgroundView.alpha = 1.0
        }
    }

    private func didSelectedRecruitmentButtonSetting(_ isSelected: Bool) {
        if isSelected {
            setupRecruitmentButtonIsDeSelected()
            self.recruitmentButton.isSelected = false
            self.recruitmentButton.tintColor = .white
        } else {
            setupRecruitmentButtonIsSelected()
            self.recruitmentButton.isSelected = true
            self.recruitmentButton.tintColor = UIColor(red: 236.0/255.0, green: 95.0/255.0, blue: 95.0/255.0, alpha: 1.0)
        }
    }

}

// MARK: - CollectionViewDataSource
extension GameMatchingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.horizontalCalendarView {
            return self.horizontalCalendarViewModel.horizontalCount
        } else {
            return self.tagCellModel.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.horizontalCalendarView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCalendarCollectionViewCell", for: indexPath) as? HorizontalCalendarCollectionViewCell else {
                return .init()
            }

            cell.configure(self.horizontalCalendarViewModel.getSelectedDateModel(with: indexPath))

            let selectedDate = self.gameMatchingModel.formalStrSelectedDate
            let horizontalDate = self.horizontalCalendarViewModel.formalStrHorizontalCalendarDates[indexPath.item]

            if !selectedDate.isEmpty {
                for date in selectedDate {
                    if date == horizontalDate {
                        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
                    }
                }
            }

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterTagCollectionViewCell", for: indexPath) as? FilterTagCollectionViewCell else {
                return .init()
            }
            cell.configure(self.tagCellModel[indexPath.item], self.didSelectedFilterList)

            return cell
        }
    }
}

// MARK: - CollectionViewFlowLayout
extension GameMatchingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
}

// MARK: - TableViewDelegate
extension GameMatchingViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 원본 Match 데이터 가져오기
        guard let originalMatch = self.gameMatchingModel.getOriginalMatch(at: indexPath) else {
            print("원본 데이터를 찾을 수 없습니다.")
            return
        }
        
        // 원본 데이터로 DetailViewModel 생성
        let detailViewModel = GameMatchingDetailViewModel(match: originalMatch)
        let vc = GameMatchingDetailViewController(viewModel: detailViewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - TableViewDatasource
extension GameMatchingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameMatchingModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeTableViewCell.defaultIdentifier, for: indexPath) as? NoticeTableViewCell else {
            return UITableViewCell()
        }

        cell.update(viewModel: self.gameMatchingModel.fetchViewModel(indexPath: indexPath))
        
        // 좋아요 버튼 동작 연결
        cell.didTapLikeButton = { [weak self] in
            self?.gameMatchingModel.toggleLike(at: indexPath)
        }

        return cell
    }
}


// MARK: - GameMatchingCalendarDelegate
extension GameMatchingViewController: GameMatchingCalendarViewDelegate {
    func okButtonDidSelected(sender: GameMatchingCalendarView, selectedDates: [Date]) {
        self.gameMatchingModel.append(selectedDates, nil)
        self.horizontalCalendarView.reloadData()
        sender.removeFromSuperview()
    }

    func cancelButtonDidSelected(sender: GameMatchingCalendarView) {
        sender.removeFromSuperview()
    }
}

// MARK: - TableViewFilterViewDelegate
extension GameMatchingViewController: TableViewFilterViewDelegate {
    func cancelButtonDidSelected(sender: TableViewFilterView) {
        sender.removeFromSuperview()
    }

    func okButtonDidSelected(sender: TableViewFilterView, sortMode: SortMode) {
        self.sortMode = sortMode
        // tableViewFilterButton이 제거되었으므로 해당 라인 제거
        sender.removeFromSuperview()
    }
}

// MARK: - FilterDetailViewDelegate
extension GameMatchingViewController: FilterDetailViewDelegate {

    func finishButtonDidSelected(_ detailView: FilterDetailView, selectedList: [String]) {
        guard let tabbar = self.tabBarController else { return }
        let viewHeight: CGFloat = 244
        let viewWidth = tabbar.view.bounds.width
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            // 하단으로 내려가도록 frame 업데이트
            self.filterDetailView.frame = CGRect(
                x: 0,
                y: tabbar.view.bounds.height,
                width: viewWidth,
                height: viewHeight
            )
            self.filterDetailBackgroundView.alpha = 0 // 배경 투명하게
        } completion: { _ in
            self.filterDetailBackgroundView.isHidden = true
            self.filterDetailView.isHidden = true
            self.filterDetailBackgroundView.alpha = 1.0 // 다음 표시를 위해 초기화 (필요시)
            
            self.recruitmentButton.isHidden = false
            self.manRecruitmentButton.isHidden = false
            self.teamRecruitmentButton.isHidden = false

            self.didSelectedFilterList = detailView.didSelectedFilterList

            if self.didSelectedFilterList.isEmpty {
                self.tagCollectionViewCellIsNotSelectedViewSetting()
            } else {
                self.tagCollectionViewCellIsSelectedViewSetting()
                self.refresh()
            }
        }
    }

    private func refresh() {
        // 선택된 필터들을 분류
        var locationFilters: [String] = []
        var gameTypeFilters: [String] = []
        
        for (filterKey, filterType) in self.didSelectedFilterList {
            switch filterType {
            case .location:
                locationFilters.append(filterKey)
            case .game:
                gameTypeFilters.append(filterKey)
            }
        }
        
        print("중현: 선택된 location filter: \(locationFilters)")
        print("중현: 선택된 game filter: \(gameTypeFilters)")
        
        // ViewModel에 필터 적용
        self.gameMatchingModel.applyFilters(locationFilters: locationFilters, gameTypeFilters: gameTypeFilters)
        
        // 태그 컬렉션뷰 업데이트
        self.filterTagCollectionView.reloadData()
    }

    func cancelButtonDidSelected(_ detailView: FilterDetailView, selectedList: [String]) {
        guard let tabbar = self.tabBarController else { return }
        let viewHeight: CGFloat = 244
        let viewWidth = tabbar.view.bounds.width
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            // 하단으로 내려가도록 frame 업데이트
            self.filterDetailView.frame = CGRect(
                x: 0,
                y: tabbar.view.bounds.height,
                width: viewWidth,
                height: viewHeight
            )
            self.filterDetailBackgroundView.alpha = 0 // 배경 투명하게
        } completion: { _ in
            self.filterDetailBackgroundView.isHidden = true
            self.filterDetailView.isHidden = true
            self.filterDetailBackgroundView.alpha = 1.0 // 다음 표시를 위해 초기화
            
            self.recruitmentButton.isHidden = false
            self.manRecruitmentButton.isHidden = false
            self.teamRecruitmentButton.isHidden = false
        }
    }
}

extension GameMatchingViewController: GameMatchingPresenter {

    internal func reloadMatchingList() {
        self.noticeTableView.reloadData()
    }

    internal func showErrorMessage() {
        print("네트워크 상태가 불안정 합니다.")
    }
}

// MARK: - UIGestureRecognizerDelegate
extension GameMatchingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 필터 콘텐츠 영역을 탭한 경우는 제외
        let location = touch.location(in: self.filterDetailBackgroundView)
        return !self.filterDetailView.frame.contains(location)
    }
}
