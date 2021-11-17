//
//  UniversalProfileRepository.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import universalprofile_ios_sdk
import Alamofire

final class UniversalProfileRepository {
        
    let relayService: LuksoRelayService
    let keyValueStore: KeyValueStore
    
    init(_ relayService: LuksoRelayService, _ keyValueStore: KeyValueStore) {
        self.relayService = relayService
        self.keyValueStore = keyValueStore
    }
    
    func uploadProfile(body: DeployLSP3ProfileRequest,
                       progressCallback: @escaping (LSP3ProfileDeployTaskResponse) -> Void,
                       responseHandler: @escaping (Result<(DeployLSP3ProfileResponse, LSP3ProfileDeployTaskResponse), AFError>) -> Void) {
        
        // Some caching may happen here using keyValueStore
        
        relayService.uploadProfile(body: body, progressCallback: progressCallback, responseHandler: responseHandler)
    }
}
