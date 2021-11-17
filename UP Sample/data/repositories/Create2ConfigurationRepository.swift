//
//  Create2ConfigurationRepository.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import universalprofile_ios_sdk

class Create2ConfigurationRepository {
    
    /// Cache lives at most 30 minutes
    private let ttl: TimeInterval = 1800
    private var cacheBirthtime: TimeInterval = 0
    private var awaitingHandlers = [(Result<Create2ConfigurationResponse, AppError>) -> Void]()
    private var cachedCreate2Configuration: Create2ConfigurationResponse? = nil
    private var inProgress = false
    
    let relayService: LuksoRelayService
    
    init(_ relayService: LuksoRelayService) {
        self.relayService = relayService
        cacheCreate2Configuration()
    }
    
    private func cacheCreate2Configuration() {
        getCreate2Configuration() { result in
            switch result {
                case .success(let response):
                    self.cachedCreate2Configuration = response
                default:
                    break
            }
        }
    }
    
    private func isCacheStale() -> Bool {
        return Date().timeIntervalSince1970 - cacheBirthtime >= ttl
    }
    
    private func cacheValue(_ value: Create2ConfigurationResponse) {
        cachedCreate2Configuration = value
        cacheBirthtime = Date().timeIntervalSince1970
    }
    
    func getCreate2Configuration(_ responseHandler: @escaping (Result<Create2ConfigurationResponse, AppError>) -> Void) {
        guard !inProgress && cachedCreate2Configuration == nil && isCacheStale() else {
            
            if let cache = cachedCreate2Configuration {
                responseHandler(.success(cache))
            } else {
                awaitingHandlers.append(responseHandler)
            }
            
            return
        }
        
        inProgress = true
        
        relayService.getCreate2Configuration { result in
            var processedResult: Result<Create2ConfigurationResponse, AppError>
            switch result {
                case .success(let response):
                    self.cacheValue(response)
                    processedResult = .success(response)
                case .failure(let error):
                    processedResult = .failure(.simpleException(error: error))
            }
            
            self.awaitingHandlers.forEach {
                $0(processedResult)
            }
            self.awaitingHandlers = []
            
            responseHandler(processedResult)
            
            self.inProgress = false
        }
    }
    
    @available(iOS 15, *)
    func getCreate2Configuration() async throws -> Create2ConfigurationResponse {
        if let cache = cachedCreate2Configuration, !isCacheStale() {
            return cache
        }
        
        return try await withCheckedThrowingContinuation({ continuation in
            relayService.getCreate2Configuration { result in
                switch result {
                    case .success(let response):
                        self.cacheValue(response)
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: AppError.simpleException(error: error))
                }
            }
        })
    }
}
