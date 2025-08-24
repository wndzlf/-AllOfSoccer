//
//  GameMatchingViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/04.
//

import UIKit
import FSCalendar
import SnapKit

class GameMatchingViewController: UIViewController {
    // MARK: - ViewModel
    private var gameMatchingModel: GameMatchingViewModel = GameMatchingViewModel()
    var horizontalCalendarViewModel = HorizonralCalendarViewModel()

    // MARK: - MatchingModeButton Variable
    @IBOutlet private weak var teamMatchButton: IBSelectTableButton!
    @IBOutlet private weak var manMatchButton: IBSelectTableButton!
    @IBOutlet private weak var selectedLineCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var selectedLineWidthConstraint: NSLayoutConstraint!

    // MARK: - HorizontalCalendar Variable
    @IBOutlet private weak var horizontalCalendarView: UICollectionView!
    
    // MARK: - FilterDetailView
    private let filterDetailView = FilterDetailView()
    private var bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private lazy var filterDetailBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        return view
    }()

    // MARK: - NoticeTableView Variable
    @IBOutlet private weak var noticeTableView: UITableView!

    // MARK: - FilterTagCollectionView Variable
    private var tagCellModel: [FilterTagModel] = []
    private var didSelectedFilterList: [String: FilterType] = [:]

    @IBOutlet private weak var filterTagCollectionView: UICollectionView!
    @IBOutlet private weak var resetButtonView: UIView!
    @IBOutlet private weak var tagCollectionViewConstraint: NSLayoutConstraint!

    // MARK: - NormalCalendarView Variable
