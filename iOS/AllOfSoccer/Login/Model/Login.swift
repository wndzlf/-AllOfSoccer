//
//  Login.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2022/03/01.
//

import Foundation

struct LogIn: Codable {

    struct SaveUserInfoModel: Codable {
        let ageRange: Int
        let displayName: String
        let displayPhone: String
        let email: String
        let id: Int
        let introduction: String
        let name: String
        let phone: String
        let profileImgUrl: String
        let skillLevel: Int
        let teamIds: String
    }

    struct BroewseUserInfoModel: Codable {
        let id: Int
        let name: String
        let email: String
        let phone: String
        let displayName: String
        let displayPhone: String
        let ageRange: Int
        let skillLevel: Int
        let teamIds: String
        let profileImgUrl: String
        let introduction: String
    }

}
