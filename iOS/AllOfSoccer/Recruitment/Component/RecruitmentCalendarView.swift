//
//  CalendarView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/04.
//

import UIKit
import FSCalendar

protocol RecruitmentCalendarViewDelegate: AnyObject {
    func cancelButtonDidSelected(_ view: RecruitmentCalendarView)
    func okButtonDidSelected(_ view: RecruitmentCalendarView, selectedDate: String)
}

class RecruitmentCalendarView: UIView {

    weak var delegate: RecruitmentCalendarViewDelegate?

    private var selectedDate: String?
    private var currentPage: Date?

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

        calendar.allowsMultipleSelection = false

        return calendar
    }()

    private var timeDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .automatic
        datePicker.datePickerMode = .time
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.timeZone = .autoupdatingCurrent
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)

        return datePicker
    }()

    private var timeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "시간"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
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
        calendar.delegate = self
        calendar.dataSource = self
        
        // 현재 날짜를 기본 선택으로 설정
        let today = Date()
        calendar.select(today)
        appendDate(date: today)
    }

    private func setViewConstraint() {

        self.addsubviews(self.baseView)
        self.baseView.addsubviews(self.okAndCancelStackView, self.calendar, self.timeTitleLabel, self.timeDatePicker)
        self.calendar.addsubviews(self.monthPrevButton, self.monthNextButton)

        NSLayoutConstraint.activate([

            self.baseView.topAnchor.constraint(equalTo: self.topAnchor, constant: 167),
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -167),

            self.okAndCancelStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 28),
            self.okAndCancelStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -28),
            self.okAndCancelStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -24),
            self.okAndCancelStackView.heightAnchor.constraint(equalToConstant: 40),

            self.timeDatePicker.bottomAnchor.constraint(equalTo: self.okAndCancelStackView.topAnchor, constant: -24),
            self.timeDatePicker.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -28),

            self.timeTitleLabel.centerYAnchor.constraint(equalTo: self.timeDatePicker.centerYAnchor),
            self.timeTitleLabel.trailingAnchor.constraint(equalTo: self.timeDatePicker.leadingAnchor, constant: -30),

            self.calendar.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 20),
            self.calendar.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 28),
            self.calendar.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -28),
            self.calendar.bottomAnchor.constraint(equalTo: self.timeDatePicker.topAnchor, constant: 10),

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
        self.delegate?.cancelButtonDidSelected(self)
    }

    @objc private func okButtonTouchUp(sender: UIButton) {
        guard let selectedDate = self.selectedDate else { return }
        
        // 시간 정보도 포함하여 전달
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: timeDatePicker.date)
        
        let fullDateString = "\(selectedDate) \(timeString)"
        self.delegate?.okButtonDidSelected(self, selectedDate: fullDateString)
    }

    @objc private func monthPrevButtonTouchUp(_ sender: UIButton) {
        moveCurrentPage(moveUp: false)
    }

    @objc private func monthNextButtonTouchUp(_ sender: UIButton) {
        moveCurrentPage(moveUp: true)
    }

    @objc private func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = " hh시 mm분"
        let time = dateFormatter.string(from: sender.date)

        self.selectedDate.map {
            self.selectedDate = $0 + time
        }
    }

    private func moveCurrentPage(moveUp: Bool) {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = moveUp ? 1 : -1

        self.currentPage = calendar.date(byAdding: dateComponents, to: self.currentPage ?? Date())
        guard let currentPage = self.currentPage else { return }
        self.calendar.setCurrentPage(currentPage, animated: true)
    }
}

// MARK: - FSCollectionViewDelegate
extension RecruitmentCalendarView: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        self.appendDate(date: date)
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {

        self.appendDate(date: date)
    }

    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }

    private func appendDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        let stringDate = dateFormatter.string(from: date)
        self.selectedDate = stringDate

        let buttonTitle = "\(stringDate) 선택"
        self.okButton.setTitle(buttonTitle, for: .normal)
    }

//    private func deleteDate(date: Date) {
//        let dateFormatter = DateFormatter()
//        let stringDate = dateFormatter.string(from: date)
//        guard let indexOfStringDate = selectedDate.firstIndex(of: stringDate) else { return }
//        self.selectedDate.remove(at: indexOfStringDate)
//        let countOfSeletedDate = self.selectedDate.count
//        let buttonTitle = self.selectedDate.isEmpty ? "선택" : "선택 (\(countOfSeletedDate)건)"
//        self.okButton.setTitle(buttonTitle, for: .normal)
//    }
}

// MARK: - FSCollectionViewDataSource
extension RecruitmentCalendarView: FSCalendarDataSource {

}
