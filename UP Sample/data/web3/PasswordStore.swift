//
//  PasswordStore.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation

class PasswordStore {
    private let keyValueStore: KeyValueStore
    private var password: String? = nil
    
    private static let PasswordKey = "network.lukso.up.passwordh"

    init(keyValueStore: KeyValueStore) {
        self.keyValueStore = keyValueStore
    }

    func setPassword(password: String) -> Result<String, AppError> {
        guard let hashedPassword = BCryptSwift.hashPassword(password, withSalt: BCryptSwift.generateSalt()) else {
            return .failure(.simpleError(msg: "Failed to hash a password using BCrypt"))
        }

        if try! keyValueStore.save(key: PasswordStore.PasswordKey, value: hashedPassword) {
            self.password = password
            return .success(password)
        } else {
            return .failure(.simpleError(msg: "Couldn't save password"))
        }
    }

    func getCachedPassword() -> Result<String, AppError> {
        guard let password = password else { return .failure(.itemNotFound) }
        return .success(password)
    }
    
    func hasPassword() -> Result<Bool, AppError> {
        guard let passwordHashed = keyValueStore.getRaw(key: PasswordStore.PasswordKey) else { return .failure(.itemNotFound) }
        return .success(!passwordHashed.isEmpty)
    }

    func validateAndCachePassword(_ password: String) -> Result<Bool, AppError> {
        return validate(password)
    }

    private func validate(_ password: String) -> Result<Bool, AppError> {
        switch getHashedPassword() {
            case .success(let hashedPassword):
                return .success(BCryptSwift.verifyPassword(password, matchesHash: hashedPassword) == true)
            case .failure(let error):
                return .failure(error)
        }
    }

    private func getHashedPassword() -> Result<String, AppError> {
        guard let passwordHashed = keyValueStore.getRaw(key: PasswordStore.PasswordKey),
              !passwordHashed.isEmpty
              else { return .failure(.itemNotFound) }
        return .success(passwordHashed)
    }
}
