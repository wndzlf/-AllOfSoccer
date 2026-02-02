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
    
    // 시간 선택을 위한 데이터
    private let hours = Array(0...23)
    private let minutes = [0, 30]
    private var selectedHour = 0
    private var selectedMinute = 0

    private var baseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 12

        return view
    }()

    private var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
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
        
        // 이전/다음 달 날짜 숨기기
        calendar.placeholderType = .none

        return calendar
    }()

    private var timePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = .clear
        return pickerView
    }()

    private var timeTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "시간"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private var monthPrevButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = UIImage(systemName: "arrowtriangle.left.fill")
        button.setImage(buttonImage, for: .normal)
        button.tintColor = UIColor(red: 194.0/255.0, green: 194.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        button.addTarget(self, action: #selector(monthPrevButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private var monthNextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = UIImage(systemName: "arrowtriangle.right.fill")
        button.setImage(buttonImage, for: .normal)
        button.tintColor = UIColor(red: 194.0/255.0, green: 194.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        button.addTarget(self, action: #selector(monthNextButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("선택", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(UIColor.white, for: .normal)
        let backgroundColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = true

        button.addTarget(self, action: #selector(okButtonTouchUp), for: .touchUpInside)

        return button
    }()

    lazy private var okAndCancelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.cancelButton, self.okButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.isUserInteractionEnabled = true

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
        
        // 현재 시간을 30분 단위로 맞춤
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        
        // 분을 30분 단위로 반올림
        if let minute = components.minute {
            if minute < 30 {
                components.minute = 0
            } else {
                components.minute = 30
            }
        }
        
        // 초기 시간 설정
        selectedHour = components.hour ?? 0
        selectedMinute = components.minute ?? 0
        
        // UIPickerView 설정
        timePickerView.delegate = self
        timePickerView.dataSource = self
        
        // 초기 선택 위치 설정
        timePickerView.selectRow(selectedHour, inComponent: 0, animated: false)
        timePickerView.selectRow(selectedMinute == 30 ? 1 : 0, inComponent: 1, animated: false)
    }

    private func setViewConstraint() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.baseView)
        self.baseView.translatesAutoresizingMaskIntoConstraints = false
        self.baseView.addSubview(self.okAndCancelStackView)
        self.baseView.addSubview(self.calendar)
        self.baseView.addSubview(self.timeTitleLabel)
        self.baseView.addSubview(self.timePickerView)
        self.calendar.translatesAutoresizingMaskIntoConstraints = false
        self.calendar.addSubview(self.monthPrevButton)
        self.calendar.addSubview(self.monthNextButton)

        NSLayoutConstraint.activate([

            self.baseView.topAnchor.constraint(equalTo: self.topAnchor, constant: 167),
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -167),

            self.okAndCancelStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 28),
            self.okAndCancelStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -28),
            self.okAndCancelStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -24),
            self.okAndCancelStackView.heightAnchor.constraint(equalToConstant: 40),

            self.timePickerView.bottomAnchor.constraint(equalTo: self.okAndCancelStackView.topAnchor, constant: -24),
            self.timePickerView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -28),
            self.timePickerView.widthAnchor.constraint(equalToConstant: 120),
            self.timePickerView.heightAnchor.constraint(equalToConstant: 100),

            self.timeTitleLabel.centerYAnchor.constraint(equalTo: self.timePickerView.centerYAnchor),
            self.timeTitleLabel.trailingAnchor.constraint(equalTo: self.timePickerView.leadingAnchor, constant: -30),

            self.calendar.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 20),
            self.calendar.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 28),
            self.calendar.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -28),
            self.calendar.bottomAnchor.constraint(equalTo: self.timePickerView.topAnchor, constant: 10),

            self.monthPrevButton.topAnchor.constraint(equalTo: calendar.topAnchor, constant: 5),
            self.monthPrevButton.leadingAnchor.constraint(equalTo: calendar.leadingAnchor, constant: 2),
            self.monthPrevButton.widthAnchor.constraint(equalToConstant: 14),
            self.monthPrevButton.heightAnchor.constraint(equalToConstant: 14),

            self.monthNextButton.topAnchor.constraint(equalTo: calendar.topAnchor, constant: 5),
            self.monthNextButton.trailingAnchor.constraint(equalTo: calendar.trailingAnchor, constant: -2),
            self.monthNextButton.widthAnchor.constraint(equalToConstant: 14),
            self.monthNextButton.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    @objc private func cancelButtonTouchUp(sender: UIButton) {
        self.delegate?.cancelButtonDidSelected(self)
    }

    @objc private func okButtonTouchUp(sender: UIButton) {
        guard let selectedDate = self.selectedDate else { return }
        
        // 선택된 시간을 HH:mm 형식으로 포맷
        let timeString = String(format: "%02d:%02d", selectedHour, selectedMinute)
        
        let fullDateString = "\(selectedDate) \(timeString)"
        self.delegate?.okButtonDidSelected(self, selectedDate: fullDateString)
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
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let stringDate = dateFormatter.string(from: date)
        self.selectedDate = stringDate

        // 버튼에는 년도 없이 표시
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MM월 dd일"
        let displayDate = displayFormatter.string(from: date)
        let buttonTitle = "\(displayDate) 선택"
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

// MARK: - UIPickerViewDelegate & DataSource
extension RecruitmentCalendarView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // 시간, 분
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: // 시간
            return hours.count
        case 1: // 분
            return minutes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 16)
        ]
        
        switch component {
        case 0: // 시간
            return NSAttributedString(string: "\(hours[row])", attributes: attributes)
        case 1: // 분
            return NSAttributedString(string: "\(minutes[row])", attributes: attributes)
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: // 시간
            selectedHour = hours[row]
        case 1: // 분
            selectedMinute = minutes[row]
        default:
            break
        }
    }
}
