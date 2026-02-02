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

    // Mock 데이터용 간편 이니셜라이저
    init(id: String, name: String, profileImage: String?, appleId: String? = nil, isActive: Bool? = nil) {
        self.id = id
        self.email = nil
        self.name = name
        self.phone = nil
        self.profileImage = profileImage
        self.appleId = appleId
        self.isActive = isActive
    }

    // 전체 파라미터 이니셜라이저 (Codable 자동 생성 대체)
    init(id: String, email: String?, name: String, phone: String?, profileImage: String?, appleId: String?, isActive: Bool?) {
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
        self.profileImage = profileImage
        self.appleId = appleId
        self.isActive = isActive
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
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case team
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

// MARK: - Match Creation
struct MatchCreationData {
    // FirstTeamRecruitmentViewController에서 수집
    let date: Date
    let location: String
    let address: String?
    let latitude: String?
    let longitude: String?
    let matchType: String // "6v6" or "11v11"
    let genderType: String // "male", "female", "mixed"
    let shoesRequirement: String // "cleats", "indoor", "any"
    let hasFormerPlayer: Bool
    let fee: Int

    // SecondTeamRecruitmentViewController에서 수집
    var teamName: String?
    var ageRangeMin: Int?
    var ageRangeMax: Int?
    var skillLevelMin: String?
    var skillLevelMax: String?
    var teamIntroduction: String?
    var contactInfo: String?
}

struct CreateMatchResponse: Codable {
    let success: Bool
    let data: Match?
    let message: String?
}

// MARK: - Match Detail
struct MatchDetailResponse: Codable {
    let success: Bool
    let data: MatchDetail?
    let message: String?
}

struct MatchDetail: Codable {
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
    let mercenaryRecruitmentCount: Int?
    let isOpponentMatched: Bool?
    let hasFormerPlayer: Bool?
    let status: String
    let isActive: Bool
    let teamId: String?
    let createdAt: String
    let updatedAt: String
    let team: Team?
    let matchParticipants: [MatchParticipant]?
    let comments: [MatchComment]?

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
        case matchParticipants = "MatchParticipants"
        case comments = "Comments"
    }
}

struct MatchParticipant: Codable {
    let id: String
    let matchId: String
    let userId: String
    let teamId: String?
    let status: String
    let createdAt: String
    let updatedAt: String
    let user: UserProfile?
    let team: Team?

    enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case userId = "user_id"
        case teamId = "team_id"
        case status, createdAt, updatedAt
        case user = "User"
        case team = "Team"
    }
}

struct MatchComment: Codable {
    let id: String
    let content: String
    let userId: String
    let teamId: String?
    let type: String
    let orderIndex: Int?
    let createdAt: String
    let updatedAt: String
    let user: UserProfile?

    enum CodingKeys: String, CodingKey {
        case id, content, type, createdAt, updatedAt
        case userId = "user_id"
        case teamId = "team_id"
        case orderIndex = "order_index"
        case user = "User"
    }
}

// MARK: - Match Participation
struct ApplyMatchResponse: Codable {
    let success: Bool
    let data: MatchParticipant?
    let message: String?
}

struct CancelMatchResponse: Codable {
    let success: Bool
    let message: String?
}

// MARK: - Mercenary Request Models
struct MercenaryRequestListResponse: Codable {
    let success: Bool
    let data: [MercenaryRequest]
    let pagination: PaginationInfo
}

struct MercenaryRequestResponse: Codable {
    let success: Bool
    let data: MercenaryRequest
    let message: String?
}

struct MercenaryRequest: Codable, Identifiable {
    let id: String
    let teamId: String?
    let title: String
    let description: String?
    let date: String
    let location: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let fee: Int
    let mercenaryCount: Int
    let positionsNeeded: [String: Int]
    let skillLevelMin: String?
    let skillLevelMax: String?
    let currentApplicants: Int
    let status: String
    let team: Team?

    enum CodingKeys: String, CodingKey {
        case id, title, description, date, location, address, fee, status, team
        case teamId = "team_id"
        case latitude, longitude
        case mercenaryCount = "mercenary_count"
        case positionsNeeded = "positions_needed"
        case skillLevelMin = "skill_level_min"
        case skillLevelMax = "skill_level_max"
        case currentApplicants = "current_applicants"
    }
}

// MARK: - Mercenary Application Models
struct MercenaryApplicationListResponse: Codable {
    let success: Bool
    let data: [MercenaryApplication]
    let pagination: PaginationInfo
}

struct MercenaryApplicationResponse: Codable {
    let success: Bool
    let data: MercenaryApplication
    let message: String?
}

struct MercenaryApplication: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let description: String?
    let availableDates: [String]
    let preferredLocations: [String]
    let positions: [String]
    let skillLevel: String
    let preferredFeeMin: Int?
    let preferredFeeMax: Int?
    let status: String
    let user: UserProfile?

    enum CodingKeys: String, CodingKey {
        case id, title, description, positions, status, user
        case userId = "user_id"
        case availableDates = "available_dates"
        case preferredLocations = "preferred_locations"
        case skillLevel = "skill_level"
        case preferredFeeMin = "preferred_fee_min"
        case preferredFeeMax = "preferred_fee_max"
    }
}

// MARK: - Pagination Info
struct PaginationInfo: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let total_pages: Int
}