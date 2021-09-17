//
//  LSP3ProfileListViewModel.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import RxSwift
import RxRelay
import universalprofile_ios_sdk

class LSP3ProfileListViewModel {
    private let lsp3ProfileRepository: LSP3ProfileRepository
    
    let progress = BehaviorRelay<Bool>(value: false)
    let errorEvent = PublishRelay<AppError>()
    let lsp3Profiles = BehaviorRelay<[LSP3Profile]>(value: [])
    
    init(_ lsp3ProfileRepository: LSP3ProfileRepository) {
        self.lsp3ProfileRepository = lsp3ProfileRepository
    }
    
    func load() {
        switch lsp3ProfileRepository.list() {
            case .success(let profiles):
                self.lsp3Profiles.accept(profiles)
            case .failure(let error):
                self.onError(error)
        }
    }
    
    private func onError(_ error: AppError) {
        progress.accept(false)
        NSLog(error.description())
        errorEvent.accept(error)
    }
    
    func searchProfile(_ lsp3Id: String) {
        lsp3ProfileRepository.search(lsp3Id: lsp3Id) { result in
            switch result {
                case .success(let profile):
                    var profiles = self.lsp3Profiles.value
                    profiles.append(profile)
                    self.lsp3Profiles.accept(profiles)
                case .failure(let error):
                    self.onError(error)
            }
        }
    }
}

