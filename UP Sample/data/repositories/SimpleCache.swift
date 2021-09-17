//
//  SimpleCache.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation

class SimpleCache<T> {
    
    private var cache = [String : T]()
    private let getId: (T) -> String
    
    init(_ getId: @escaping (T) -> String) {
        self.getId = getId
    }
    
    func list() -> Result<[T], AppError> {
        return .success(cache.map({ (key: String, value: T) in
            return value
        }))
    }
    
    
    func get(id: String) -> Result<T, AppError> {
        guard let data = cache[id] else { return .failure(.itemNotFound) }
        return .success(data)
    }
    
    
    func set(list: [T]) -> Result<[T], AppError> {
        list.forEach { t in
            cache[getId(t)] = t
        }
        return .success(list)
    }
    
    
    func set(_ value: T) -> Result<T, AppError> {
        cache[getId(value)] = value
        return .success(value)
    }
}
