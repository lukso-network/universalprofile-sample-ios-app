//
//  NeomorphicButtonStyle.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import SwiftUI

struct NeomorphicButtonStyle<S: Shape>: ButtonStyle {
    
    let options: Options
    var isHighlighted = false
    var shape: S
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.all, options.padding)
            .contentShape(shape)
            .background(
                Group {
                    if configuration.isPressed {
                        switch options.pressedStateStyle {
                            case .outerShadow:
                                pressedOuter()
                            case .innerShadow:
                                pressedInner()
                        }
                    } else {
                        switch options.releasedStateStyle {
                            case .outerShadow:
                                releasedOuter()
                            case .innerShadow:
                                releasedInner()
                        }
                    }
                }
            )
    }
    
    private func pressedOuter() -> some View {
        shape.fill(Color.lightStart)
            .shadow(color: .black.opacity(0.2), radius: 14, x: 10, y: 10)
            .shadow(color: .white.opacity(0.7), radius: 14, x: -5, y: -5)
    }
    
    private func pressedInner() -> some View {
        return shape.fill(Color.lightStart)
            .overlay(
                shape.stroke(Color.gray, lineWidth: 4)
                    .blur(radius: 4.0)
                    .offset(x: 2, y: 2)
                    .mask(shape.fill(LinearGradient(.black, .clear)))
            )
            .overlay(
                shape.stroke(Color.white, lineWidth: 8)
                    .blur(radius: 4)
                    .offset(x: -2, y: -2)
                    .mask(shape.fill(LinearGradient(.black, .clear)))
            )
    }
    
    private func releasedOuter() -> some View {
        return shape.fill(Color.lightStart)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 10, y: 10)
            .shadow(color: .white.opacity(0.7), radius: 10, x: -5, y: -5)
    }
    
    private func releasedInner() -> some View {
        return shape.fill(Color.lightStart)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 10, y: 10)
            .shadow(color: .white.opacity(0.7), radius: 10, x: -5, y: -5)
    }
    
    struct Options {
        let padding: CGFloat
        let pressedStateStyle: StateStyle
        let releasedStateStyle: StateStyle
    }
}

enum StateStyle {
    case outerShadow, innerShadow
}
