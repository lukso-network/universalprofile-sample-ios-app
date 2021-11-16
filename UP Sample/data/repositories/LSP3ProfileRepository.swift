//
//  LSP3ProfileRepository.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import OrderedCollections
import universalprofile_ios_sdk

class LSP3ProfileRepository {
    
    public static let KeyLSP3Profiles = "KeyLSP3Profiles"
    
    private let provider: LSP3ProfileProvider
    private let keyValueStore: KeyValueStore
    private let cache = SimpleCache<IdentifiableLSP3Profile> { lsp3Profile in
        lsp3Profile.id
    }
    
    init(_ provider: LSP3ProfileProvider, _ keyValueStore: KeyValueStore) {
        self.provider = provider
        self.keyValueStore = keyValueStore
    }
    
    func get(id: String) -> IdentifiableLSP3Profile? {
        switch cache.get(id: id) {
            case .failure(let error):
                NSLog(error.localizedDescription)
                return nil
            case .success(let profile):
                return profile
        }
    }
    
    func list() -> Result<[IdentifiableLSP3Profile], AppError> {
        return listDisk().flatMap({ profiles in
            cache.set(list: profiles)
        })
    }
    
    func create(_ request: LSP3CreateProfileRequest, responseHandler: @escaping (Result<IdentifiableLSP3Profile, AppError>) -> Void) {
        func saveProfile(_ profile: IdentifiableLSP3Profile) {
            switch self.save(profile) {
                case .success(let profile):
                    responseHandler(.success(profile))
                case .failure(let error):
                    responseHandler(.failure(error))
            }
        }
        
        provider.uploadLSP3Profile(request) { result in
            switch result {
                case .success(let tuple):
                    saveProfile(IdentifiableLSP3Profile(id: tuple.0.hash, lsp3Profile: tuple.1))
                case .failure(let error):
                    responseHandler(.failure(.simpleException(error: error)))
                    
            }
        }
    }
    
    func save(_ profile: IdentifiableLSP3Profile) -> Result<IdentifiableLSP3Profile, AppError> {
        return listDisk().flatMap { profiles in
            var newProfiles = OrderedSet(profiles)
            newProfiles.append(profile)
            return saveList(list: newProfiles.elements).flatMap { _ in
                return .success(profile)
            }.flatMapError { error in
                return .failure(.simpleException(error: error))
            }
        }.flatMapError { error in
            return .failure(.simpleException(error: error))
        }
    }
    
    private func saveList(list: [IdentifiableLSP3Profile]) -> Result<[IdentifiableLSP3Profile], AppError> {
        return saveToDisk(list).flatMap({ profiles in
            return cache.set(list: profiles)
        })
    }
    
    private func listDisk() -> Result<[IdentifiableLSP3Profile], AppError> {
        do {
            guard let profiles: [IdentifiableLSP3Profile] = try keyValueStore.get(key: LSP3ProfileRepository.KeyLSP3Profiles) else {
                return .success([])
            }
            
            return .success(profiles)
        } catch {
            return .failure(.simpleException(error: error))
        }
    }
    
    private func saveToDisk(_ profiles: [IdentifiableLSP3Profile]) -> Result<[IdentifiableLSP3Profile], AppError> {
        do {
            // All saved profiles must have valid ID as CID multihash or at least must not be empty.
            let filteredProfiles = profiles.filter {
                UPWeb3Utils.isIpfsCid($0.id) || !$0.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            
            if !(try keyValueStore.save(key: LSP3ProfileRepository.KeyLSP3Profiles, value: filteredProfiles)) {
                return .failure(.simpleError(msg: "Failed to save a list of profiles under key = \(LSP3ProfileRepository.KeyLSP3Profiles)"))
            }
            return .success(profiles)
        } catch {
            return .failure(.simpleException(error: error))
        }
    }
    
    func search(lsp3Id: String, responseHandler: @escaping (Result<IdentifiableLSP3Profile, AppError>) -> Void) {
        if let lsp3Profile = get(id: lsp3Id) {
            responseHandler(.success(lsp3Profile))
        }
        
        provider.loadFromIPFS(lsp3Id) { result in
            switch result {
                case .success(let profile):
                    responseHandler(self.save(IdentifiableLSP3Profile(id: lsp3Id, lsp3Profile: profile)))
                case .failure(let error):
                    responseHandler(.failure(.simpleException(error: error)))
            }
        }
    }
}
