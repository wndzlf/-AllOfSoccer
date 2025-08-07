//
//  AllOfSoccerRootResponse.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/11/27.
//

import Foundation

struct RootResponse<T: Decodable>: Decodable {
    var data: T
}
