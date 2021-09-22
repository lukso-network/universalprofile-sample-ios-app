//
//  Views+Utility.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import UIKit

func getTopPadding() -> CGFloat {
    if UIDevice.current.hasNotch {
        return UIDevice.current.topNotch
    } else {
        return 16
    }
}

func getBottomPadding() -> CGFloat {
    if UIDevice.current.hasNotch {
        return UIDevice.current.bottomNotch + 32
    } else {
        return 64
    }
}
