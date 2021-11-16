//
//  Environments.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import universalprofile_ios_sdk

class TestIPFSServiceEnvironment: IPFSServiceEnvironment {
    func gatewayUrl() -> String {
        return IPFSClientImpl.LUKSOIPFS_GATEWAY
    }
    
    func clusterUrl() -> String {
        return IPFSClientImpl.LUKSOIPFS_CLUSTER
    }
}

class TestIpServiceEnvornment : UPIpServiceEnvironment {
    func baseUrl() -> String {
        return "http://35.246.184.226/api/v1/"
    }
}

class LocalIpServiceEnvornment : UPIpServiceEnvironment {
    func baseUrl() -> String {
        return "http//:localhost:8080/api/v1/"
    }
}

// MARK: - ResourceServiceEnvironment
class TestResourceServiceEnvironment : ResourceServiceEnvironment {
    func baseUrl() -> String {
        return "http://35.246.184.226:8081"
    }
}

class LocalResourceServiceEnvironment : ResourceServiceEnvironment {
    func baseUrl() -> String {
        return "http//:localhost:8081"
    }
}

