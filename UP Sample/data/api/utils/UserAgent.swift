//
//  UserAgent.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import UIKit

class UserAgent {
    private init() {}
    
    static let header = String(format:"IPSampleApp/%@ (%@)",
                        getApplicationVersionAndDate(), getDeviceInfo())
    static let platform = "ios"
    static let osBuild = UIDevice.current.systemVersion
    static let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
}

func getDeviceInfo() -> String {
    return "iOS \(UIDevice.current.systemVersion) \(UIDevice.current.deviceType.displayName)"
}

func getBuildDate() -> Date? {
    guard let infoPath = Bundle.main.path(forResource: "Info.plist", ofType: nil) else {
        return nil
    }
    guard let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath) else {
        return nil
    }
    let key = FileAttributeKey(rawValue: "NSFileCreationDate")
    guard let infoDate = infoAttr[key] as? Date else {
        return nil
    }
    return infoDate
}

func getApplicationVersionAndDate() -> String {
    return "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)  (\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)) (\(getBuildDate()?.withFormat("HH:mm dd/MM/yyyy") ?? ""))"
}
