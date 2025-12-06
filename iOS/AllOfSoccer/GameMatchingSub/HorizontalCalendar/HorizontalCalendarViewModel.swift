//
//  HorizontalCalendarViewModel.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2022/03/13.
//

import Foundation

class HorizonralCalendarViewModel {

    // MARK: - Properties
    internal private(set) var horizontalCalendarModels: [HorizontalCalendarModel] = []

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
