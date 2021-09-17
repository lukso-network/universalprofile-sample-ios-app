//
//  NeomorphicStyles.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import SwiftUI

final class NeomorphicStyle {
    private init() {}
    final class TextField {
        private init() {}
        
        static var standard: some View {
            RoundedRectangle(cornerRadius: 12).fill(Color.lightStart)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 3, y: 3)
                .shadow(color: .white.opacity(0.7), radius: 6, x: -3, y: -3)
                .padding(.leading, 16)
                .padding(.trailing, 16)
        }
    }
    
    final class Button {
        private init() {}
        
        static var standardRoundedRect: NeomorphicButtonStyle<RoundedRectangle> {
            let options = NeomorphicButtonStyle<RoundedRectangle>.Options(padding: 18,
                                                                          pressedStateStyle: .innerShadow,
                                                                          releasedStateStyle: .outerShadow)
            return NeomorphicButtonStyle<RoundedRectangle>(options: options,
                                                           shape: RoundedRectangle(cornerRadius: 12))
        }
        
    }
}
