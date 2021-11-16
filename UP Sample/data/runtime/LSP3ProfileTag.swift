//
//  LSP3ProfileTag.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import SwiftUI

class LSP3ProfileTag: Identifiable, Hashable {
    
    static func == (lhs: LSP3ProfileTag, rhs: LSP3ProfileTag) -> Bool {
        return lhs.tag == rhs.tag
    }
    
    let id = UUID()
    let tag: String
    
    init(tag: String) {
        self.tag = tag
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tag.hashValue &* 13)
    }
}
