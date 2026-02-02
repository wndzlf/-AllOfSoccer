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

    // 편의 initializer (기본값 제공)
    init(
        id: String,
        name: String,
        profileImage: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        appleId: String? = nil,
        isActive: Bool? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
        self.profileImage = profileImage
        self.appleId = appleId
        self.isActive = isActive
    }

    // Decodable 명시적 구현
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        appleId = try container.decodeIfPresent(String.self, forKey: .appleId)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
    }

    // Encodable 명시적 구현
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(profileImage, forKey: .profileImage)
        try container.encodeIfPresent(appleId, forKey: .appleId)
        try container.encodeIfPresent(isActive, forKey: .isActive)
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

    // 편의 initializer (기본값 제공)
    init(
        id: String,
        title: String,
        date: String,
        location: String,
        fee: Int,
        maxParticipants: Int,
        currentParticipants: Int,
        matchType: String,
        genderType: String,
        shoesRequirement: String,
        status: String,
        isActive: Bool,
        createdAt: String,
        updatedAt: String,
        description: String? = nil,
        address: String? = nil,
        latitude: String? = nil,
        longitude: String? = nil,
        ageRangeMin: Int? = nil,
        ageRangeMax: Int? = nil,
        skillLevelMin: String? = nil,
        skillLevelMax: String? = nil,
        teamIntroduction: String? = nil,
        mercenaryRecruitmentCount: Int? = nil,
        isOpponentMatched: Bool? = nil,
        hasFormerPlayer: Bool? = nil,
        teamId: String? = nil,
        team: Team? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.location = location
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.fee = fee
        self.maxParticipants = maxParticipants
        self.currentParticipants = currentParticipants
        self.matchType = matchType
        self.genderType = genderType
        self.shoesRequirement = shoesRequirement
        self.ageRangeMin = ageRangeMin
        self.ageRangeMax = ageRangeMax
        self.skillLevelMin = skillLevelMin
        self.skillLevelMax = skillLevelMax
        self.teamIntroduction = teamIntroduction
        self.mercenaryRecruitmentCount = mercenaryRecruitmentCount
        self.isOpponentMatched = isOpponentMatched
        self.hasFormerPlayer = hasFormerPlayer
        self.status = status
        self.isActive = isActive
        self.teamId = teamId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.team = team
    }

    // Decodable 명시적 구현
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        date = try container.decode(String.self, forKey: .date)
        location = try container.decode(String.self, forKey: .location)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
        fee = try container.decode(Int.self, forKey: .fee)
        maxParticipants = try container.decode(Int.self, forKey: .maxParticipants)
        currentParticipants = try container.decode(Int.self, forKey: .currentParticipants)
        matchType = try container.decode(String.self, forKey: .matchType)
        genderType = try container.decode(String.self, forKey: .genderType)
        shoesRequirement = try container.decode(String.self, forKey: .shoesRequirement)
        ageRangeMin = try container.decodeIfPresent(Int.self, forKey: .ageRangeMin)
        ageRangeMax = try container.decodeIfPresent(Int.self, forKey: .ageRangeMax)
        skillLevelMin = try container.decodeIfPresent(String.self, forKey: .skillLevelMin)
        skillLevelMax = try container.decodeIfPresent(String.self, forKey: .skillLevelMax)
        teamIntroduction = try container.decodeIfPresent(String.self, forKey: .teamIntroduction)
        mercenaryRecruitmentCount = try container.decodeIfPresent(Int.self, forKey: .mercenaryRecruitmentCount)
        isOpponentMatched = try container.decodeIfPresent(Bool.self, forKey: .isOpponentMatched)
        hasFormerPlayer = try container.decodeIfPresent(Bool.self, forKey: .hasFormerPlayer)
        status = try container.decode(String.self, forKey: .status)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        teamId = try container.decodeIfPresent(String.self, forKey: .teamId)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        team = try container.decodeIfPresent(Team.self, forKey: .team)
    }

    // Encodable 명시적 구현
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(date, forKey: .date)
        try container.encode(location, forKey: .location)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encode(fee, forKey: .fee)
        try container.encode(maxParticipants, forKey: .maxParticipants)
        try container.encode(currentParticipants, forKey: .currentParticipants)
        try container.encode(matchType, forKey: .matchType)
        try container.encode(genderType, forKey: .genderType)
        try container.encode(shoesRequirement, forKey: .shoesRequirement)
        try container.encodeIfPresent(ageRangeMin, forKey: .ageRangeMin)
        try container.encodeIfPresent(ageRangeMax, forKey: .ageRangeMax)
        try container.encodeIfPresent(skillLevelMin, forKey: .skillLevelMin)
        try container.encodeIfPresent(skillLevelMax, forKey: .skillLevelMax)
        try container.encodeIfPresent(teamIntroduction, forKey: .teamIntroduction)
        try container.encodeIfPresent(mercenaryRecruitmentCount, forKey: .mercenaryRecruitmentCount)
        try container.encodeIfPresent(isOpponentMatched, forKey: .isOpponentMatched)
        try container.encodeIfPresent(hasFormerPlayer, forKey: .hasFormerPlayer)
        try container.encode(status, forKey: .status)
        try container.encode(isActive, forKey: .isActive)
        try container.encodeIfPresent(teamId, forKey: .teamId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(team, forKey: .team)
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

    // 편의 initializer (기본값 제공)
    init(
        id: String,
        name: String,
        logo: String? = nil,
        captain: UserProfile? = nil,
        description: String? = nil,
        captainId: String? = nil,
        ageRangeMin: Int? = nil,
        ageRangeMax: Int? = nil,
        skillLevel: String? = nil,
        introduction: String? = nil,
        isActive: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.logo = logo
        self.captainId = captainId
        self.ageRangeMin = ageRangeMin
        self.ageRangeMax = ageRangeMax
        self.skillLevel = skillLevel
        self.introduction = introduction
        self.isActive = isActive
        self.captain = captain
    }

    // Decodable 명시적 구현
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        logo = try container.decodeIfPresent(String.self, forKey: .logo)
        captainId = try container.decodeIfPresent(String.self, forKey: .captainId)
        ageRangeMin = try container.decodeIfPresent(Int.self, forKey: .ageRangeMin)
        ageRangeMax = try container.decodeIfPresent(Int.self, forKey: .ageRangeMax)
        skillLevel = try container.decodeIfPresent(String.self, forKey: .skillLevel)
        introduction = try container.decodeIfPresent(String.self, forKey: .introduction)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
        captain = try container.decodeIfPresent(UserProfile.self, forKey: .captain)
    }

    // Encodable 명시적 구현
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(logo, forKey: .logo)
        try container.encodeIfPresent(captainId, forKey: .captainId)
        try container.encodeIfPresent(ageRangeMin, forKey: .ageRangeMin)
        try container.encodeIfPresent(ageRangeMax, forKey: .ageRangeMax)
        try container.encodeIfPresent(skillLevel, forKey: .skillLevel)
        try container.encodeIfPresent(introduction, forKey: .introduction)
        try container.encodeIfPresent(isActive, forKey: .isActive)
        try container.encodeIfPresent(captain, forKey: .captain)
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