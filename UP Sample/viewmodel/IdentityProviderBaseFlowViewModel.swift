//
//  IdentityProviderBaseFlowViewModel.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import RxSwift
import RxRelay
import web3swift
import universalprofile_ios_sdk

class IdentityProviderBaseFlowViewModel {
    
    private let signInUsecase: SignInUsecase
    private let sampleResourceService: SampleResourceService
    private let web3KeyStore: Web3KeyStore
    
    let errorEventData = PublishRelay<AppError>()
    let progress = BehaviorRelay<Bool>(value: false)
    let toast = PublishRelay<String>()
    let myInfo = BehaviorRelay<MyInfo?>(value: nil)
    let keystore = BehaviorRelay<EthereumKeystoreV3?>(value: nil)
    
    init(signInUsecase: SignInUsecase,
         sampleResourceService: SampleResourceService,
         web3KeyStore: Web3KeyStore) {
        self.signInUsecase = signInUsecase
        self.sampleResourceService = sampleResourceService
        self.web3KeyStore = web3KeyStore
    }
    
    func load() {
        progress.accept(true)
        
        switch web3KeyStore.loadOrGenerateDefaultKeyPair() {
            case .success(let keystore):
                self.onWalletFound(keystore)
                self.progress.accept(false)
            case .failure(let error):
                self.onError(error)
                self.progress.accept(false)
        }
    }
    
    private func onWalletFound(_ keystore: EthereumKeystoreV3) {
        self.keystore.accept(keystore)
    }
    
    func signIn() {
        progress.accept(true)
        signInUsecase.signIn { result in
            switch result {
                case .success:
                    self.callMe()
                case .failure(let error):
                    self.onError(error)
                    self.progress.accept(false)
            }
        }
    }
    
    private func onSuccessFullySignedIn(_ myInfo: MyInfo) {
        toastIt("Received my info")
        self.myInfo.accept(myInfo)
    }
    
    private func onError(_ error: AppError) {
        NSLog(error.description())
        errorEventData.accept(error)
    }
    
    private func toastIt(_ msg: String) {
        toast.accept(msg)
    }
    
    func callMe() {
        progress.accept(true)
        sampleResourceService.getMyInfo { result in
            switch result {
                case .success(let me):
                    self.onSuccessFullySignedIn(me)
                case .failure(let error):
                    self.onError(.simpleException(error: error))
            }
            self.progress.accept(false)
        }
    }
}