//    private var norMalCalendarView = GameMatchingCalendarView()
    private var norMalCalendarDidSelectedDate: [Date] = []

    @IBOutlet private weak var monthButton: UIButton!

    // MARK: - TableViewFilterView Variable
    private var sortMode = SortMode.distance

    @IBOutlet private weak var tableViewFilterButton: UIButton!

    // MARK: - RecruitmentButtonAction
    @IBOutlet private weak var recruitmentButton: RoundButton!
    @IBOutlet private weak var manRecruitmentButton: RoundButton!
    @IBOutlet private weak var teamRecruitmentButton: RoundButton!
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

    // MARK: - MatchingModeButtonAction
    @IBAction private func teamMatchButtonTouchUp(_ sender: Any) {
        self.teamMatchButton.isSelected = true
        self.manMatchButton.isSelected = false

        let teamMatchingButtonWidth = self.teamMatchButton.frame.width

        UIView.animate(withDuration: 0.1) { [weak self] in

            guard let self = self else { return }

            self.selectedLineCenterConstraint.constant = 0
            self.selectedLineWidthConstraint.constant = teamMatchingButtonWidth
            self.view.layoutIfNeeded()
        }
    }

    @IBAction private func manMatchButtonTouchUp(_ sender: Any) {
        self.teamMatchButton.isSelected = false
        self.manMatchButton.isSelected = true

        let constant = manMatchButton.center.x - teamMatchButton.center.x
        let manMatchingButtonWidth = self.manMatchButton.frame.width

        UIView.animate(withDuration: 0.1) { [weak self] in

            guard let self = self else { return }

            self.selectedLineCenterConstraint.constant = constant
            self.selectedLineWidthConstraint.constant = manMatchingButtonWidth
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - CalendarMonthButtonAction
    @IBAction func monthButtonTouchUp(_ sender: UIButton) {
        //중현: 추후에 기능 추가
//        let norMalCalendarView = GameMatchingCalendarView.make(selectedDates: self.gameMatchingModel.selectedDate, delegate: self)
//        self.setSubViewConstraints(view: norMalCalendarView)
    }

    @IBAction private func resetTagButtonTouchUp(_ sender: UIButton) {
        self.didSelectedFilterList.removeAll()
        self.filterDetailView.didSelectedFilterList.removeAll()
        self.filterTagCollectionView.reloadData()
        self.tagCollectionViewCellIsNotSelectedViewSetting()
    }

    @IBAction func tableViewSortingButtonTouchUp(_ sender: UIButton) {

        let tableViewFilterView = TableViewFilterView()
        tableViewFilterView.delegate = self
        setSubViewConstraints(view: tableViewFilterView)
    }

    // MARK: - RecruitmentButtonAction
    @IBAction private func recruitmentButtonTouchUp(_ sender: UIButton) {
        self.didSelectedRecruitmentButtonSetting(sender.isSelected)
    }

    // 뷰 완성시 코드 추가할 예정
    @IBAction private func teamRecruitmentButtonTouchUp(_ sender: UIButton) {
        guard let teamRecruitmentNavigationController = UIStoryboard.init(name: "TeamRecruitment", bundle: nil).instantiateViewController(identifier: "TeamRecruitmentNavigationController") as? UINavigationController  else { return }

        teamRecruitmentNavigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(teamRecruitmentNavigationController, animated: true, completion: nil)
    }

    @IBAction private func manRecruitmentButtonTouchUp(_ sender: UIButton) {
        guard let manRecruitmentNavigationController = UIStoryboard.init(name: "ManRecruitment", bundle: nil).instantiateViewController(identifier: "ManRecruitmentNavigationController") as? UINavigationController  else { return }

        manRecruitmentNavigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(manRecruitmentNavigationController, animated: true, completion: nil)
    }

    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gameMatchingModel.presenter = self

        self.setupModeButtonUnderLine()
        self.setupHorizontalCalendarView()
        self.setupFilterTagCollectionView()
        self.setupFilterDetailView()
        self.setupNoticeTableView()
        self.setupRecruitmentButton()

        self.setupFilterDetailViewConstraint()
        self.setupRecruitmentButtonConstraint()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)

        self.recruitmentButton.isHidden = false
        self.manRecruitmentButton.isHidden = false
        self.teamRecruitmentButton.isHidden = false
        self.tabBarController?.view.insertSubview(self.recruitmentButton, at: self.tabBarController?.view.subviews.count ?? 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(false)

        self.recruitmentButton.isHidden = true
        self.manRecruitmentButton.isHidden = true
        self.teamRecruitmentButton.isHidden = true
        self.tabBarController?.view.insertSubview(self.recruitmentButton, at: self.tabBarController?.view.subviews.count ?? 0)
    }

    // MARK: - Setup View
    private func setupModeButtonUnderLine() {
        let teamMatchingButtonConstant = self.teamMatchButton.frame.width

        self.selectedLineWidthConstraint.constant = teamMatchingButtonConstant
    }

    private func setupHorizontalCalendarView() {
        self.horizontalCalendarView.delegate = self
        self.horizontalCalendarView.dataSource = self
        self.horizontalCalendarView.allowsMultipleSelection = true

        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.minimumInteritemSpacing = 12 // 적절한 간격으로 조정
        flowlayout.minimumLineSpacing = 10
        flowlayout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) // 여백 조정
        flowlayout.scrollDirection = .horizontal

        let itemWidth = (self.horizontalCalendarView.frame.width - (12*6) - 8) / 7 // 간격 조정
        flowlayout.itemSize = CGSize(width: itemWidth, height: 70) // 높이 조정
        self.horizontalCalendarView.collectionViewLayout = flowlayout

        let dateRange = 90
        for nextDay in 0...dateRange {
            let cellData = HorizontalCalendarModel(date: makeDate(nextDay))
            self.horizontalCalendarViewModel.append(cellData)
        }
    }

    private func setupFilterTagCollectionView() {

        self.filterTagCollectionView.delegate = self
        self.filterTagCollectionView.dataSource = self
        self.filterTagCollectionView.allowsMultipleSelection = true

        let tagCollectionViewLayout = UICollectionViewFlowLayout()
        tagCollectionViewLayout.estimatedItemSize = CGSize(width: 500, height: 28)
        tagCollectionViewLayout.minimumInteritemSpacing = 6
        tagCollectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tagCollectionViewLayout.scrollDirection = .horizontal
        self.filterTagCollectionView.collectionViewLayout = tagCollectionViewLayout

        self.tagCollectionViewConstraint.constant = -(self.resetButtonView.frame.width)
        self.resetButtonView.isHidden = true

        for filterType in FilterType.allCases {
            let tagCellData = FilterTagModel(filterType: filterType)
            self.tagCellModel.append(tagCellData)
        }
    }

    private func setupFilterDetailView() {
        self.filterDetailView.delegate = self

        self.filterDetailView.isHidden = true
        self.filterDetailBackgroundView.isHidden = true
    }

    private func setupNoticeTableView() {
        self.noticeTableView.delegate = self
        self.noticeTableView.dataSource = self
    }

    private func setupRecruitmentButton() {
        self.recruitmentButton.setImage(UIImage(systemName: "plus"), for: .normal)
        self.recruitmentButton.setImage(UIImage(systemName: "xmark"), for: .selected)
        self.recruitmentButton.setBackgroundColor(UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1), for: .normal)
        self.recruitmentButton.setBackgroundColor(.white, for: .selected)
        self.recruitmentButton.clipsToBounds = true
    }

    private func setupFilterDetailViewConstraint() {

        guard let tabBarController = self.tabBarController else { return }

        tabBarController.view.addSubview(self.filterDetailBackgroundView)
        self.filterDetailBackgroundView.addSubview(self.filterDetailView)
        self.filterDetailBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.filterDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        // 초기 높이 설정 (최소 높이)
        let initialHeight: CGFloat = 244
        let topMargin: CGFloat = 150 // 상단 딤드 영역

        NSLayoutConstraint.activate([
            self.filterDetailBackgroundView.leadingAnchor.constraint(equalTo: tabBarController.view.leadingAnchor, constant: 0),
            self.filterDetailBackgroundView.topAnchor.constraint(equalTo: tabBarController.view.topAnchor, constant: 0),
            self.filterDetailBackgroundView.bottomAnchor.constraint(equalTo: tabBarController.view.bottomAnchor, constant: 0),
            self.filterDetailBackgroundView.trailingAnchor.constraint(equalTo: tabBarController.view.trailingAnchor, constant: 0),

            self.filterDetailView.leadingAnchor.constraint(equalTo: self.filterDetailBackgroundView.leadingAnchor, constant: 0),
            self.filterDetailView.trailingAnchor.constraint(equalTo: self.filterDetailBackgroundView.trailingAnchor, constant: 0),
            self.filterDetailView.heightAnchor.constraint(greaterThanOrEqualToConstant: initialHeight),
            self.filterDetailView.topAnchor.constraint(equalTo: self.filterDetailBackgroundView.topAnchor, constant: topMargin)
        ])
    }

    private func setupRecruitmentButtonConstraint() {

        guard let tabBarController = self.tabBarController else { return }

        tabBarController.view.addsubviews(self.recruitmentButton, self.recruitmentBackgroundView, self.manRecruitmentButton, self.teamRecruitmentButton, self.manRecruitmentButtonLabel, self.teamRecruitmentButtonLabel)

        self.recruitmentBackgroundView.isHidden = true
        self.manRecruitmentButton.isHidden = true
        self.teamRecruitmentButton.isHidden = true
        self.manRecruitmentButtonLabel.isHidden = true
        self.teamRecruitmentButtonLabel.isHidden = true

        NSLayoutConstraint.activate([
            self.recruitmentButton.bottomAnchor.constraint(equalTo: tabBarController.view.bottomAnchor, constant: -100),
            self.recruitmentButton.trailingAnchor.constraint(equalTo: tabBarController.view.trailingAnchor, constant: -20),

            self.recruitmentBackgroundView.topAnchor.constraint(equalTo: tabBarController.view.topAnchor, constant: 0),
            self.recruitmentBackgroundView.leadingAnchor.constraint(equalTo: tabBarController.view.leadingAnchor, constant: 0),
            self.recruitmentBackgroundView.trailingAnchor.constraint(equalTo: tabBarController.view.trailingAnchor, constant: 0),
            self.recruitmentBackgroundView.bottomAnchor.constraint(equalTo: tabBarController.view.bottomAnchor, constant: 0),

            self.manRecruitmentButton.bottomAnchor.constraint(equalTo: tabBarController.view.bottomAnchor, constant: -105),
            self.manRecruitmentButton.trailingAnchor.constraint(equalTo: tabBarController.view.trailingAnchor, constant: -25),

            self.teamRecruitmentButton.bottomAnchor.constraint(equalTo: tabBarController.view.bottomAnchor, constant: -105),
            self.teamRecruitmentButton.trailingAnchor.constraint(equalTo: tabBarController.view.trailingAnchor, constant: -25),

            self.manRecruitmentButtonLabel.centerYAnchor.constraint(equalTo: self.manRecruitmentButton.centerYAnchor),
            self.manRecruitmentButtonLabel.trailingAnchor.constraint(equalTo: self.manRecruitmentButton.leadingAnchor, constant: -10),

            self.teamRecruitmentButtonLabel.centerYAnchor.constraint(equalTo: self.teamRecruitmentButton.centerYAnchor),
            self.teamRecruitmentButtonLabel.trailingAnchor.constraint(equalTo: self.teamRecruitmentButton.leadingAnchor, constant: -10)
        ])
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
        let resetButtonViewWidth = self.resetButtonView.frame.width
        UIView.animate(withDuration: 0.05) { [weak self] in
            self?.tagCollectionViewConstraint.constant = -(resetButtonViewWidth)
            self?.resetButtonView.isHidden = true
            self?.view.layoutIfNeeded()
        }
    }

    private func tagCollectionViewCellIsSelectedViewSetting() {
        UIView.animate(withDuration: 0.05) { [weak self] in
            self?.tagCollectionViewConstraint.constant = 0
            self?.resetButtonView.isHidden = false
            self?.view.layoutIfNeeded()
        }
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
        self.filterDetailView.isHidden = false
        self.filterDetailBackgroundView.isHidden = false
        self.recruitmentButton.isHidden = true
        self.manRecruitmentButton.isHidden = true
        self.teamRecruitmentButton.isHidden = true

        self.tabBarController?.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            guard let tabbar = self.tabBarController else { return }
            
            // 상단 150px 딤드 영역 보장
            let topMargin: CGFloat = 150
            let viewHeight = self.filterDetailView.frame.height
            let screenHeight = tabbar.view.frame.height
            let yPosition = topMargin // 상단에서 150px 아래부터 시작
            
            self.filterDetailView.frame = CGRect(x: 0, y: yPosition, width: self.filterDetailView.frame.width, height: viewHeight)
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
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
        self.tableViewFilterButton.setTitle(self.sortMode.sortModeTitle, for: .normal)
        sender.removeFromSuperview()
    }
}

