//
//  AllOfSoccerProvider.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/11/27.
//

import Foundation

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

        var body: [String: Any] = [
            "title": "\(data.location) \(data.matchType) 경기",
            "description": data.teamIntroduction ?? "",
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
        if let intro = data.teamIntroduction { body["team_introduction"] = intro }

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
}
