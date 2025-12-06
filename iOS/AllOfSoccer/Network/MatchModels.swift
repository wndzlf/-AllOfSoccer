//
//  MatchModels.swift
//  AllOfSoccer
//
//  Created by Assistant on 2024/01/01.
//

import Foundation

// MARK: - Match List Response
struct MatchListResponse: Codable {
    let success: Bool
    let data: [Match]
    let pagination: Pagination
    let message: String?
}

// MARK: - Match
struct Match: Codable {
    let id: Int
    let title: String
    let description: String?
    let date: String
    let location: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let fee: Int
    let maxParticipants: Int
    let currentParticipants: Int
    let matchType: String
    let genderType: String
    let shoesRequirement: String
    let ageRangeMin: Int?
    let ageRangeMax: Int?
    let skillLevelMin: String?
    let skillLevelMax: String?
    let teamIntroduction: String?
    let mercenaryRecruitmentCount: Int? // 용병 모집 수
    let isOpponentMatched: Bool? // 상대팀 매칭 여부
    let hasFormerPlayer: Bool? // 선출 유무
    let status: String
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    let team: Team?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, date, location, address, latitude, longitude, fee
        case maxParticipants = "max_participants"
        case currentParticipants = "current_participants"
        case matchType = "match_type"
        case genderType = "gender_type"
        case shoesRequirement = "shoes_requirement"
        case ageRangeMin = "age_range_min"
        case ageRangeMax = "age_range_max"
        case skillLevelMin = "skill_level_min"
        case skillLevelMax = "skill_level_max"
        case teamIntroduction = "team_introduction"
        case mercenaryRecruitmentCount = "mercenary_recruitment_count"
        case isOpponentMatched = "is_opponent_matched"
        case hasFormerPlayer = "has_former_player"
        case status, isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case team
    }
}

// MARK: - Team
struct Team: Codable {
    let id: Int
    let name: String
    let logo: String?
    let captain: User?
}

// MARK: - User
struct User: Codable {
    let id: Int
    let name: String
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case profileImage = "profile_image"
    }
}

// MARK: - Pagination
struct Pagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case page, limit, total
        case totalPages = "total_pages"
    }
}

// MARK: - Match Filter Options
enum MatchType: String, CaseIterable {
    case sixVsSix = "6v6"
    case elevenVsEleven = "11v11"
    
    var displayName: String {
        switch self {
        case .sixVsSix: return "6vs6"
        case .elevenVsEleven: return "11vs11"
        }
    }
}

enum GenderType: String, CaseIterable {
    case mixed = "mixed"
    case male = "male"
    case female = "female"
    
    var displayName: String {
        switch self {
        case .mixed: return "혼성"
        case .male: return "남성"
        case .female: return "여성"
        }
    }
}

enum ShoesRequirement: String, CaseIterable {
    case any = "any"
    case cleats = "cleats"
    case indoor = "indoor"
    
    var displayName: String {
        switch self {
        case .any: return "상관없음"
        case .cleats: return "축구화"
        case .indoor: return "실내화"
        }
    }
}

enum SkillLevel: String, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    var displayName: String {
        switch self {
        case .beginner: return "초급"
        case .intermediate: return "중급"
        case .advanced: return "고급"
        case .expert: return "전문가"
        }
    }
}

enum MatchStatus: String, CaseIterable {
    case recruiting = "recruiting"
    case confirmed = "confirmed"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .recruiting: return "모집중"
        case .confirmed: return "확정"
        case .completed: return "완료"
        case .cancelled: return "취소"
        }
    }
} 