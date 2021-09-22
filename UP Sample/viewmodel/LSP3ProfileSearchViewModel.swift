//
//  LSP3ProfileSearchViewModel.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import RxRelay
import RxSwift
import universalprofile_ios_sdk

class LSP3ProfileSearchViewModel {
    
    let progress = BehaviorRelay<Bool>(value: false)
    let errorEvent = PublishRelay<AppError>()
    let lsp3Profile = BehaviorRelay<LSP3Profile?>(value: nil)
    
    private let lsp3ProfileRepository: LSP3ProfileRepository
    
    init(_ lsp3ProfileRepository: LSP3ProfileRepository) {
        self.lsp3ProfileRepository = lsp3ProfileRepository
    }
    
    func search(_ input: String) {
        if UPWeb3Utils.isAddress(input) {
            // Search on a blockchain
            // FIXME: search on blockchain
            lsp3Profile.accept(LSP3Profile(id: "1", name: "An attempt to search on blockchain", description: "You entered a valid address", links: [], tags: [], profileImage: [], backgroundImage: []))
        } else if UPWeb3Utils.isIpfsCid(input) {
            // Search on IPFS
            searchOnIPFS(input)
        } else {
            NSLog("Invalid input. Not an ethereum address or IPFS CID")
            errorEvent.accept(.simpleError(msg: "Invalid input. Not an ethereum address or IPFS CID."))
        }
    }
    
    private func searchOnIPFS(_ input: String) {
        lsp3ProfileRepository.search(lsp3Id: input) { result in
            switch result {
                case .success(let profile):
                    let _ = self.lsp3ProfileRepository.save(profile)
                    self.lsp3Profile.accept(profile)
                case .failure(let error):
                    self.onError(error)
            }
        }
    }
    
    private func onError(_ error: AppError) {
        progress.accept(false)
        NSLog(error.description())
        errorEvent.accept(error)
    }
}
