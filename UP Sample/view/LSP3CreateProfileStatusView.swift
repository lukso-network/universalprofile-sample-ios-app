//
//  LSP3CreateProfileStatusView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import RxSwift
import universalprofile_ios_sdk

struct LSP3CreateProfileStatusView: View {
    @ObservedObject private var viewModel: LSP3CreateProfileViewModel
    
    @State private var universalProfile: DeployLSP3ProfileResponse? = nil
    @State private var taskStatus: LSP3ProfileDeployTaskResponse? = nil
    @State private var identifiableLsp3Profile: IdentifiableLSP3Profile? = nil
    @State private var message: String = ""
    @State private var error: AppError? = nil
    
    private let disposeBag = DisposeBag()
    
    init(_ viewModel: LSP3CreateProfileViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            LinearGradient(.lightStart, .lightEnd)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    if taskStatus == nil || !taskStatus!.isDeployed() {
                        ProgressView().frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                        
                        Text(message)
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                    }
                    
                    Divider()
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                    
                    if let identifiableLsp3Profile = identifiableLsp3Profile {
                        Group{
                            Text("LSP3 profile")
                                .font(.title2)
                                .padding(.bottom, 16)
                            
                            let url = identifiableLsp3Profile.lsp3Profile.profileImage.first(where: { image in
                                image.height != nil && image.height! < 200 &&
                                    image.width != nil && image.width! < 200
                            })?.url
                            
                            if let url = url {
                                CustomAsyncImage(withURL: url,
                                                 defaultImage: UIImage(named: "user_profile_icon")!,
                                                 contentMode: .fill)
                                    .frame(width: 128, height: 128)
                                    .mask(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3).blur(radius: 3.0))
                                    .padding(.bottom, 16)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Text("ipfs://\(identifiableLsp3Profile.id)")
                                .padding(.bottom, 16)
                                .addContextMenuCopyButton {
                                    "ipfs://\(identifiableLsp3Profile.id)"
                                }
                        }
                    }
                    
                    Divider()
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                    
                    if let profile = universalProfile {
                        Text("Task ID: \(profile.taskId)")
                            .addContextMenuCopyButton {
                                profile.taskId
                            }
                    }
                    
                    Divider()
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                    
                    if let taskStatus = taskStatus {
                        Group{
                            Text("Deploying smart contracts")
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                            Text("Task status: \(taskStatus.status)").frame(maxWidth: .infinity)
                            
                            Divider().padding(.top, 16)
                            
                            displayContractData("ERC725", taskStatus.taskData?.contracts.erc725)
                                .padding(.top, 16)
                                .padding(.bottom, 16)
                            
                            Divider()
                            
                            displayContractData("Universal Receiver", taskStatus.taskData?.contracts.universalReceiver)
                                .padding(.top, 16)
                                .padding(.bottom, 16)
                            
                            Divider()
                            
                            displayContractData("Key Manager", taskStatus.taskData?.contracts.keyManager)
                                .padding(.top, 16)
                                .padding(.bottom, 16)
                        }
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)
            }
        }.onAppear {
            viewModel.progressMessage
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { message in
                    self.message = message
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.errorEvent
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { error in
                    self.error = error
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.taskStatus
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { taskStatus in
                    if let taskStatus = taskStatus?.getIfNotConsumed() {
                        self.taskStatus = taskStatus
                    }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.identifiableLsp3Profile
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { createdProfileEvent in
                    if let identifiableLsp3Profile = createdProfileEvent?.get() {
                        self.identifiableLsp3Profile = identifiableLsp3Profile
                    }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.universalProfile
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { universalProfile in
                    if let profile = universalProfile?.getIfNotConsumed() {
                        self.universalProfile = profile
                    }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
        }
    }
    
    private func displayContractData(_ smartContractTitle: String, _ status: Contract?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(smartContractTitle)
                .font(.title3)
                .padding(.bottom, 16)
            
            if let status = status {
                Text("Address: \(status.address)")
                    .padding(.bottom, 16)
                    .addContextMenuCopyButton {
                        status.address
                    }
                Text("Transaction hash: \(status.transactionHash)")
                    .padding(.bottom, 16)
                    .addContextMenuCopyButton {
                        status.transactionHash
                    }
                Text("Version: \(status.version)")
                    .padding(.bottom, 16)
                    .addContextMenuCopyButton {
                        status.version
                    }
                Text("Status: \(status.status)")
                    .padding(.bottom, 16)
                    .addContextMenuCopyButton {
                        status.status
                    }
                Text("Block number: \(status.blockNumber)")
                    .addContextMenuCopyButton {
                        String(describing: status.blockNumber)
                    }
            }
        }
    }
}

//struct LSP3CreateProfileStatusView_Previews: PreviewProvider {
//    static var previews: some View {
//        LSP3CreateProfileStatusView()
//    }
//}


