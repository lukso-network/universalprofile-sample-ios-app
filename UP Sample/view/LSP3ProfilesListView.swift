//
//  LSP3ProfilesListView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import RxSwift
import universalprofile_ios_sdk

struct LSP3ProfilesListView: View {
    let disposeBag = DisposeBag()
    let viewModel = DependencyInjectorContainer.resolve(LSP3ProfileListViewModel.self)!
    
    @State private var fileHash = "QmaufE68Q6cdnFJk6VQvvkXgqP3x8Hfp8bhqrjijeRHrnh"
    @State private var isSearchButtonEnabled = true
    @State private var profiles: [IdentifiableLSP3Profile] = []
    
    @State private var showAlert = false
    @State private var alertMessage: String? = nil
    @State private var showProgress = false
    
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
                            ForEach(profiles, id: \.self) { profile in
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
            viewModel.progress
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { isInProgress in
                    self.showProgress = isInProgress
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.lsp3Profiles
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { profiles in
                    self.profiles = profiles
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.errorEvent
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { error in
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.load()
        }
    }
}

struct LSP3ProfilesListView_Previews: PreviewProvider {
    static var previews: some View {
        LSP3ProfilesListView()
    }
}


