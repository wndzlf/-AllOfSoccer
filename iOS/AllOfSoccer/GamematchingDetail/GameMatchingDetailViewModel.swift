//
//  GameMatchingDetailViewModel.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/15.
//

import UIKit

struct GameMatchingDetailData {
    // MARK: - Date and Location
    let date: String
    let location: String
    let address: String
    
    // MARK: - Fee
    let feeAmount: String
    
    // MARK: - Game Format
    let formatItems: [FormatItem]
    
    // MARK: - Team Info
    let teamName: String
    let ageRange: String
    let skillLevel: String
    let uniformInfo: UniformInfo
    let contactNumber: String
    
    // MARK: - Note
    let noteText: String
}

struct FormatItem {
    let title: String
    let iconName: String
}

struct UniformItem {
    let iconName: String
    let color: UIColor
}

struct UniformInfo {
    let topUniform: [UniformItem] // 상의 유니폼 정보
}

class GameMatchingDetailViewModel {
    
    // MARK: - Mock Data
    private let mockData = GameMatchingDetailData(
        date: "2021-06-26 (토) 10:00",
        location: "용산 아이파크몰",
        address: "서울시 용산구 한강대로23길 55",
        feeAmount: "9,000원",
        formatItems: [
            FormatItem(title: "6 vs 6", iconName: "person.2.fill"),
            FormatItem(title: "남성 매치", iconName: "person.fill"),
            FormatItem(title: "풋살화", iconName: "figure.soccer"),
        ],
        teamName: "FC 토토",
        ageRange: "20대 후반 - 30대 초반",
        skillLevel: "하하하",
        uniformInfo: UniformInfo(
            topUniform: [
                UniformItem(iconName: "tshirt.fill", color: UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)), 
            ]
        ),
        contactNumber: "010-1234-1234",
        noteText: "안녕하세요 FC 토토입니다. 잘부탁드립니다. 실력 최하하 매너 최상상 팁입니다!!!! "
    )
    
    // MARK: - Public Properties
    var data: GameMatchingDetailData {
        return mockData
    }
    
    // MARK: - Share Data
    private var shareItems: [String] = []
    
    func addShareItem(_ item: String) {
        shareItems.append(item)
    }
    
    func getShareItems() -> [String] {
        return shareItems
    }
    
    func clearShareItems() {
        shareItems.removeAll()
    }
} 
