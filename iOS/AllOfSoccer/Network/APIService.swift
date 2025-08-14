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

    func signIn(model: SignInModel, completion: @escaping (Result<SignInModel, Error>) -> Void) {
        // 기존 signIn 로직은 그대로 유지
        print("SignIn 기능은 추후 구현 예정")
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
