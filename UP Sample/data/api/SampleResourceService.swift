//
//  SampleResourceService.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import Alamofire

protocol SampleResourceService {
    func getMyInfo(_ responseHandler: @escaping (Result<MyInfo, AFError>) -> Void)
}

struct MyInfo: Codable {
    let erc725Address: String
    let erc725Key: String
    let isAnonymous: Bool
    
    public enum CodingKeys: String, CodingKey {
        case erc725Address = "ERC725Address"
        case erc725Key = "ERC725Key"
        case isAnonymous = "IsAnonymous"
    }
}
