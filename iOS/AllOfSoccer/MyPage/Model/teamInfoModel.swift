//
//  teamInfoModel.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/19.
//

import Foundation

struct TeamInfoModel: Codable {
    let age: String
    let skill: String
    let Uniform: Uniform
    let phoneNumber: String
}

// 서버랑 협의 후 데이터 형태 결정 예정
struct Uniform: Codable {
    let top: [String]
    let bottom: String
}
