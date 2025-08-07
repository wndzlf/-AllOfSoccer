////
////  AllOfSoccerProvider.swift
////  AllOfSoccer
////
////  Created by 최원석 on 2021/11/27.
////
//
//import Foundation
//import Moya
//
//struct APIService {
//
//    static let shared = APIService()
//
//    private let provider = MoyaProvider<APITarget>()
//
//    func signIn(model: SignInModel, completion: @escaping (Result<SignInModel, Error>) -> Void) {
//        provider.request(.signIn(model)) { result in
//            self.parseRootData(result: result, completion: completion)
//        }
//    }
//}
//
//extension APIService {
//    func parseRootData<T: Decodable>(result: Result<Response, MoyaError>,
//                           completion: (Result<T, Error>) -> Void) {
//        switch result {
//        case let .success(success):
//            let responseData = success.data
//            do {
//                let rootData = try JSONDecoder().decode(RootResponse<T>.self, from: responseData)
//                completion(.success(rootData.data))
//            } catch {
//                completion(.failure(error))
//            }
//
//        case let .failure(error):
//            completion(.failure(error))
//        }
//    }
//}
