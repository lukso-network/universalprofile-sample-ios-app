//
//  LSP3ProfileListViewModel.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import SwiftUI
import universalprofile_ios_sdk

class LSP3ProfileListViewModel: ObservableObject {
    private let lsp3ProfileRepository: LSP3ProfileRepository
    
    @Published private (set) var profiles: [IdentifiableLSP3Profile] = []
    @Published private (set) var showAlert = false
    @Published private (set) var alertMessage: String? = nil
    @Published private (set) var showProgress = false
    
    init(_ lsp3ProfileRepository: LSP3ProfileRepository) {
        self.lsp3ProfileRepository = lsp3ProfileRepository
    }
    
    func load() {
        switch lsp3ProfileRepository.list() {
            case .success(let profiles):
                self.profiles = profiles
            case .failure(let error):
                self.onError(error)
        }
    }
    
    private func onError(_ error: AppError) {
        alertMessage = error.description()
        showAlert = true
    }
    
    func searchProfile(_ lsp3Id: String) {
        showProgress = true
        lsp3ProfileRepository.search(lsp3Id: lsp3Id) { result in
            switch result {
                case .success(let profile):
                    var profiles = self.profiles
                    profiles.append(profile)
                    self.profiles = profiles
                case .failure(let error):
                    self.onError(error)
            }
            self.showProgress = false
        }
    }
}

