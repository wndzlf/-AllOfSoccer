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

    struct RequestFilters: Equatable {
        let location: String?
        let position: String?
        let skillLevel: String?
        let matchType: String?
        let status: String?
    }

    @Published var mercenaryRequests: [MercenaryRequest] = []
    @Published var mercenaryApplications: [MercenaryApplication] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMoreRequestPages = true
    @Published var hasMoreApplicationPages = true

    private var currentRequestPage = 1
    private var currentApplicationPage = 1
    private var lastRequestFilters = RequestFilters(
        location: nil,
        position: nil,
        skillLevel: nil,
        matchType: nil,
        status: nil
    )
    private let pageSize = 20
    private let displayLocale = Locale(identifier: "ko_KR")
    private let displayTimeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
    private static let regionRules: [(canonical: String, display: String, keywords: [String])] = [
        ("서울북부", "서울 북부", ["노원", "도봉", "강북", "성북", "중랑", "동대문", "광진", "종로", "은평", "서대문", "마포"]),
        ("서울남부", "서울 남부", ["강남", "서초", "송파", "강동", "강서", "양천", "영등포", "구로", "금천", "동작", "관악", "용산"]),
        ("경기북부", "경기 북부", ["고양", "파주", "의정부", "양주", "동두천", "연천", "포천", "가평", "남양주", "구리"]),
        ("경기남부", "경기 남부", ["성남", "수원", "용인", "화성", "평택", "안산", "안양", "과천", "군포", "의왕", "시흥", "광명", "오산", "이천", "안성", "하남", "광주"]),
        ("인천부천", "인천/부천", ["인천", "부천", "송도", "계양", "부평", "남동", "연수", "미추홀"]),
        ("기타지역", "기타지역", [])
    ]

    var activeRequestFilters: RequestFilters {
        return lastRequestFilters
    }

    // MARK: - Data Fetching
    func fetchMercenaryRequests(
        page: Int = 1,
        location: String? = nil,
        position: String? = nil,
        skillLevel: String? = nil,
        matchType: String? = nil,
        status: String? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        guard !isLoading else {
            completion(false)
            return
        }

        let filters = RequestFilters(
            location: location,
            position: position,
            skillLevel: skillLevel,
            matchType: matchType,
            status: status
        )

        if page == 1 {
            currentRequestPage = 1
            hasMoreRequestPages = true
        }

        lastRequestFilters = filters
        isLoading = true
        errorMessage = nil

        APIService.shared.getMercenaryRequests(
            page: page,
            limit: pageSize,
            location: location,
            matchType: matchType,
            skillLevel: skillLevel,
            status: status
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let response):
                    if page == 1 {
                        self?.mercenaryRequests = response.data
                    } else {
                        self?.mercenaryRequests.append(contentsOf: response.data)
                    }
                    self?.currentRequestPage = page
                    self?.hasMoreRequestPages = page < response.pagination.total_pages
                    completion(true)

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func fetchMercenaryApplications(page: Int = 1, completion: @escaping (Bool) -> Void) {
        guard !isLoading else {
            completion(false)
            return
        }

        if page == 1 {
            currentApplicationPage = 1
            hasMoreApplicationPages = true
        }

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
                    self?.currentApplicationPage = page
                    self?.hasMoreApplicationPages = page < response.pagination.total_pages
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

    func loadNextPageOfRequests(
        location: String? = nil,
        position: String? = nil,
        skillLevel: String? = nil,
        matchType: String? = nil,
        status: String? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        guard !isLoading && hasMoreRequestPages else {
            completion(false)
            return
        }

        fetchMercenaryRequests(
            page: currentRequestPage + 1,
            location: location,
            position: position,
            skillLevel: skillLevel,
            matchType: matchType,
            status: status,
            completion: completion
        )
    }

    func loadNextPageOfApplications(completion: @escaping (Bool) -> Void) {
        guard !isLoading && hasMoreApplicationPages else {
            completion(false)
            return
        }

        fetchMercenaryApplications(page: currentApplicationPage + 1, completion: completion)
    }

    // MARK: - Formatting
    func formatDate(_ dateString: String) -> String {
        let parts = formatDateTimeComponents(dateString)
        return parts.time.isEmpty ? parts.date : "\(parts.date) \(parts.time)"
    }

    func formatDateTimeComponents(_ dateString: String) -> (date: String, time: String) {
        guard let date = parseDate(dateString) else {
            return (dateString, "")
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = displayLocale
        dateFormatter.timeZone = displayTimeZone
        dateFormatter.dateFormat = "M월 d일(E)"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = displayLocale
        timeFormatter.timeZone = displayTimeZone
        timeFormatter.dateFormat = "a h:mm"

        return (
            date: dateFormatter.string(from: date),
            time: timeFormatter.string(from: date)
        )
    }

    func formatFee(_ fee: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        return (formatter.string(from: NSNumber(value: fee)) ?? "0") + "원"
    }

    func formatFeeChip(_ fee: Int) -> String {
        return "참가비 \(formatFee(fee))"
    }

    func formatSkillChip(min: String?, max: String?) -> String {
        return "실력 \(formatSkillRange(min: min, max: max))"
    }

    func formatLocationTitle(location: String, address: String?) -> String {
        let resolvedRegion = resolveRegion(from: location, address: address) ?? "기타지역"
        let condensed = condensedAddress(location: location, address: address)
        let detail = condensed.isEmpty ? location : condensed
        return "[\(resolvedRegion)] \(detail)"
    }

    func formatPositions(_ positions: [String: Int]) -> String {
        return positions
            .sorted { $0.key < $1.key }
            .map { "\($0.key) \($0.value)명" }
            .joined(separator: ", ")
    }

    func formatPositionSummary(_ positions: [String: Int]) -> String {
        let text = formatPositions(positions)
        return text.isEmpty ? "" : "포지션 \(text)"
    }

    func formatMatchType(_ matchType: String?) -> String {
        guard let matchType else { return "경기유형 미정" }
        switch matchType {
        case "11v11": return "11 vs 11"
        case "6v6": return "풋살"
        default: return matchType
        }
    }

    func formatSkillRange(min: String?, max: String?) -> String {
        let localizedMin = localizeSkill(min)
        let localizedMax = localizeSkill(max)

        if let localizedMin, let localizedMax {
            return localizedMin == localizedMax ? localizedMin : "\(localizedMin) ~ \(localizedMax)"
        }
        if let localizedMin { return localizedMin }
        if let localizedMax { return localizedMax }
        return "무관"
    }

    func formatFormerPlayerType(_ hasFormerPlayer: Bool?) -> String {
        guard let hasFormerPlayer else { return "유형 무관" }
        return hasFormerPlayer ? "선출 포함" : "비선출 우선"
    }

    private func parseDate(_ dateString: String) -> Date? {
        let isoWithFractional = ISO8601DateFormatter()
        isoWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoWithFractional.date(from: dateString) {
            return date
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd HH:mm"
        ]

        for format in dateFormats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = displayTimeZone
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }

    private func localizeSkill(_ rawSkill: String?) -> String? {
        guard let rawSkill else { return nil }

        switch rawSkill.lowercased() {
        case "beginner": return "초급"
        case "intermediate": return "중급"
        case "advanced": return "상급"
        case "expert": return "최상"
        default: return rawSkill
        }
    }

    private func resolveRegion(from location: String, address: String?) -> String? {
        let normalizedLocation = normalizeRegionText(location)
        if let rule = Self.regionRules.first(where: { normalizedLocation.contains($0.canonical) }) {
            return rule.display
        }

        let source = "\(location) \(address ?? "")"
        if let rule = Self.regionRules.first(where: { rule in
            rule.keywords.contains(where: { source.contains($0) })
        }) {
            return rule.display
        }
        return nil
    }

    private func normalizeRegionText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "/", with: "")
    }

    private func condensedAddress(location: String, address: String?) -> String {
        let primary = (address?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? address! : location
        let parts = primary.split(separator: " ").map(String.init)
        guard parts.count > 1 else { return primary }

        // 지역 prefix를 제외하고 핵심 구장명 중심으로 표시
        let significantParts = parts.dropFirst(1)
        let condensed = significantParts.joined(separator: " ")
        return condensed.isEmpty ? primary : condensed
    }
}
