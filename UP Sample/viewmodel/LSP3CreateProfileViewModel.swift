//
//  LSP3CreateProfileViewModel.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import UIKit
import SwiftUI
import RxRelay
import Foundation
import OrderedCollections
import universalprofile_ios_sdk

class LSP3CreateProfileViewModel : ObservableObject {
    
    let progress = BehaviorRelay<Bool>(value: false)
    let errorEvent = PublishRelay<AppError>()
    let lsp3Profile = BehaviorRelay<LSP3Profile?>(value: nil)
    
    @Published private(set) var tags = OrderedSet<LSP3ProfileTag>()
    @Published private(set) var links = OrderedSet<LSP3ProfileLink>()
    private(set) var createLsp3RequestBuilder = LSP3CreateProfileRequest.Builder()
    private let lsp3ProfileRepository: LSP3ProfileRepository
    
    init(_ lsp3ProfileRepository: LSP3ProfileRepository) {
        self.lsp3ProfileRepository = lsp3ProfileRepository
    }
    
    func appendNewLink(_ title: String, _ url: String) {
        links.append(LSP3ProfileLink(title: title, url: url))
    }
    
    func deleteLink(_ link: LSP3ProfileLink) -> Bool {
        let size = tags.count
        links.removeAll {
            return $0.id == link.id
        }
        return size - 1 == tags.count
    }
    
    func appendNewTag(_ tag: String) {
        tags.append(LSP3ProfileTag(tag: tag))
    }
    
    func deleteTag(_ tag: LSP3ProfileTag) -> Bool {
        let size = tags.count
        tags.removeAll {
            return $0.id == tag.id
        }
        return size - 1 == tags.count
    }
    
    func getProfileUIImage() -> UIImage? {
        return createLsp3RequestBuilder.profileImageOriginal
    }
    
    func getBackdropUIImage() -> UIImage? {
        return createLsp3RequestBuilder.backdropImageOriginal
    }
    
    func setProfileImage(_ imageData: [UIImagePickerController.InfoKey: Any]) {
        createLsp3RequestBuilder.profileImageUrl = (imageData[.imageURL] as! URL).absoluteString
        createLsp3RequestBuilder.profileImageOriginal = imageData[.originalImage] as? UIImage
    }
    
    func setBackdropImage(_ imageData: [UIImagePickerController.InfoKey: Any]) {
        createLsp3RequestBuilder.backdropImageUrl = (imageData[.imageURL] as! URL).absoluteString
        createLsp3RequestBuilder.backdropImageOriginal = imageData[.originalImage] as? UIImage
    }
    
    private func onError(_ error: AppError) {
        progress.accept(false)
        NSLog(error.description())
        errorEvent.accept(error)
    }
    
    func create() {
        guard !progress.value else {
            return
        }
        
        progress.accept(true)
        
        createLsp3RequestBuilder.links = links.elements
        createLsp3RequestBuilder.tags = tags.map { $0.tag }
        
        lsp3ProfileRepository.create(createLsp3RequestBuilder.build()) { result in
            switch result {
                case .success(let profile):
                    self.progress.accept(false)
                    self.lsp3Profile.accept(profile)
                case .failure(let error):
                    self.onError(error)
            }
        }
    }
}

class LSP3ProfileTag: Identifiable, Hashable {
    
    static func == (lhs: LSP3ProfileTag, rhs: LSP3ProfileTag) -> Bool {
        return lhs.tag == rhs.tag
    }
    
    let id = UUID()
    let tag: String
    
    init(tag: String) {
        self.tag = tag
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tag.hashValue &* 13)
    }
}
