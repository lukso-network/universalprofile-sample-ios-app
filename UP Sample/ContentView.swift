//
//  ContentView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import RxSwift

struct ContentView: View {
    
    let disposeBag = DisposeBag()
    let viewModel = DependencyInjectorContainer.resolve(BaseFlowViewModel.self)!
    @State private var showProgress = false
    @State private var showToastAlert = false
    @State private var toastMessage: String? = nil
    @State private var myInfo: MyInfo? = nil
    @State private var address: String = "..."
    @State private var publicKey: String = "..."
    @State private var errorText: String = "..."

    var body: some View {
        TabView {
            VStack(alignment: .leading) {
                Group {
                    Text("ERC725Key")
                        .font(.title3)
                    Text(publicKey)
                    Text("ERC725Address")
                        .font(.title3)
                    Text(address)
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
                
                Button(myInfo == nil ? "Sign in" : "Call me again") {
                    if myInfo == nil {
                        viewModel.signIn()
                    } else {
                        viewModel.callMe()
                    }
                }
                .padding(.all, 14)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .font(.title3)
                .foregroundColor(.white)
                .cornerRadius(12)
                
            }.frame(minWidth: 0, idealWidth: UIScreen.screenWidth, maxWidth: .infinity, minHeight: 0, idealHeight: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            .tabItem {
                Image("baseline_blur_circular_black_24pt")
                Text("Anonymous")
            }.alert(isPresented: $showToastAlert, content: {
                Alert(
                    title: Text("Hello!"),
                    message: Text(toastMessage ?? ""),
                    dismissButton: .default(Text("Close"))
                )
            })
        }.onAppear {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
