//
//  Either.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation

class Either<L, R> {
    
    let left: L?
    let right: R?
    
    init(left: L) {
        self.left = left
        self.right = nil
    }
    
    init(right: R) {
        self.right = right
        self.left = nil
    }
    
    var isSuccess: Bool {
        return right != nil
    }
    var isError: Bool {
        return left != nil
    }
    
    static func appError<AppError, R>(_ a: AppError) -> Either<AppError, R> {
        return Either<AppError, R>(left: a)
    }
    
    static func success<L, R>(_ a: R) -> Either<L, R> {
        return Either<L, R>(right: a)
    }
    
    func either<T>(fnL: (L) -> T, fnR: (R) -> T) -> T {
        if let left = left {
            return fnL(left)
        } else if let right = right {
            return fnR(right)
        } else {
            fatalError("Impossible case")
        }
    }
}
