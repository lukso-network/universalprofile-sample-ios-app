//
//  IdentityProviderBaseFlowViewModel.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import SwiftUI
import web3swift
import universalprofile_ios_sdk

class IdentityProviderBaseFlowViewModel: ObservableObject {
    
    private let signInUsecase: SignInUsecase
    private let sampleResourceService: SampleResourceService
    private let web3KeyStore: Web3KeyStore
    
    @Published var showProgress = false
    @Published var showToastAlert = false
    @Published private (set) var toastMessage: String? = nil
    @Published private (set) var myInfo: MyInfo? = nil
    @Published private (set) var address: String = "..."
    @Published private (set) var publicKey: String = "..."
    @Published private (set) var errorText: String = "..."
    
    private var keystore: EthereumKeystoreV3? = nil {
        didSet {
            if let keystore = keystore {
                address = keystore.getAddress()!.address.addHexPrefix()
            }
        }
    }
    
    init(signInUsecase: SignInUsecase,
         sampleResourceService: SampleResourceService,
         web3KeyStore: Web3KeyStore) {
        self.signInUsecase = signInUsecase
        self.sampleResourceService = sampleResourceService
        self.web3KeyStore = web3KeyStore
    }
    
    func load() {
        showProgress = true
        
        switch web3KeyStore.loadOrGenerateDefaultKeyPair() {
            case .success(let keystore):
                onWalletFound(keystore)
            case .failure(let error):
                onError(error)
        }
        
        showProgress = false
    }
    
    private func onWalletFound(_ keystore: EthereumKeystoreV3) {
        self.keystore = keystore
    }
    
    func signIn() {
        showProgress = true
        signInUsecase.signIn { result in
            switch result {
                case .success:
                    self.callMe()
                case .failure(let error):
                    self.onError(error)
                    self.showProgress = false
            }
        }
    }
    
    private func onSuccessFullySignedIn(_ myInfo: MyInfo) {
        toastIt("Received my info")
        self.myInfo = myInfo
    }
    
    private func onError(_ error: AppError) {
        NSLog(error.description())
        errorText = error.description()
    }
    
    private func toastIt(_ msg: String) {
        toastMessage = msg
        showToastAlert = true
    }
    
    func callMe() {
        showProgress = true
        sampleResourceService.getMyInfo { result in
            switch result {
                case .success(let me):
                    self.onSuccessFullySignedIn(me)
                case .failure(let error):
                    self.onError(.simpleException(error: error))
            }
            self.showProgress = false
        }
    }
}

