//
//  LSP3ProfileSearchView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import UIKit
import universalprofile_ios_sdk

struct LSP3ProfileSearchView: View {
    
    @StateObject private var viewModel = DependencyInjectorContainer.resolve(LSP3ProfileSearchViewModel.self)!

    @State private var erc725OrHash = "QmbKW24R7iHbBQDAeU5ekL7qtRX2hxmgDCijTVnLafEb88"
    @State private var isSearchButtonEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                defaultTextField("ERC-725/IPFS CID", text: $erc725OrHash)
                    .frame(maxWidth: .infinity)
                
                Button(action: {
                    viewModel.search(erc725OrHash)
                }, label: {
                    Text("Search").foregroundColor(.black.opacity(0.7))
                })
                .disabled(!isSearchButtonEnabled)
                .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
            }
            .padding(16)
            
            if viewModel.showProgress {
                ProgressView()
            } else if let profile = viewModel.profile {
                NavigationLink(destination: LSP3ProfileDetailsView(lsp3ProfileCid: profile.id)) {
                    LSP3ProfileView(profile: profile)
                }.accentColor(Color.black)
            } else {
                Text("Try to search")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .accentColor(Color.black)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 16)
        .mask(RoundedRectangle(cornerRadius: 9))
        .background(RoundedRectangle(cornerRadius: 9)
                        .fill(Color.lightStart)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 3, y: 3)
                        .shadow(color: .white.opacity(0.7), radius: 10, x: -2, y: -2))
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
}

struct LSP3ProfileSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LSP3ProfileSearchView()
    }
}

