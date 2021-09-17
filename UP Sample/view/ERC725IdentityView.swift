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
    
    var body: some View {
        ZStack {
            LinearGradient(.lightStart, .lightEnd)
            VStack(alignment: .leading) {
                Group {
                    Text("ERC725Key")
                        .font(.title3)
                    // TODO: Why address is here?
                    Text(address)
                    Text("ERC725Address")
                        .font(.title3)
                    // TODO: Why public key is here?
                    Text(publicKey)
                }
                Divider()
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                
                Group {
                    Text("Result")
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity)
                    Text("ERC725Key")
                        .font(.title3)
                    Text(myInfo?.erc725Key ?? "...")
                    Text("ERC725Address")
                        .font(.title3)
                    Text(myInfo?.erc725Address ?? "...")
                    Text("IsAnonymous")
                    Text(isAnonymous())
                }
                
                if showProgress {
                    ProgressView()
                        .frame(width: 60, height: 60, alignment: .center)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    if myInfo == nil {
                        viewModel.signIn()
                    } else {
                        viewModel.callMe()
                    }
                }) {
                    Text(myInfo == nil ? "Sign in" : "Call me again")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.blue)
                }
                .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                .padding(16)
            }.frame(idealWidth: UIScreen.screenWidth,
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .leading)
            .background(Color.clear)
            .padding()
            .padding(.top, getTopPadding())
            .padding(.bottom, getBottomPadding())
            .alert(isPresented: $showToastAlert, content: {
                Alert(
                    title: Text("Message"),
                    message: Text(toastMessage ?? ""),
                    dismissButton: .default(Text("Close"))
                )
            })
        }
        .edgesIgnoringSafeArea(.all)
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
