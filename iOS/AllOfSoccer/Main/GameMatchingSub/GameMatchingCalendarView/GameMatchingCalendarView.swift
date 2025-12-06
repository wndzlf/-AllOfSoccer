//
//  CalendarView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/04.
//

import UIKit
import FSCalendar

protocol GameMatchingCalendarViewDelegate: AnyObject {
    func cancelButtonDidSelected(sender: GameMatchingCalendarView)
    func okButtonDidSelected(sender: GameMatchingCalendarView, selectedDates: [Date])
}

class GameMatchingCalendarView: UIView {

    weak var delegate: GameMatchingCalendarViewDelegate?

    private var gameMatchingCalendarViewModel = GameMatchingCalendarViewModel()
    private var currentPage: Date?
    private var selectedDate: [Date] = []

    private var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 12

        return view
    }()

    private var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.appearance.titleWeekendColor = UIColor.red
        calendar.appearance.selectionColor = UIColor.black
        calendar.appearance.todayColor = nil
        calendar.appearance.titleTodayColor = nil

        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "M월"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20, weight: .bold)

        calendar.locale = Locale(identifier: "ko-KR")
        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"

        calendar.allowsMultipleSelection = true

        return calendar
    }()

    private var monthPrevButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(systemName: "arrowtriangle.left.fill")
        button.setImage(buttonImage, for: .normal)
        button.tintColor = UIColor(red: 194.0/255.0, green: 194.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        button.addTarget(self, action: #selector(monthPrevButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private var monthNextButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(systemName: "arrowtriangle.right.fill")
        button.setImage(buttonImage, for: .normal)
        button.tintColor = UIColor(red: 194.0/255.0, green: 194.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        button.addTarget(self, action: #selector(monthNextButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(UIColor.black, for: .normal)
        let backgroundColor = UIColor(red: 246/255, green: 247/255, blue: 250/255, alpha: 1)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true

        button.addTarget(self, action: #selector(cancelButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private var okButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("선택", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(UIColor.white, for: .normal)
        let backgroundColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true

        button.addTarget(self, action: #selector(okButtonTouchUp), for: .touchUpInside)

        return button
    }()

    lazy private var okAndCancelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.cancelButton, self.okButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually

        return stackView
    }()

    init(selectedDates: [Date], delegate: GameMatchingCalendarViewDelegate) {

        self.gameMatchingCalendarViewModel.append(dates: selectedDates, date: nil)
        self.delegate = delegate

        super.init(frame: .zero)

        loadView()
        setOKButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setOKButton()
    }

    static func make(selectedDates: [Date], delegate: GameMatchingCalendarViewDelegate) -> GameMatchingCalendarView {
        return GameMatchingCalendarView(selectedDates: selectedDates, delegate: delegate)
    }

    private func loadView() {

        setSuperView()
        setCalendar()
        setViewConstraint()
    }

    private func setSuperView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }

    private func setCalendar() {

        self.calendar.delegate = self
        self.calendar.dataSource = self

        self.calendar.register(GameMatchingCalendarCell.self, forCellReuseIdentifier: GameMatchingCalendarCell.reuseId)
    }

    private func setOKButton() {

        let countOfSeletedDate = self.gameMatchingCalendarViewModel.selectedDate.count

        let buttonTitle = countOfSeletedDate <= 0 ? "선택" : "선택 (\(countOfSeletedDate)건)"
        self.okButton.setTitle(buttonTitle, for: .normal)
    }

    private func setViewConstraint() {

        self.addsubviews(self.baseView)
        self.baseView.addsubviews(self.okAndCancelStackView, self.calendar)
        self.calendar.addsubviews(self.monthPrevButton, self.monthNextButton)

        NSLayoutConstraint.activate([

            self.baseView.widthAnchor.constraint(equalToConstant: 336),
            self.baseView.heightAnchor.constraint(equalToConstant: 432),
            self.baseView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.baseView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            self.okAndCancelStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),
            self.okAndCancelStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -32),
            self.okAndCancelStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -24),
            self.okAndCancelStackView.heightAnchor.constraint(equalToConstant: 40),

            self.calendar.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 20),
            self.calendar.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 22),
            self.calendar.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -22),
            self.calendar.bottomAnchor.constraint(equalTo: self.okAndCancelStackView.topAnchor, constant: 0),

            self.monthPrevButton.topAnchor.constraint(equalTo: calendar.topAnchor, constant: 5),
            self.monthPrevButton.leadingAnchor.constraint(equalTo: calendar.leadingAnchor, constant: 2),
            self.monthPrevButton.widthAnchor.constraint(equalToConstant: 14),
            self.monthPrevButton.widthAnchor.constraint(equalToConstant: 14),

            self.monthNextButton.topAnchor.constraint(equalTo: calendar.topAnchor, constant: 5),
            self.monthNextButton.trailingAnchor.constraint(equalTo: calendar.trailingAnchor, constant: -2),
            self.monthNextButton.widthAnchor.constraint(equalToConstant: 14),
            self.monthNextButton.widthAnchor.constraint(equalToConstant: 14)
        ])
    }

    @objc private func cancelButtonTouchUp(sender: UIButton) {
        self.delegate?.cancelButtonDidSelected(sender: self)
    }

    @objc private func okButtonTouchUp(sender: UIButton) {
        self.delegate?.okButtonDidSelected(sender: self, selectedDates: self.gameMatchingCalendarViewModel.selectedDate)
    }

    @objc private func monthPrevButtonTouchUp(_ sender: UIButton) {
        moveCurrentPage(moveUp: false)
    }

    @objc private func monthNextButtonTouchUp(_ sender: UIButton) {
        moveCurrentPage(moveUp: true)
    }

    private func moveCurrentPage(moveUp: Bool) {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = moveUp ? 1 : -1

        self.currentPage = calendar.date(byAdding: dateComponents, to: self.currentPage ?? Date())
        guard let currentPage = self.currentPage else { return }
        self.calendar.setCurrentPage(currentPage, animated: true)
    }

    deinit {
        print("클래스가 deinit이 되었습니다.")
    }
}

// MARK: - FSCollectionViewDelegate
extension GameMatchingCalendarView: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        self.gameMatchingCalendarViewModel.append(dates: [], date: date)
        self.setOKButton()
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {

        self.gameMatchingCalendarViewModel.delete(date: date)
        self.setOKButton()
    }

    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
     }
}

// MARK: - FSCollectionViewDataSource
extension GameMatchingCalendarView: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {

        guard let cell = calendar.dequeueReusableCell(withIdentifier: "GameMatchingCalendarCell", for: date, at: position) as? GameMatchingCalendarCell else { return .init() }

        let selectedDate = gameMatchingCalendarViewModel.formalStrSelectedDate
        let calendarDate = self.changeDateFormat(date)

        if selectedDate.contains(calendarDate) {
            calendar.select(date)
        }

        return cell
    }
}

extension GameMatchingCalendarView {
    private func changeDateFormat(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")

        let changedSelectedDate = dateFormatter.string(from: date)

        return changedSelectedDate
    }
}

