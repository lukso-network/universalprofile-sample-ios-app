//
//  ERC725IdentityView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import RxSwift
import universalprofile_ios_sdk

struct ERC725IdentityView: View {
    
    let disposeBag = DisposeBag()
    let viewModel = DependencyInjectorContainer.resolve(IdentityProviderBaseFlowViewModel.self)!
    
    @State private var showProgress = false
    @State private var showToastAlert = false
    @State private var toastMessage: String? = nil
    @State private var myInfo: MyInfo? = nil
    @State private var address: String = "..."
    @State private var publicKey: String = "..."
    @State private var errorText: String = "..."
    
    private let lsp3SearchView = LSP3ProfileSearchView()
    
    var body: some View {
        ZStack {
            LinearGradient(.lightStart, .lightEnd)
                .edgesIgnoringSafeArea(.all)
            
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            Group {
                                Text("ERC725Key")
                                    .font(.title3)
                                    .padding(.top, 16)
                                // TODO: Why address is here?
                                Text(address)
                                    .font(.body)
                                    .padding()
                                    .foregroundColor(Color.black.opacity(0.75))
                                
                                Text("ERC725Address")
                                    .font(.title3)
                                // TODO: Why public key is here?
                                Text(publicKey)
                                    .font(.body)
                                    .foregroundColor(Color.black.opacity(0.75))
                                    .padding()
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            
                            Divider()
                            
                            Group {
                                Text("Result")
                                    .font(.headline.italic())
                                    .foregroundColor(Color.black.opacity(0.8))
                                    .padding(.top, 12)
                                    .padding(.bottom, 16)
                                    .frame(maxWidth: .infinity)
                                
                                Text("ERC725Key")
                                    .font(.title3)
                                Text(myInfo?.erc725Key ?? "...")
                                    .font(.body)
                                    .foregroundColor(Color.black.opacity(0.75))
                                    .padding()
                                
                                Text("ERC725Address")
                                    .font(.title3)
                                Text(myInfo?.erc725Address ?? "...")
                                    .font(.body)
                                    .foregroundColor(Color.black.opacity(0.75))
                                    .padding()
                                
                                Text("IsAnonymous")
                                Text(isAnonymous())
                                    .font(.body)
                                    .foregroundColor(Color.black.opacity(0.75))
                                    .padding()
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            
                            Button(action: {
                                if myInfo == nil {
                                    viewModel.signIn()
                                } else {
                                    viewModel.callMe()
                                }
                            }) {
                                ZStack(alignment: .trailing) {
                                    Text(myInfo == nil ? "Sign in" : "Call me again")
                                        .font(.title3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.blue)
                                    
                                    if showProgress {
                                        ProgressView()
                                    }
                                }
                            }
                            .disabled(showProgress)
                            .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                            .padding(.top, 32)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                        }
                        .mask(RoundedRectangle(cornerRadius: 9))
                        .background(RoundedRectangle(cornerRadius: 9)
                                        .fill(Color.lightStart)
                                        .shadow(color: .black.opacity(0.2), radius: 10, x: 3, y: 3)
                                        .shadow(color: .white.opacity(0.7), radius: 10, x: -2, y: -2))
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                        
                        Divider()
                            .padding(.top, 16)
                        
                        defaultTitleText("Search LSP3 profiles", .headline)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        
                        defaultTitleText("Note: this is a standalone UI element that can be basically drag & dropped into a place where it is needed. It is easy as writing `LSP3ProfileSearchView()`.",
                                         .system(size: 10).italic())
                            .padding(.top, 8)
                            .padding(.trailing, 16)
                            .padding(.bottom, 4)
                        
                        lsp3SearchView
                        
                        Spacer()
                    }
                }
            .alert(isPresented: $showToastAlert, content: {
                Alert(
                    title: Text("Message"),
                    message: Text(toastMessage ?? ""),
                    dismissButton: .default(Text("Close"))
                )
            })
        }
        .onAppear {
            viewModel.progress
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { isInProgress in
                    self.showProgress = isInProgress
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.keystore
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { keystore in
                    if let address = keystore?.getAddress()?.address {
                        self.address = address.addHexPrefix()
                    }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.errorEventData
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { error in
                    NSLog(error.description())
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.myInfo
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { myInfo in
                    self.myInfo = myInfo
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.toast
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { toastMessage in
                    self.toastMessage = toastMessage
                    self.showToastAlert = true
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.load()
        }
    }
    
    private func isAnonymous() -> String {
        if myInfo == nil {
            return "..."
        } else {
            return String.init(describing: myInfo!.isAnonymous)
        }
    }
}


struct ERC725IdentityView_Previews: PreviewProvider {
    static var previews: some View {
        ERC725IdentityView()
    }
}
