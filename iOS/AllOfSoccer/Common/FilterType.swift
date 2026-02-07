//
//  FilterType.swift
//  AllOfSoccer
//
//  Created by Claude on 2026
//

import Foundation

enum FilterType: CaseIterable {
    case location
    case game
    case status

    var tagTitle: String {
        switch self {
        case .location: return "장소"
        case .game: return "경기 종류"
        case .status: return "매칭 여부"
        }
    }

    var filterList: [String] {
        switch self {
        case .location: return [
            "서울북부",
            "서울남부",
            "경기북부",
            "경기남부",
            "인천/부천",
            "기타지역"
        ]
        case .game: return ["11 vs 11", "풋살"]
        case .status: return ["매칭 완료", "매칭 중"]
        }
    }
}
