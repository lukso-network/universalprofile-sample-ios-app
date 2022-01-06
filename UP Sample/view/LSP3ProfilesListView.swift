//
//  LSP3ProfilesListView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import universalprofile_ios_sdk

struct LSP3ProfilesListView: View {
    
    @StateObject private var viewModel = DependencyInjectorContainer.resolve(LSP3ProfileListViewModel.self)!
    
    @State private var fileHash = "QmaufE68Q6cdnFJk6VQvvkXgqP3x8Hfp8bhqrjijeRHrnh"
    @State private var isSearchButtonEnabled = true
    
    var body: some View {
        ZStack {
            LinearGradient(.lightStart, .lightEnd)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack(spacing: 0) {
                    TextField("Hash", text: $fileHash) { isEditing in
                        // Ignored
                    } onCommit: {
                        isSearchButtonEnabled = !fileHash.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .padding(.leading, 32)
                    .padding(.trailing, 32)
                    .background(NeomorphicStyle.TextField.standard
                                    .padding(.leading, 16)
                                    .padding(.trailing, 8))
                    
                    Button(action: {
                        viewModel.searchProfile(fileHash)
                    }, label: {
                        Text("Search").foregroundColor(.black.opacity(0.7))
                    }).disabled(!isSearchButtonEnabled)
                    .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                    .padding(.trailing, 16)
                }
                
                Divider().padding(.leading, 16).padding(.trailing, 16)
                
                Group {
                    Text("Cached profiles")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.7))
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.profiles, id: \.self) { profile in
                                NavigationLink(destination: LSP3ProfileDetailsView(lsp3ProfileCid: profile.id)) {
                                    LSP3ProfileRowView(profile: profile)
                                        .padding(.leading, 8)
                                        .padding(.trailing, 8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}

struct LSP3ProfilesListView_Previews: PreviewProvider {
    static var previews: some View {
        LSP3ProfilesListView()
    }
}


