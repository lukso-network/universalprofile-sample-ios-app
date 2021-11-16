//
//  LSP3ProfileDetailsViewModel.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import universalprofile_ios_sdk

class LSP3ProfileDetailsViewModel : ObservableObject {
    private let lsp3ProfileRepository: LSP3ProfileRepository
    
    @Published private(set) var progress = false
    @Published private(set) var errorEvent: ConsumableEvent<Error> = .empty()
    @Published private(set) var rawProfileJson: String? = nil
    @Published private(set) var profile: IdentifiableLSP3Profile? = nil {
        didSet {
            if let profile = profile {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                guard let data = try? encoder.encode(profile) else { return }
                
                self.rawProfileJson = String(data: data, encoding: .utf8)
            }
        }
    }
    
    private var lsp3ProfileHash = ""
    
    init(_ lsp3ProfileRepository: LSP3ProfileRepository) {
        self.lsp3ProfileRepository = lsp3ProfileRepository
    }
    
    func load(_ lsp3ProfileHash: String) {
        progress = true
        self.lsp3ProfileHash = lsp3ProfileHash
        guard let profile = lsp3ProfileRepository.get(id: lsp3ProfileHash) else {
            search(lsp3ProfileHash)
            return
        }
        
        self.profile = profile
        progress = false
    }
    
    private func search(_ lsp3ProfileHash: String) {
        progress = true
        lsp3ProfileRepository.search(lsp3Id: lsp3ProfileHash) { result in
            switch result {
                case .success(let lsp3Profile):
                    self.profile = lsp3Profile
                case .failure(let error):
                    self.onError(error)
            }
            self.progress = false
        }
    }
    
    private func onError(_ error: AppError) {
        progress = false
        NSLog(error.description())
        errorEvent = .init(error)
    }
}
