//
//  GameMatchingDetailViewModel.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/15.
//

import Foundation

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

struct UniformInfo {
    let topUniform: [String] // 유니폼 색상 또는 이미지 이름
    let bottomUniform: String
}

class GameMatchingDetailViewModel {
    
    // MARK: - Mock Data
    private let mockData = GameMatchingDetailData(
        date: "2021-06-26 (토) 10:00",
        location: "용산 아이파크몰",
        address: "서울시 용산구 한강대로23길 55",
        feeAmount: "9,000원",
        formatItems: [
            FormatItem(title: "6 vs 6", iconName: ""),
            FormatItem(title: "남성 매치", iconName: ""),
            FormatItem(title: "풋살화", iconName: "")
        ],
        teamName: "모두의 축구",
        ageRange: "20대 후반 - 30대 초반",
        skillLevel: "중하",
        uniformInfo: UniformInfo(
            topUniform: ["uniform_red", "uniform_blue"],
            bottomUniform: "uniform_black"
        ),
        contactNumber: "010-1234-1234",
        noteText: "혼자 또는 친구들 하고 오세요!ㅣㅏㅟㅏㄴㅁ위ㅏㅁㄴ우이ㅏㅁ눙ㅁ니ㅏㅜ미ㅏ우미ㅏ"
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