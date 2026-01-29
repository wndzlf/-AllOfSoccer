//
//  AllOfSoccerProvider.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/11/27.
//

import Foundation

struct APIService {

    static let shared = APIService()
    
    private let baseURL = "http://localhost:3000"

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
