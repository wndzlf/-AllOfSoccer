//
//  MercenaryMatchViewModel.swift
//  AllOfSoccer
//
//  Created by Assistant on 2026
//

import Foundation

class MercenaryMatchViewModel: ObservableObject {
    enum DataType {
        case request
        case application
    }

    @Published var mercenaryRequests: [MercenaryRequest] = []
    @Published var mercenaryApplications: [MercenaryApplication] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var currentPage = 1
    private let pageSize = 20

    // MARK: - Data Fetching
    func fetchMercenaryRequests(page: Int = 1, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        APIService.shared.getMercenaryRequests(page: page, limit: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let response):
                    if page == 1 {
                        self?.mercenaryRequests = response.data
                    } else {
                        self?.mercenaryRequests.append(contentsOf: response.data)
                    }
                    self?.currentPage = page
                    completion(true)

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func fetchMercenaryApplications(page: Int = 1, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        APIService.shared.getMercenaryApplications(page: page, limit: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let response):
                    if page == 1 {
                        self?.mercenaryApplications = response.data
                    } else {
                        self?.mercenaryApplications.append(contentsOf: response.data)
                    }
                    self?.currentPage = page
                    completion(true)

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    // MARK: - Data Access
    func getRequestCount() -> Int {
        return mercenaryRequests.count
    }

    func getApplicationCount() -> Int {
        return mercenaryApplications.count
    }

    func getRequest(at index: Int) -> MercenaryRequest? {
        guard index >= 0 && index < mercenaryRequests.count else { return nil }
        return mercenaryRequests[index]
    }

    func getApplication(at index: Int) -> MercenaryApplication? {
        guard index >= 0 && index < mercenaryApplications.count else { return nil }
        return mercenaryApplications[index]
    }

    func loadNextPageOfRequests(completion: @escaping (Bool) -> Void) {
        fetchMercenaryRequests(page: currentPage + 1, completion: completion)
    }

    func loadNextPageOfApplications(completion: @escaping (Bool) -> Void) {
        fetchMercenaryApplications(page: currentPage + 1, completion: completion)
    }

    // MARK: - Formatting
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MM월 dd일 HH:mm"
            displayFormatter.locale = Locale(identifier: "ko_KR")
            return displayFormatter.string(from: date)
        }
        return dateString
    }

    func formatFee(_ fee: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        return (formatter.string(from: NSNumber(value: fee)) ?? "0") + "원"
    }

    func formatPositions(_ positions: [String: Int]) -> String {
        return positions.map { "\($0.key) \($0.value)명" }.joined(separator: ", ")
    }
}

// MARK: - API Response Models
struct MercenaryRequestListResponse: Codable {
    let success: Bool
    let data: [MercenaryRequest]
    let pagination: PaginationInfo
}

struct MercenaryApplicationListResponse: Codable {
    let success: Bool
    let data: [MercenaryApplication]
    let pagination: PaginationInfo
}

struct PaginationInfo: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let total_pages: Int
}

// MARK: - Data Models
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

struct Team: Codable {
    let id: String
    let name: String
    let logo: String?
    let captain: UserProfile?
}

struct UserProfile: Codable {
    let id: String
    let name: String
    let profileImage: String?
    let phone: String?

    enum CodingKeys: String, CodingKey {
        case id, name, phone
        case profileImage = "profile_image"
    }
}
