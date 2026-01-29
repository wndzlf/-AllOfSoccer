//
//  MatchModels.swift
//  AllOfSoccer
//
//  Created by Assistant on 2024/01/01.
//

import Foundation

// MARK: - Apple Sign-In Response
struct AppleSignInResponse: Codable {
    let success: Bool
    let data: AppleSignInData?
    let message: String?
}

struct AppleSignInData: Codable {
    let user: UserProfile
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct UserProfile: Codable {
    let id: String
    let email: String?
    let name: String
    let phone: String?
    let profileImage: String?
    let appleId: String?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id, email, name, phone
        case profileImage = "profile_image"
        case appleId = "apple_id"
        case isActive = "is_active"
    }
}

// MARK: - Profile Response
struct ProfileResponse: Codable {
    let success: Bool
    let data: UserProfile?
    let message: String?
}

// MARK: - Match List Response
struct MatchListResponse: Codable {
    let success: Bool
    let data: [Match]
    let pagination: Pagination
    let message: String?
}

// MARK: - Match
struct Match: Codable {
    let id: String
    let title: String
    let description: String?
    let date: String
    let location: String
    let address: String?
    let latitude: String?
    let longitude: String?
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
    let teamId: String?
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
        case teamId = "team_id"
        case createdAt, updatedAt
        case team = "Team"
    }
}

// MARK: - Team
struct Team: Codable {
    let id: String
    let name: String
    let description: String?
    let logo: String?
    let captainId: String?
    let ageRangeMin: Int?
    let ageRangeMax: Int?
    let skillLevel: String?
    let introduction: String?
    let isActive: Bool?
    let captain: UserProfile?

    enum CodingKeys: String, CodingKey {
        case id, name, description, logo, introduction, captain
        case captainId = "captain_id"
        case ageRangeMin = "age_range_min"
        case ageRangeMax = "age_range_max"
        case skillLevel = "skill_level"
        case isActive = "is_active"
    }

    // Mock 데이터용 간편 이니셜라이저
    init(id: String, name: String, logo: String?, captain: UserProfile?) {
        self.id = id
        self.name = name
        self.description = nil
        self.logo = logo
        self.captainId = nil
        self.ageRangeMin = nil
        self.ageRangeMax = nil
        self.skillLevel = nil
        self.introduction = nil
        self.isActive = nil
        self.captain = captain
    }
}

// MARK: - User (간단한 사용자 정보)
struct User: Codable {
    let id: String
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