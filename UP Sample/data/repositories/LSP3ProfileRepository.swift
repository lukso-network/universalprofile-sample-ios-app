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
    private let cache = SimpleCache<LSP3Profile>.init { lsp3Profile in
        lsp3Profile.id
    }
    
    init(_ provider: LSP3ProfileProvider, _ keyValueStore: KeyValueStore) {
        self.provider = provider
        self.keyValueStore = keyValueStore
    }
    
    func get(id: String) -> LSP3Profile? {
        switch cache.get(id: id) {
            case .failure(let error):
                NSLog(error.localizedDescription)
                return nil
            case .success(let profile):
                return profile
        }
    }
    
    func list() -> Result<[LSP3Profile], AppError> {
        return listDisk().flatMap({ profiles in
            cache.set(list: profiles)
        })
    }
    
    func create(_ request: LSP3CreateProfileRequest, responseHandler: @escaping (Result<LSP3Profile, AppError>) -> Void) {
        func saveProfile(_ profile: LSP3Profile) {
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
                    saveProfile(tuple.1.copy(id: tuple.0.hash))
                case .failure(let error):
                    responseHandler(.failure(.simpleException(error: error)))
                    
            }
        }
    }
    
    func save(_ profile: LSP3Profile) -> Result<LSP3Profile, AppError> {
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
    
    private func saveList(list: [LSP3Profile]) -> Result<[LSP3Profile], AppError> {
        return saveToDisk(list).flatMap({ profiles in
            return cache.set(list: profiles)
        })
    }
    
    private func listDisk() -> Result<[LSP3Profile], AppError> {
        guard let diskText = keyValueStore.get(key: LSP3ProfileRepository.KeyLSP3Profiles),
              !diskText.isEmpty else {
            return .success([])
        }
        
        do {
            let result = try JSONDecoder().decode([LSP3Profile].self, from: Data(diskText.bytes))
            return .success(result)
        } catch {
            return .failure(.simpleException(error: error))
        }
    }
    
    private func saveToDisk(_ profiles: [LSP3Profile]) -> Result<[LSP3Profile], AppError> {
        do {
            // All saved profiles must have valid ID as CID multihash or at least must not be empty.
            let filteredProfiles = profiles.filter {
                UPWeb3Utils.isIpfsCid($0.id) || !$0.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            
            let jsonData = try JSONEncoder().encode(filteredProfiles)
            let json = String(data: jsonData, encoding: .utf8)!
            if !keyValueStore.save(key: LSP3ProfileRepository.KeyLSP3Profiles, value: json) {
                return .failure(.simpleError(msg: "Failed to save a list of profiles under key = \(LSP3ProfileRepository.KeyLSP3Profiles)"))
            }
            return .success(profiles)
        } catch {
            return .failure(.simpleException(error: error))
        }
    }
    
    func search(lsp3Id: String, responseHandler: @escaping (Result<LSP3Profile, AppError>) -> Void) {
        provider.loadFromIPFS(lsp3Id) { result in
            switch result {
                case .success(let profile):
                    responseHandler(self.save(profile.copy(id: lsp3Id)))
                case .failure(let error):
                    responseHandler(.failure(.simpleException(error: error)))
            }
        }
    }
}
