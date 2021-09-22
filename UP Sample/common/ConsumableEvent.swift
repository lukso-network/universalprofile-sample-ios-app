//
//  ConsumableEvent.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

final class ConsumableEvent<T> {
    
    private var consumed = false
    private let value: T?
    
    init(_ value:  T?) {
        self.value = value
    }
    
    func isConsumed() -> Bool {
        return consumed
    }
    
    func getIfNotConsumed() -> T? {
        if consumed {
            return nil
        }
        consumed = true
        return value
    }
    
    func get() -> T? {
        consumed = true
        return value
    }
    
    static func empty() -> ConsumableEvent<T> {
        return .init(nil)
    }
}
