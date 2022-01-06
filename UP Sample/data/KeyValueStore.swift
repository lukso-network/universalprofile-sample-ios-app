//
//  KeyValueStore.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation

protocol KeyValueStore {
    func getRaw(key: String) -> String?
    func saveRaw(key: String, value: String) -> Bool
    
    func get<T>(key: String) throws -> T? where T: Decodable
    func save<T>(key: String, value: T) throws -> Bool where T: Encodable
    
    func delete(key: String) -> Bool
    func dump() -> String
}

class DefaultKeyValueStore: KeyValueStore {
    
    private static let SUITE_NAME = "com.livingpackets.common"
    
    private let prefs = UserDefaults(suiteName: SUITE_NAME)!
    
    
    func dump() -> String {
        return prefs.dictionaryRepresentation().map({ (key, value) in
            "\n\(key) ---->\n\(value)"
        }).joined(separator: "\n................")
    }
    
    func delete(key: String) -> Bool {
        prefs.removeObject(forKey: key)
        return true
    }
    
    func getRaw(key: String) -> String? {
        return prefs.string(forKey: key)
    }
    
    func saveRaw(key: String, value: String) -> Bool {
        prefs.setValue(value, forKey: key)
        return true
    }
    
    func get<T>(key: String) throws -> T? where T: Decodable {
        guard let rawJson = getRaw(key: key), !rawJson.isEmpty else { return nil }
        return try JSONDecoder().decode(T.self, from: Data(rawJson.bytes))
    }
    
    func save<T>(key: String, value: T) throws -> Bool where T: Encodable {
        let rawJsonData = try JSONEncoder().encode(value)
        guard let rawJson = String(data: rawJsonData, encoding: .utf8) else { return false }
        return saveRaw(key: key, value: rawJson)
    }
}
