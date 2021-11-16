//
//  UniversalProfileRepository.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import universalprofile_ios_sdk

final class UniversalProfileRepository {
        
    let relayService: LuksoRelayService
    let keyValueStore: KeyValueStore
    
    init(_ relayService: LuksoRelayService, _ keyValueStore: KeyValueStore) {
        self.relayService = relayService
        self.keyValueStore = keyValueStore
    }
    
    // TODO: make use of relayService and Key-Value store
}
