//
//  LSP3ProfileRowView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import universalprofile_ios_sdk

struct LSP3ProfileRowView: View {
    var profile: IdentifiableLSP3Profile
    
    var body: some View {
        LSP3ProfileView(profile: profile)
            .padding(.bottom, 16)
            .mask(RoundedRectangle(cornerRadius: 9))
            .background(RoundedRectangle(cornerRadius: 9).fill(Color.lightStart)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 3, y: 3)
                            .shadow(color: .white.opacity(0.7), radius: 10, x: -2, y: -2))
            .padding(8)
    }
}

//struct LSP3ProfileRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        LSP3ProfileRowView()
//    }
//}

