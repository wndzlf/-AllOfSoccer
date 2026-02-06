//
//  MercenaryMatchViewModel.swift
//  AllOfSoccer
//
//  Created by Assistant on 2026
//

import Foundation

// MARK: - MercenaryFilterType
enum MercenaryFilterType: CaseIterable {
    case location
    case position
    case skillLevel

    var tagTitle: String {
        switch self {
        case .location:
            return "장소"
        case .position:
            return "포지션"
        case .skillLevel:
            return "실력"
        }
    }

    var filterList: [String] {
        switch self {
        case .location:
            return ["서울 노원구", "서울 강남구", "서울 마포구", "서울 종로구", "기타지역"]
        case .position:
            return ["GK", "DF", "MF", "FW"]
        case .skillLevel:
            return ["초급", "중급", "고급", "고수"]
        }
    }
}

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
