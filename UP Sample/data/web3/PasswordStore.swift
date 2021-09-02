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

    func setPassword(password: String) -> Either<AppError, String> {
        guard let hashedPassword = BCryptSwift.hashPassword(password, withSalt: BCryptSwift.generateSalt()) else {
            return .appError(.simpleError(msg: "Failed to hash a password using BCrypt"))
        }
        

        if keyValueStore.save(key: PasswordStore.PasswordKey, value: hashedPassword) {
            self.password = password
            return .success(password)
        } else {
            return .appError(.simpleError(msg: "Couldn't save password"))
        }
    }

    func getCachedPassword() -> Either<AppError, String> {
        guard let password = password else { return .appError(.itemNotFound) }
        return .success(password)
    }
    
    func hasPassword() -> Either<AppError, Bool> {
        guard let passwordHashed = keyValueStore.get(key: PasswordStore.PasswordKey) else { return .appError(.itemNotFound) }
        return .success(!passwordHashed.isEmpty)
    }

    func validateAndCachePassword(_ password: String) -> Either<AppError, Bool> {
        return validate(password)
    }

    private func validate(_ password: String) -> Either<AppError, Bool> {
        guard let hashedPassword = getHashedPassword().right else {
            return .appError(.simpleError(msg: "Couldn't find hashed password"))
        }
        return .success(BCryptSwift.verifyPassword(password, matchesHash: hashedPassword) == true)
    }

    private func getHashedPassword() -> Either<AppError, String> {
        guard let passwordHashed = keyValueStore.get(key: PasswordStore.PasswordKey),
              !passwordHashed.isEmpty
              else { return .appError(.itemNotFound) }
        return .success(passwordHashed)
    }
}