// MARK: - FilterDetailViewDelegate
extension GameMatchingViewController: FilterDetailViewDelegate {

    func finishButtonDidSelected(_ detailView: FilterDetailView, selectedList: [String]) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.filterDetailView.frame = CGRect(x: 0, y: self.view.frame.maxY, width: self.filterDetailView.frame.width, height: self.filterDetailView.frame.height)
            self.tabBarController?.view.layoutIfNeeded()
        } completion: { _ in
            self.filterDetailBackgroundView.isHidden = true
            self.filterDetailView.isHidden = true
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
        guard let filterType = self.didSelectedFilterList.first?.value else {
            return
        }

        switch filterType {
        case .location:
            print("중현: 선택된 location filter \(self.didSelectedFilterList.map { $0.key })")
        case .game:
            print("중현: 선택된 game filter \(self.didSelectedFilterList.map { $0.key })")
        }

        print("중현: 해당 filter 들로 request 요청한다.")

        self.filterTagCollectionView.reloadData()
    }

    func cancelButtonDidSelected(_ detailView: FilterDetailView, selectedList: [String]) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.filterDetailView.frame = CGRect(x: 0, y: 1000, width: self.filterDetailView.frame.width, height: self.filterDetailView.frame.height)
            self.tabBarController?.view.layoutIfNeeded()
        } completion: { _ in
            self.filterDetailBackgroundView.isHidden = true
            self.filterDetailView.isHidden = true
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
