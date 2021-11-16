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
import RxSwift
import web3swift
import Foundation
import OrderedCollections
import universalprofile_ios_sdk

class LSP3CreateProfileViewModel : ObservableObject {
    
    let progressMessage = BehaviorRelay<String>(value: "")
    let progress = BehaviorRelay<Bool>(value: false)
    let errorEvent = PublishRelay<AppError>()
    let identifiableLsp3Profile = BehaviorRelay<ConsumableEvent<IdentifiableLSP3Profile>?>(value: nil)
    let universalProfile = BehaviorRelay<ConsumableEvent<DeployLSP3ProfileResponse>?>(value: nil)
    let taskStatus = BehaviorRelay<ConsumableEvent<LSP3ProfileDeployTaskResponse>?>(value: nil)
    
    @Published private(set) var tags = OrderedSet<LSP3ProfileTag>()
    @Published private(set) var links = OrderedSet<LSP3ProfileLink>()
    private(set) var createLsp3RequestBuilder = LSP3CreateProfileRequest.Builder()
    
    private let lsp3ProfileRepository: LSP3ProfileRepository
    private let universalProfileRepository: UniversalProfileRepository
    private let web3KeyStore: Web3KeyStore
    
    init(_ lsp3ProfileRepository: LSP3ProfileRepository,
         _ universalProfileRepository: UniversalProfileRepository,
         _ web3KeyStore: Web3KeyStore) {
        self.lsp3ProfileRepository = lsp3ProfileRepository
        self.universalProfileRepository = universalProfileRepository
        self.web3KeyStore = web3KeyStore
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
                    self.progressMessage.accept("Profile created.\nDeploying smart contracts...")
                    self.identifiableLsp3Profile.accept(.init(profile))
                    self.deploySmartContracts(profile)
                case .failure(let error):
                    self.onError(error)
            }
        }
    }
    
    private func deploySmartContracts(_ profile: IdentifiableLSP3Profile) {
        guard !profile.id.isEmpty else {
            onError(.simpleError(msg: "Cannot deploy LSP3 profile with empty CID"))
            return
        }
        
        let ethereumKeystore: EthereumKeystoreV3 = try! web3KeyStore.loadOrGenerateDefaultKeyPair().get()
        
        let request = DeployLSP3ProfileRequest(profileJsonUrl: "ipfs://\(profile.id)",
                                               // You may want to look for safer options of
                                               // generating salt 32 bytes length if that makes sense.
                                               salt: randomNotSecureSalt(),
                                               erc725ControllerKey: ethereumKeystore.getAddress()!.address,
                                               // TODO: pass in email from user instead of placeholder
                                               email: "hello@lukso.io")
        
//        universalProfileRepository.uploadProfile(body: request) { deployTaskStatusResponse in
//            let msg = self.progressMessage.value.replacingOccurrences(of: "...", with: "")
//            self.progressMessage.accept("\(msg).")
//            self.taskStatus.accept(ConsumableEvent(deployTaskStatusResponse))
//        } responseHandler: { result in
//            switch result {
//                case .success((let deployUpResponse, let taskStatus)):
//                    // TODO: save deployUpResponse (aka profile info)
//                    self.taskStatus.accept(ConsumableEvent(taskStatus))
//                    self.universalProfile.accept(ConsumableEvent(deployUpResponse))
//                case .failure(let error):
//                    self.onError(.simpleException(error: error))
//            }
//        }

    }
}


