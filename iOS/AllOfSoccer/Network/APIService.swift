//
//  AllOfSoccerProvider.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/11/27.
//

import Foundation
import UIKit

struct APIService {

    static let shared = APIService()

    // 로컬 개발 환경: 맥 IP 주소로 설정
    // 프로덕션: 실제 서버 주소로 변경
    private let baseURL = "http://172.30.1.76:3000"

    // MARK: - Email Sign-In
    func emailSignIn(email: String, password: String, completion: @escaping (Result<AppleSignInResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/auth/signin") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let signInResponse = try JSONDecoder().decode(AppleSignInResponse.self, from: data)
                    completion(.success(signInResponse))
                } catch {
                    print("이메일 로그인 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func emailSignUp(email: String, password: String, name: String, completion: @escaping (Result<AppleSignInResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/auth/signup") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": email, "password": password, "name": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let signUpResponse = try JSONDecoder().decode(AppleSignInResponse.self, from: data)
                    completion(.success(signUpResponse))
                } catch {
                    print("회원가입 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Apple Sign-In
    func appleSignIn(appleId: String, email: String?, name: String?,
                     completion: @escaping (Result<AppleSignInResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/auth/apple-signin") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = ["apple_id": appleId]
        if let email = email { body["email"] = email }
        if let name = name { body["name"] = name }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let signInResponse = try JSONDecoder().decode(AppleSignInResponse.self, from: data)
                    completion(.success(signInResponse))
                } catch {
                    print("Apple Sign-In 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Logout
    func logout(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/auth/logout") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(true))
            }
        }.resume()
    }

    // MARK: - Profile
    func getProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/auth/profile") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let profileResponse = try JSONDecoder().decode(ProfileResponse.self, from: data)
                    if let profile = profileResponse.data {
                        completion(.success(profile))
                    } else {
                        completion(.failure(NetworkError.noData))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // 좋아요 토글 (Mock API)
    func toggleLike(matchId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            completion(.success(true))
        }
    }
    
    // 매칭 생성
    func createMatch(data: MatchCreationData, completion: @escaping (Result<CreateMatchResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/matches") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // ISO 8601 날짜 포맷
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        let dateString = dateFormatter.string(from: data.date)

        let trimmedIntro = data.teamIntroduction?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContact = data.contactInfo?.trimmingCharacters(in: .whitespacesAndNewlines)
        let contactLine = (trimmedContact?.isEmpty == false) ? "연락처: \(trimmedContact!)" : nil

        var descriptionParts: [String] = []
        if let intro = trimmedIntro, !intro.isEmpty {
            descriptionParts.append(intro)
        }
        if let contactLine = contactLine {
            descriptionParts.append(contactLine)
        }

        let finalDescription = descriptionParts.isEmpty ? "" : descriptionParts.joined(separator: "\n")

        var body: [String: Any] = [
            "title": "\(data.location) \(data.matchType) 경기",
            "description": finalDescription,
            "date": dateString,
            "location": data.location,
            "match_type": data.matchType,
            "gender_type": data.genderType,
            "shoes_requirement": data.shoesRequirement,
            "fee": data.fee,
            "has_former_player": data.hasFormerPlayer
        ]

        if let address = data.address { body["address"] = address }
        if let latitude = data.latitude { body["latitude"] = latitude }
        if let longitude = data.longitude { body["longitude"] = longitude }
        if let teamName = data.teamName { body["team_name"] = teamName }
        if let ageMin = data.ageRangeMin { body["age_range_min"] = ageMin }
        if let ageMax = data.ageRangeMax { body["age_range_max"] = ageMax }
        if let skillMin = data.skillLevelMin { body["skill_level_min"] = skillMin }
        if let skillMax = data.skillLevelMax { body["skill_level_max"] = skillMax }
        if let intro = trimmedIntro, !intro.isEmpty { body["team_introduction"] = intro }

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { responseData, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let responseData = responseData else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let createResponse = try JSONDecoder().decode(CreateMatchResponse.self, from: responseData)
                    completion(.success(createResponse))
                } catch {
                    print("매칭 생성 응답 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: responseData, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // 매칭 상세 조회
    func getMatchDetail(matchId: String, completion: @escaping (Result<MatchDetail, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/matches/\(matchId)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(MatchDetailResponse.self, from: data)
                    if let matchDetail = response.data {
                        completion(.success(matchDetail))
                    } else {
                        completion(.failure(NetworkError.noData))
                    }
                } catch {
                    print("매칭 상세 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // 매칭 참가 신청
    func applyForMatch(matchId: String, completion: @escaping (Result<ApplyMatchResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/matches/\(matchId)/apply") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(ApplyMatchResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("참가 신청 응답 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // 매칭 참가 취소
    func cancelMatchApplication(matchId: String, completion: @escaping (Result<CancelMatchResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/matches/\(matchId)/apply") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(CancelMatchResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("참가 취소 응답 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // 내가 등록한 매칭 목록 가져오기
    func getMyMatches(page: Int? = nil, limit: Int? = nil, completion: @escaping (Result<MatchListResponse, Error>) -> Void) {
        var urlComponents = URLComponents(string: "\(baseURL)/api/matches/my/created")!

        var queryItems: [URLQueryItem] = []
        if let page = page { queryItems.append(URLQueryItem(name: "page", value: "\(page)")) }
        if let limit = limit { queryItems.append(URLQueryItem(name: "limit", value: "\(limit)")) }
        urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(MatchListResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("내가 등록한 매칭 목록 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // 매칭 목록 가져오기
    func getMatches(
        page: Int? = nil,
        limit: Int? = nil,
        location: String? = nil,
        date: String? = nil,
        matchType: String? = nil,
        genderType: String? = nil,
        shoesRequirement: String? = nil,
        ageMin: Int? = nil,
        ageMax: Int? = nil,
        skillLevel: String? = nil,
        feeMin: Int? = nil,
        feeMax: Int? = nil,
        status: String? = nil,
        sortBy: String? = nil,
        sortOrder: String? = nil,
        completion: @escaping (Result<MatchListResponse, Error>) -> Void
    ) {
        // URL 구성
        var urlComponents = URLComponents(string: "\(baseURL)/api/matches")!
        
        // 쿼리 파라미터 추가
        var queryItems: [URLQueryItem] = []
        
        if let page = page { queryItems.append(URLQueryItem(name: "page", value: "\(page)")) }
        if let limit = limit { queryItems.append(URLQueryItem(name: "limit", value: "\(limit)")) }
        if let location = location { queryItems.append(URLQueryItem(name: "location", value: location)) }
        if let date = date { queryItems.append(URLQueryItem(name: "date", value: date)) }
        if let matchType = matchType { queryItems.append(URLQueryItem(name: "match_type", value: matchType)) }
        if let genderType = genderType { queryItems.append(URLQueryItem(name: "gender_type", value: genderType)) }
        if let shoesRequirement = shoesRequirement { queryItems.append(URLQueryItem(name: "shoes_requirement", value: shoesRequirement)) }
        if let ageMin = ageMin { queryItems.append(URLQueryItem(name: "age_min", value: "\(ageMin)")) }
        if let ageMax = ageMax { queryItems.append(URLQueryItem(name: "age_max", value: "\(ageMax)")) }
        if let skillLevel = skillLevel { queryItems.append(URLQueryItem(name: "skill_level", value: skillLevel)) }
        if let feeMin = feeMin { queryItems.append(URLQueryItem(name: "fee_min", value: "\(feeMin)")) }
        if let feeMax = feeMax { queryItems.append(URLQueryItem(name: "fee_max", value: "\(feeMax)")) }
        if let status = status { queryItems.append(URLQueryItem(name: "status", value: status)) }
        if let sortBy = sortBy { queryItems.append(URLQueryItem(name: "sort_by", value: sortBy)) }
        if let sortOrder = sortOrder { queryItems.append(URLQueryItem(name: "sort_order", value: sortOrder)) }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // URLRequest 생성
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Authorization 헤더 추가 (JWT 토큰이 있다면)
        if let accessToken = Auth.accessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // URLSession으로 요청
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("네트워크 에러: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                do {
                    let matchData = try JSONDecoder().decode(MatchListResponse.self, from: data)
                    completion(.success(matchData))
                } catch {
                    print("JSON 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "데이터 없음")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Network Error
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .noData:
            return "데이터를 받지 못했습니다."
        case .decodingError:
            return "데이터 파싱에 실패했습니다."
        case .serverError(let message):
            return "서버 오류: \(message)"
        }
    }
}

extension APIService {
    func parseRootData<T: Decodable>(result: Result<Data, Error>,
                           completion: (Result<T, Error>) -> Void) {
        switch result {
        case let .success(data):
            do {
                let rootData = try JSONDecoder().decode(RootResponse<T>.self, from: data)
                completion(.success(rootData.data))
            } catch {
                completion(.failure(error))
            }

        case let .failure(error):
            completion(.failure(error))
        }
    }

    // MARK: - Mercenary Requests
    func getMercenaryRequests(
        page: Int = 1,
        limit: Int = 20,
        location: String? = nil,
        matchType: String? = nil,
        skillLevel: String? = nil,
        status: String? = nil,
        completion: @escaping (Result<MercenaryRequestListResponse, Error>) -> Void
    ) {
        var urlComponents = URLComponents(string: "\(baseURL)/api/mercenary-requests")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        if let location = location { queryItems.append(URLQueryItem(name: "location", value: location)) }
        if let matchType = matchType { queryItems.append(URLQueryItem(name: "match_type", value: matchType)) }
        if let skillLevel = skillLevel { queryItems.append(URLQueryItem(name: "skill_level", value: skillLevel)) }
        if let status = status { queryItems.append(URLQueryItem(name: "status", value: status)) }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 429 {
                        let rateLimitError = NSError(domain: "APIService", code: 429, userInfo: [NSLocalizedDescriptionKey: "Too many requests. Please try again later."])
                        completion(.failure(rateLimitError))
                        return
                    }
                    if httpResponse.statusCode >= 400 {
                        let serverError = NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])
                        completion(.failure(serverError))
                        return
                    }
                }

                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(MercenaryRequestListResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    // If JSON decoding fails, check if it's a plain text error response
                    if let plainTextError = String(data: data, encoding: .utf8), plainTextError.contains("too many requests") || plainTextError.contains("Too many") {
                        let rateLimitError = NSError(domain: "APIService", code: 429, userInfo: [NSLocalizedDescriptionKey: plainTextError])
                        completion(.failure(rateLimitError))
                    } else {
                        print("용병 모집 목록 파싱 에러: \(error)")
                        print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }

    func getMercenaryRequestDetail(
        requestId: String,
        completion: @escaping (Result<MercenaryRequestResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/mercenary-requests/\(requestId)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        let serverError = NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])
                        completion(.failure(serverError))
                        return
                    }
                }

                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(MercenaryRequestResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("용병 모집 상세 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func createMercenaryRequest(
        title: String,
        description: String?,
        date: String,
        location: String,
        address: String?,
        fee: Int,
        mercenaryCount: Int,
        positionsNeeded: [String: Int],
        skillLevelMin: String?,
        skillLevelMax: String?,
        teamName: String?,
        completion: @escaping (Result<MercenaryRequestResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/mercenary-requests") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body: [String: Any] = [
            "title": title,
            "date": date,
            "location": location,
            "fee": fee,
            "mercenary_count": mercenaryCount,
            "positions_needed": positionsNeeded
        ]

        if let description = description { body["description"] = description }
        if let address = address { body["address"] = address }
        if let skillLevelMin = skillLevelMin { body["skill_level_min"] = skillLevelMin }
        if let skillLevelMax = skillLevelMax { body["skill_level_max"] = skillLevelMax }
        if let teamName = teamName { body["team_name"] = teamName }

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(MercenaryRequestResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("용병 모집 생성 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Mercenary Applications
    func getMercenaryApplications(
        page: Int = 1,
        limit: Int = 20,
        skillLevel: String? = nil,
        status: String? = nil,
        completion: @escaping (Result<MercenaryApplicationListResponse, Error>) -> Void
    ) {
        var urlComponents = URLComponents(string: "\(baseURL)/api/mercenary-applications")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        if let skillLevel = skillLevel { queryItems.append(URLQueryItem(name: "skill_level", value: skillLevel)) }
        if let status = status { queryItems.append(URLQueryItem(name: "status", value: status)) }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 429 {
                        let rateLimitError = NSError(domain: "APIService", code: 429, userInfo: [NSLocalizedDescriptionKey: "Too many requests. Please try again later."])
                        completion(.failure(rateLimitError))
                        return
                    }
                    if httpResponse.statusCode >= 400 {
                        let serverError = NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])
                        completion(.failure(serverError))
                        return
                    }
                }

                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(MercenaryApplicationListResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    // If JSON decoding fails, check if it's a plain text error response
                    if let plainTextError = String(data: data, encoding: .utf8), plainTextError.contains("too many requests") || plainTextError.contains("Too many") {
                        let rateLimitError = NSError(domain: "APIService", code: 429, userInfo: [NSLocalizedDescriptionKey: plainTextError])
                        completion(.failure(rateLimitError))
                    } else {
                        print("용병 지원 목록 파싱 에러: \(error)")
                        print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }

    func createMercenaryApplication(
        title: String,
        description: String?,
        availableDates: [String],
        preferredLocations: [String],
        positions: [String],
        skillLevel: String,
        preferredFeeMin: Int?,
        preferredFeeMax: Int?,
        completion: @escaping (Result<MercenaryApplicationResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/mercenary-applications") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body: [String: Any] = [
            "title": title,
            "available_dates": availableDates,
            "preferred_locations": preferredLocations,
            "positions": positions,
            "skill_level": skillLevel
        ]

        if let description = description { body["description"] = description }
        if let preferredFeeMin = preferredFeeMin { body["preferred_fee_min"] = preferredFeeMin }
        if let preferredFeeMax = preferredFeeMax { body["preferred_fee_max"] = preferredFeeMax }

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(MercenaryApplicationResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("용병 지원 생성 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func getMyMercenaryRequests(
        page: Int = 1,
        limit: Int = 20,
        completion: @escaping (Result<MercenaryRequestListResponse, Error>) -> Void
    ) {
        var urlComponents = URLComponents(string: "\(baseURL)/api/mercenary-requests/my/created")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        let serverError = NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])
                        completion(.failure(serverError))
                        return
                    }
                }

                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(MercenaryRequestListResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("내 용병 모집 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func getMyFavoriteMatches(
        page: Int = 1,
        limit: Int = 20,
        completion: @escaping (Result<MatchListResponse, Error>) -> Void
    ) {
        var urlComponents = URLComponents(string: "\(baseURL)/api/users/my/interests/matches")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        let serverError = NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])
                        completion(.failure(serverError))
                        return
                    }
                }

                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(MatchListResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("찜한 팀 매칭 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func getMyFavoriteMercenaryRequests(
        page: Int = 1,
        limit: Int = 20,
        completion: @escaping (Result<MercenaryRequestListResponse, Error>) -> Void
    ) {
        var urlComponents = URLComponents(string: "\(baseURL)/api/users/my/interests/mercenary")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        let serverError = NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])
                        completion(.failure(serverError))
                        return
                    }
                }

                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(MercenaryRequestListResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("찜한 용병 모집 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - User Profile (New UserProfile model)
    func getUserProfile(completion: @escaping (Result<UserProfileDetailResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/users/profile/me") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(UserProfileDetailResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("사용자 프로필 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func updateUserProfile(
        nickname: String?,
        bio: String?,
        preferredPositions: [String]?,
        preferredSkillLevel: String?,
        location: String?,
        completion: @escaping (Result<UserProfileDetailResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/users/profile/me") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body: [String: Any] = [:]
        if let nickname = nickname { body["nickname"] = nickname }
        if let bio = bio { body["bio"] = bio }
        if let positions = preferredPositions { body["preferred_positions"] = positions }
        if let skillLevel = preferredSkillLevel { body["preferred_skill_level"] = skillLevel }
        if let location = location { body["location"] = location }

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(UserProfileDetailResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("프로필 수정 파싱 에러: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Like/Unlike APIs
    func likeMatch(matchId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/matches/\(matchId)/like") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(true))
            }
        }.resume()
    }

    func unlikeMatch(matchId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/matches/\(matchId)/like") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(true))
            }
        }.resume()
    }

    func likeMercenaryRequest(requestId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/mercenary-requests/\(requestId)/like") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(true))
            }
        }.resume()
    }

    func unlikeMercenaryRequest(requestId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/mercenary-requests/\(requestId)/like") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(true))
            }
        }.resume()
    }

    // MARK: - Mercenary Application
    func applyForMercenary(
        requestId: String,
        completion: @escaping (Result<MercenaryRequestResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/mercenary-requests/\(requestId)/apply") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(MercenaryRequestResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("용병 신청 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func cancelMercenaryApplication(
        requestId: String,
        completion: @escaping (Result<MercenaryRequestResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/mercenary-requests/\(requestId)/apply") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(MercenaryRequestResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("용병 신청 취소 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Profile Image Upload
    func uploadProfileImage(
        image: UIImage,
        completion: @escaping (Result<UserProfileDetailResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/users/profile-image/me") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let token = Auth.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // multipart/form-data로 이미지 전송
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // 이미지 바운더리 및 데이터
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append(imageData)
        }

        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(UserProfileDetailResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("프로필 이미지 업로드 파싱 에러: \(error)")
                    print("받은 데이터: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
