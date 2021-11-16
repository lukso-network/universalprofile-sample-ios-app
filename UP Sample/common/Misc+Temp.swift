//
//  Misc+Temp.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation

func randomNotSecureSalt() -> String {
    var saltData = Data()
    for _ in 0..<32 {
        saltData.append(contentsOf: [UInt8.random(in: 0..<255)])
    }
    return saltData.toHexString().addHexPrefix()
}
