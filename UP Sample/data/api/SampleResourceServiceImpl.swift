//
//  SampleResourceServiceImpl.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import Alamofire
import universalprofile_ios_sdk

protocol ResourceServiceEnvironment {
    func baseUrl() -> String
}

class SampleResourceServiceImpl: SampleResourceService {
    
    private let environment: ResourceServiceEnvironment
    private let authStore: AuthStore
    
    init(environment: ResourceServiceEnvironment, authStore: AuthStore) {
        self.environment = environment
        self.authStore = authStore
    }
    
    func getAuthorizationToken() -> String? {
        return authStore.getToken().either { error in
            return nil
        } fnR: { token in
            return token.token
        }
    }

    /// @GET("me")
    /// @Headers("Content-Type: application/json")
    func getMyInfo(_ responseHandler: @escaping (Result<MyInfo, AFError>) -> Void) {
        var requestUrl = URL(string: environment.baseUrl())!
        requestUrl.appendPathComponent("me")
        
        var headers: HTTPHeaders = [.contentType("application/json")]
        if let token = getAuthorizationToken() {
            headers.add(.authorization(bearerToken: token))
        }
        
        AF.request(requestUrl, method: .get,
                   headers: headers)
            .responseDecodable(of: MyInfo.self) { response in
                responseHandler(response.result)
            }
    }
    
}
