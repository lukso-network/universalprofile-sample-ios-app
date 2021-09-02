//
//  KeyValueStore.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation

protocol KeyValueStore {
    func get(key: String) -> String?
    func save(key: String, value: String) -> Bool
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
    
    func get(key: String) -> String? {
        return prefs.string(forKey: key)
    }
    
    func save(key: String, value: String) -> Bool {
        prefs.setValue(value, forKey: key)
        return true
    }
    
}
