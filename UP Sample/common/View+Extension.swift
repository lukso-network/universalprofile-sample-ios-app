//
//  View+Extension.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import SwiftUI

extension View {
    func addContextMenuCopyButton(_ content: @escaping () -> String) -> some View {
        self.contextMenu(ContextMenu(menuItems: {
            Button("Copy", action: {
                UIPasteboard.general.string = content()
            })
        }))
    }
}
