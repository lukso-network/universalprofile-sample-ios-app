//
//  Environments.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import universalprofile_ios_sdk

class TestIpServiceEnvornment : UPIpServiceEnvornment {
    func baseUrl() -> String {
        return "http://35.246.184.226"
    }
}

class LocalIpServiceEnvornment : UPIpServiceEnvornment {
    func baseUrl() -> String {
        return "http//:localhost:8080"
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

