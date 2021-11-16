//
//  AppError.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation

enum AppError: Error {
    case none(error: Error)
    case networkConnection(error: Error)
    case apiError(statusCode: Int, msg: String, error: Error)
    case noNetworkError
    case tokenNotFound
    case itemNotFound
    case jsonMalFormed(error: Error)
    case simpleError(msg: String)
    case simpleException(error: Error)
    case simpleExceptionWithMessage(msg: String, error: Error)
    case storageException(error: Error)
    case alreadyExists
    case notImplementedError
    
    func description() -> String {
        switch self {
            case .none(let error):
                return error.localizedDescription
            case .networkConnection(let error):
                return error.localizedDescription
            case .apiError(let statusCode, let msg, let error):
                return "Status code: \(statusCode)\nMessage: \(msg)\nError: \(error.localizedDescription)"
            case .noNetworkError:
                return "noNetworkError"
            case .tokenNotFound:
                return "tokenNotFound"
            case .itemNotFound:
                return "itemNotFound"
            case .jsonMalFormed(let error):
                return error.localizedDescription
            case .simpleError(let msg):
                return msg
            case .simpleException(let error):
                return error.localizedDescription
            case .simpleExceptionWithMessage(let msg, let error):
                return msg
            case .storageException(let error):
                return error.localizedDescription
            case .alreadyExists:
                return "alreadyExists"
            case .notImplementedError:
                return "notImplementedError"
        }
    }
}
