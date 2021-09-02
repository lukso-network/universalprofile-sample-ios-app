//
//  AuthStore.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import universalprofile_ios_sdk

class AuthStore {
    private static let KEY_TOKEN = "KEY_TOKEN"
    
    private let keyValueStore: KeyValueStore
    
    var token: UPToken? = nil
    
    init(keyValueStore: KeyValueStore) {
        self.keyValueStore = keyValueStore
    }
    
    func getToken() -> Either<AppError, UPToken> {
        if let token = token {
            NSLog("DB Token: \(token)")
            return .success(token)
        }
        
        guard let result = keyValueStore.get(key: AuthStore.KEY_TOKEN), !result.isEmpty else {
            return .appError(.tokenNotFound)
        }
        
        NSLog("Raw Token: \(result)")
        
        do {
            token = try JSONDecoder().decode(UPToken.self, from: Data(result.bytes))
            
            NSLog("DB Token decoded: \(token!)")
            return .success(token!)
        } catch  {
            return .appError(.jsonMalFormed(error: error))
        }
    }
    
    func setToken(_ token: UPToken) -> Either<AppError, UPToken> {
        NSLog("Setting Token: \(token)")
        
        do {
            let tokenJson = try JSONEncoder().encode(token)
            
            if keyValueStore.save(key: AuthStore.KEY_TOKEN, value: String(data: tokenJson, encoding: .utf8)!) {
                self.token = token
                return .success(token)
            } else {
                return .appError(.storageException(error: UPSimpleError("couldn't write value at key \(AuthStore.KEY_TOKEN)")))
            }
        } catch {
            return .appError(.jsonMalFormed(error: error))
        }
    }
}
