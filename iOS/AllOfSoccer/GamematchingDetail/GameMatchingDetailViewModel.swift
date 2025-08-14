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
    private let mockDataArray = [
        GameMatchingDetailData(
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
        ),
        GameMatchingDetailData(
            date: "2021-06-27 (일) 14:00",
            location: "양원역 구장",
            address: "서울시 강북구 양원역로 123 양원역 근처 풋살장",
            feeAmount: "7,000원",
            formatItems: [
                FormatItem(title: "11 vs 11", iconName: "person.3.fill"),
                FormatItem(title: "혼성 매치", iconName: "person.2.circle.fill"),
                FormatItem(title: "축구화", iconName: "figure.soccer"),
            ],
            teamName: "FC 캘란",
            ageRange: "20대 초반 - 40대 중반",
            skillLevel: "중상",
            uniformInfo: UniformInfo(
                topUniform: [
                    UniformItem(iconName: "tshirt.fill", color: UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0)),
                    UniformItem(iconName: "tshirt.fill", color: UIColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 1.0)),
                ]
            ),
            contactNumber: "010-9876-5432",
            noteText: "안녕하세요! FC 캘란입니다. 저희는 매주 일요일 오후에 경기를 하고 있습니다. 실력은 중상 정도이고, 매너 좋은 분들과 함께 즐겁게 축구하고 싶습니다. 초보자도 환영하니 부담 없이 연락주세요! 특히 이번 주는 새로운 멤버들이 많이 와서 더욱 즐거운 경기가 될 것 같습니다. 구장비는 7천원이고, 경기 후 간단한 회식도 있을 예정입니다. 많은 참여 부탁드립니다!"
        ),
        GameMatchingDetailData(
            date: "2021-06-28 (월) 20:00",
            location: "태릉중학교",
            address: "서울시 노원구 태릉로 456 태릉중학교 운동장",
            feeAmount: "50,000원",
            formatItems: [
                FormatItem(title: "11 vs 11", iconName: "person.3.fill"),
                FormatItem(title: "남성 매치", iconName: "person.fill"),
                FormatItem(title: "축구화", iconName: "figure.soccer"),
            ],
            teamName: "FC 바르셀로나",
            ageRange: "30대 후반 - 50대 초반",
            skillLevel: "상",
            uniformInfo: UniformInfo(
                topUniform: [
                    UniformItem(iconName: "tshirt.fill", color: UIColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1.0)),
                ]
            ),
            contactNumber: "010-5555-7777",
            noteText: "FC 바르셀로나입니다. 저희는 실력 있는 분들과 함께하는 경기를 선호합니다. 이번 경기는 특별히 구장비가 5만원으로 비싸지만, 최고급 인조잔디 구장에서 진행됩니다. 경기 후에는 근처 맛집에서 회식도 예정되어 있습니다. 실력이 상급이신 분들만 연락주시고, 경기 중 매너도 중요하게 생각합니다. 특히 이번 경기는 다른 팀과의 친선경기이므로 더욱 신중하게 선수들을 모집하고 있습니다. 많은 관심 부탁드립니다!"
        )
    ]
    
    // MARK: - Public Properties
    var data: GameMatchingDetailData {
        return mockDataArray[0] // 기본값으로 첫 번째 데이터 반환
    }
    
    // MARK: - Data Management
    private var currentDataIndex: Int = 0
    
    func getData(at index: Int) -> GameMatchingDetailData? {
        guard index >= 0 && index < mockDataArray.count else { return nil }
        return mockDataArray[index]
    }
    
    func setCurrentDataIndex(_ index: Int) {
        guard index >= 0 && index < mockDataArray.count else { return }
        currentDataIndex = index
    }
    
    var currentData: GameMatchingDetailData {
        return mockDataArray[currentDataIndex]
    }
    
    var dataCount: Int {
        return mockDataArray.count
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
