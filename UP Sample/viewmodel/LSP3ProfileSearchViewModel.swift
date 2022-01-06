//
//  LSP3ProfileSearchViewModel.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import SwiftUI
import universalprofile_ios_sdk

class LSP3ProfileSearchViewModel: ObservableObject {
    
    @Published private(set) var profile: IdentifiableLSP3Profile? = nil
    @Published var showAlert = false
    @Published private(set) var alertMessage: String? = nil
    @Published var showProgress = false
    @Published private(set) var errorEvent: AppError? = nil
    
    private let lsp3ProfileRepository: LSP3ProfileRepository
    
    init(_ lsp3ProfileRepository: LSP3ProfileRepository) {
        self.lsp3ProfileRepository = lsp3ProfileRepository
    }
    
    func search(_ input: String) {
        if UPWeb3Utils.isAddress(input) {
            // Search on a blockchain
            // FIXME: search on blockchain
            profile = IdentifiableLSP3Profile(id: "1",
                                                       lsp3Profile: LSP3Profile(name: "An attempt to search on blockchain", description: "You entered a valid address", links: [], tags: [], profileImage: [], backgroundImage: []))
        } else if UPWeb3Utils.isIpfsCid(input) {
            // Search on IPFS
            searchOnIPFS(input)
        } else {
            NSLog("Invalid input. Not an ethereum address or IPFS CID")
            onError(.simpleError(msg: "Invalid input. Not an ethereum address or IPFS CID."))
        }
    }
    
    private func searchOnIPFS(_ input: String) {
        lsp3ProfileRepository.search(lsp3Id: input) { result in
            switch result {
                case .success(let profile):
                    let _ = self.lsp3ProfileRepository.save(profile)
                    self.profile = profile
                case .failure(let error):
                    self.onError(error)
            }
        }
    }
    
    private func onError(_ error: AppError) {
        NSLog(error.description())
        showProgress = false
        errorEvent = error
        profile = nil
        alertMessage = error.description()
        showAlert = true
    }
}
