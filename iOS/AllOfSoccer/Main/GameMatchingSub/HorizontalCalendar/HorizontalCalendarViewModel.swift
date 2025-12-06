//
//  HorizontalCalendarViewModel.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2022/03/13.
//

import UIKit

class HorizonralCalendarViewModel {

    // MARK: - Properties
    private var horizontalCalendarModels: [HorizontalCalendarModel] = []

    internal var formalStrHorizontalCalendarDates: [String] {
        let strHorizontalCalendarDates = self.horizontalCalendarModels.map { self.changeDateToString($0.date) }

        return strHorizontalCalendarDates
    }

    internal var horizontalCount: Int {
        self.horizontalCalendarModels.count
    }

    // MARK: - Function
    internal func append(_ data: HorizontalCalendarModel) {
        self.horizontalCalendarModels.append(data)
    }

    internal func getSelectedDateModel(with indexpath: IndexPath) -> HorizontalCalendarModel {
        return self.horizontalCalendarModels[indexpath.item]
    }

    internal func makeMonthText(indexPath: IndexPath) -> String {
        let newIndexPathItem = makeNewIndexPathItem(indexPath: indexPath)
        let currentDate = self.horizontalCalendarModels[newIndexPathItem].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월"
        let monthString = dateFormatter.string(from: currentDate)
        return monthString
    }

    private func makeNewIndexPathItem(indexPath: IndexPath) -> Int {
        let numberForMakingFirstIndexPath = 6

        var newIndexPathItem = indexPath.item
        if newIndexPathItem >= numberForMakingFirstIndexPath {
            newIndexPathItem = newIndexPathItem - numberForMakingFirstIndexPath
        }
        return newIndexPathItem
    }
}

extension HorizonralCalendarViewModel {
    private func changeDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")

        let changedSelectedDate = dateFormatter.string(from: date)

        return changedSelectedDate
    }
}

internal struct HorizontalCalendarModel {

    internal var date: Date

    internal var weeks: [String] = ["토","일","월","화","수","목","금"]

    internal var weeksDay: Int {
        let calendar = Calendar.current
        let dayOfTheWeekint = calendar.component(.weekday, from: self.date)
        return dayOfTheWeekint
    }

    internal var dayText: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        let chagedDateDay = calendar.dateComponents([.day], from: self.date).day
        if chagedDateDay == 1 {
            dateFormatter.dateFormat = "M/d"
        } else {
            dateFormatter.dateFormat = "d"
        }
        let dateString = dateFormatter.string(from: self.date)
        return dateString
    }

    internal var weeksDayText: String {
        return self.weeks[self.weeksDay % 7]
    }

    // 오늘 날짜인지 확인
    internal var isToday: Bool {
        let calendar = Calendar.current
        let today = Date()
        return calendar.isDate(self.date, inSameDayAs: today)
    }

    // 날짜의 전체 정보 (년-월-일)
    internal var fullDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self.date)
    }

    internal var dayTextColor: UIColor {
        if self.isToday {
            return UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        } else if self.weeksDay % 7 == NumberOfDays.sunday.rawValue {
            // 일요일
            return UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        } else if self.weeksDay % 7 == NumberOfDays.saturday.rawValue {
            // 토요일
            return UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        } else {
            // 평일
            return UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        }
    }

    internal var dateTextColor: UIColor {
        if self.isToday {
            return UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        } else if self.weeksDay % 7 == NumberOfDays.sunday.rawValue {
            // 일요일
            return UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        } else if self.weeksDay % 7 == NumberOfDays.saturday.rawValue {
            // 토요일
            return UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        } else {
            // 평일
            return UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        }
    }
}

extension HorizontalCalendarModel {
    private func changeDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")

        let changedSelectedDate = dateFormatter.string(from: date)

        return changedSelectedDate
    }
}
