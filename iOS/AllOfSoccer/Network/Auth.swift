//
//  Auth.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/11/28.
//

import Foundation

class Auth {

    private static var accessTokenKey: String = "accessToken"

    static func accessToken() -> String? {

        if let accesstoken = UserDefaults.standard.string(forKey: "accesstoken") {
            return accesstoken
        } else {
            return nil
        }
    }

    static func updateAcceessToken(token: String) {
        UserDefaults.standard.set(token, forKey: "accesstoken")
    }

    static func reset() throws {
        try UserDefaults.standard.set(nil, forKey: "accesstoken")
    }
}

// MARK: - UserIdentifier
extension Auth {
    private static var userIdentifierKey: String = "userIdentifier"

    static func userIdentifier() -> String? {
        if let userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier") {
            return userIdentifier
        } else {
            return nil
        }
    }

    static func updateUserIdentifierKey(userIdentifier: String) {
        UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")
    }
}
