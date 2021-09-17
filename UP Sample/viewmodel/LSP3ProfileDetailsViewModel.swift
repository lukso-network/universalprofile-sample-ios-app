//
//  LSP3ProfileDetailsViewModel.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import RxRelay
import universalprofile_ios_sdk

class LSP3ProfileDetailsViewModel {
    private let lsp3ProfileRepository: LSP3ProfileRepository
    
    let progress = BehaviorRelay<Bool>(value: false)
    let errorEvent = PublishRelay<AppError>()
    let lsp3Profile = BehaviorRelay<LSP3Profile?>(value: nil)
    
    private var lsp3ProfileHash = ""
    
    init(_ lsp3ProfileRepository: LSP3ProfileRepository) {
        self.lsp3ProfileRepository = lsp3ProfileRepository
    }
    
    func load(_ lsp3ProfileHash: String) {
        self.lsp3ProfileHash = lsp3ProfileHash
        guard let profile = lsp3ProfileRepository.get(id: lsp3ProfileHash) else {
            onError(.simpleError(msg: "Failed to find profile with hash: \(lsp3ProfileHash)"))
            return
        }
        
        lsp3Profile.accept(profile)
    }
    
    private func onError(_ error: AppError) {
        progress.accept(false)
        NSLog(error.description())
        errorEvent.accept(error)
    }
}
