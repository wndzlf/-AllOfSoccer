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
    
    // MARK: - Properties
    private var match: Match?
    
    // MARK: - Public Properties
    var data: GameMatchingDetailData {
        return convertMatchToDetailData(match)
    }
    
    // MARK: - Initialization
    init(match: Match? = nil) {
        self.match = match
    }
    
    // MARK: - Data Management
    func setMatch(_ match: Match) {
        self.match = match
    }
    
    func getMatch() -> Match? {
        return match
    }
    
    // MARK: - Data Conversion
    private func convertMatchToDetailData(_ match: Match?) -> GameMatchingDetailData {
        guard let match = match else {
            // 기본값 반환
            return GameMatchingDetailData(
                date: "날짜 정보 없음",
                location: "장소 정보 없음",
                address: "주소 정보 없음",
                feeAmount: "0원",
                formatItems: [
                    FormatItem(title: "정보 없음", iconName: "questionmark.circle")
                ],
                teamName: "팀 정보 없음",
                ageRange: "나이대 정보 없음",
                skillLevel: "실력 정보 없음",
                uniformInfo: UniformInfo(topUniform: []),
                contactNumber: "연락처 정보 없음",
                noteText: "상세 정보가 없습니다."
            )
        }
        
        // 날짜 형식 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: match.date) ?? Date()
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy-MM-dd (E) HH:mm"
        displayFormatter.locale = Locale(identifier: "ko_KR")
        let displayDate = displayFormatter.string(from: date)
        
        // 참가비 형식 변환
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let feeAmount = numberFormatter.string(from: NSNumber(value: match.fee)) ?? "0"
        
        // 경기 형식 아이템 생성
        let formatItems = createFormatItems(from: match)
        
        // 나이대 정보
        let ageRange = createAgeRange(min: match.ageRangeMin, max: match.ageRangeMax)
        
        // 실력 정보
        let skillLevel = createSkillLevel(min: match.skillLevelMin, max: match.skillLevelMax)
        
        // 유니폼 정보 (기본값)
        let uniformInfo = UniformInfo(topUniform: [
            UniformItem(iconName: "tshirt.fill", color: UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0))
        ])
        
        // 연락처 정보 (팀 캡틴 정보에서 추출)
        let contactNumber = match.team?.captain?.name != nil ? "010-1234-5678" : "연락처 정보 없음"
        
        return GameMatchingDetailData(
            date: displayDate,
            location: match.location,
            address: match.address ?? "주소 정보 없음",
            feeAmount: "\(feeAmount)원",
            formatItems: formatItems,
            teamName: match.team?.name ?? "팀 정보 없음",
            ageRange: ageRange,
            skillLevel: skillLevel,
            uniformInfo: uniformInfo,
            contactNumber: contactNumber,
            noteText: match.teamIntroduction ?? "상세 정보가 없습니다."
        )
    }
    
    private func createFormatItems(from match: Match) -> [FormatItem] {
        var items: [FormatItem] = []
        
        // 경기 형식
        let matchTypeTitle = match.matchType == "11v11" ? "11 vs 11" : "6 vs 6"
        items.append(FormatItem(title: matchTypeTitle, iconName: "person.3.fill"))
        
        // 성별
        let genderTitle: String
        switch match.genderType {
        case "male": genderTitle = "남성 매치"
        case "female": genderTitle = "여성 매치"
        case "mixed": genderTitle = "혼성 매치"
        default: genderTitle = "성별 제한 없음"
        }
        items.append(FormatItem(title: genderTitle, iconName: "person.fill"))
        
        // 신발 요구사항
        let shoesTitle: String
        switch match.shoesRequirement {
        case "cleats": shoesTitle = "축구화"
        case "indoor": shoesTitle = "실내화"
        case "any": shoesTitle = "신발 제한 없음"
        default: shoesTitle = "신발 제한 없음"
        }
        items.append(FormatItem(title: shoesTitle, iconName: "figure.soccer"))
        
        return items
    }
    
    private func createAgeRange(min: Int?, max: Int?) -> String {
        if let min = min, let max = max {
            return "\(min)대 - \(max)대"
        } else if let min = min {
            return "\(min)대 이상"
        } else if let max = max {
            return "\(max)대 이하"
        } else {
            return "나이 제한 없음"
        }
    }
    
    private func createSkillLevel(min: String?, max: String?) -> String {
        let skillLevels = ["beginner": "초급", "intermediate": "중급", "advanced": "고급", "expert": "전문가"]
        
        if let min = min, let max = max {
            let minDisplay = skillLevels[min] ?? min
            let maxDisplay = skillLevels[max] ?? max
            return "\(minDisplay) - \(maxDisplay)"
        } else if let min = min {
            let minDisplay = skillLevels[min] ?? min
            return "\(minDisplay) 이상"
        } else if let max = max {
            let maxDisplay = skillLevels[max] ?? max
            return "\(maxDisplay) 이하"
        } else {
            return "실력 제한 없음"
        }
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
