//
//  Date+Extension.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2022/03/13.
//

import Foundation

extension Date {
    internal var changedSringFromDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")

        let changedSelectedDate = dateFormatter.string(from: self)

        return changedSelectedDate
    }
}
