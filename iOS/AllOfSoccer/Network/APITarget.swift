//
//  AllOfSoccerService.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/11/27.
//

// Moya 대신 URLSession을 사용하므로 이 파일은 더 이상 사용하지 않습니다.
// APIService.swift에서 URLSession으로 직접 구현했습니다.

/*
import Foundation
import Moya

enum APITarget: TargetType {
    // 1. User - Authorization
    case signIn(SignInModel)
    
    // 2. Matches
    case getMatches(page: Int?, limit: Int?, location: String?, date: String?, matchType: String?, genderType: String?, shoesRequirement: String?, ageMin: Int?, ageMax: Int?, skillLevel: String?, feeMin: Int?, feeMax: Int?, status: String?, sortBy: String?, sortOrder: String?)

    var baseURL: URL {
        // baseURL - 서버의 도메인 (localhost:3000으로 변경)
        return URL(string: "http://localhost:3000/")!
    }

    // 세부 경로
    var path: String {
        switch self {
        // 1. User - Authorization
        case .signIn: return "api/v1/tabtab/user/add"
        
        // 2. Matches
        case .getMatches: return "api/matches"
        }
    }

    var method: Moya.Method {
        // method - 통신 method (get, post, put, delete ...)
        switch self {
        case .signIn: return .post
        case .getMatches: return .get
        }
    }

    /// Provides stub data for use in testing.
    var sampleData: Data {
        return Data()
    }

    /// The type of HTTP task to be performed.
    var task: Task {
        // task - 리퀘스트에 사용되는 파라미터 설정
        // 파라미터가 없을 때는 - .requestPlain
        // 파라미터 존재시에는 - .requestParameters(parameters: ["first_name": firstName, "last_name": lastName], encoding: URLEncoding.default)
        switch self {
        case let .signIn(logInModel):
            return .requestParameters(parameters: ["id": logInModel.id, "name": logInModel.name, "email": logInModel.email, "phone": logInModel.phone], encoding: URLEncoding.default)
            
        case let .getMatches(page, limit, location, date, matchType, genderType, shoesRequirement, ageMin, ageMax, skillLevel, feeMin, feeMax, status, sortBy, sortOrder):
            var parameters: [String: Any] = [:]
            
            if let page = page { parameters["page"] = page }
            if let limit = limit { parameters["limit"] = limit }
            if let location = location { parameters["location"] = location }
            if let date = date { parameters["date"] = date }
            if let matchType = matchType { parameters["match_type"] = matchType }
            if let genderType = genderType { parameters["gender_type"] = genderType }
            if let shoesRequirement = shoesRequirement { parameters["shoes_requirement"] = shoesRequirement }
            if let ageMin = ageMin { parameters["age_min"] = ageMin }
            if let ageMax = ageMax { parameters["age_max"] = ageMax }
            if let skillLevel = skillLevel { parameters["skill_level"] = skillLevel }
            if let feeMin = feeMin { parameters["fee_min"] = feeMin }
            if let feeMax = feeMax { parameters["fee_max"] = feeMax }
            if let status = status { parameters["status"] = status }
            if let sortBy = sortBy { parameters["sort_by"] = sortBy }
            if let sortOrder = sortOrder { parameters["sort_order"] = sortOrder }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }

    /// The type of validation to perform on the request. Default is `.none`.
    var validationType: ValidationType {
        // validationType - 허용할 response의 타입
        return .successAndRedirectCodes
    }

    /// The headers to be used in the request.
    var headers: [String: String]? {
        // headers - HTTP header
        var headers: [String: String] = [:]
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        
        // Authorization 헤더 추가 (JWT 토큰이 있다면)
        if let accessToken = Auth.accessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return headers
    }
}
*/
