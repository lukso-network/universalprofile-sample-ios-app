//
//  IdenticonSelectorViewModel.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import universalprofile_ios_sdk
import SwiftUI

class IdenticonSelectorViewModel: ObservableObject {
    
    @Published private(set) var identiconsData = [Identicon]()
    @Published private(set) var currentPageIdenticons = [Identicon]()
    
    @Published private(set) var selectedIdenticon: Identicon!
    @Published private var currentPage = 0
    
    private let pageLimit = 10
    private let identiconPerPageCount = 9
    
    var selectedAddress: String {
        return selectedIdenticon?.address ?? ""
    }
    
    @Published var create2Configuration: Create2ConfigurationResponse? = nil {
        didSet {
            if create2Configuration != nil {
                identiconsData = []
                generateNewIdenticons()
            }
        }
    }
    
    private let create2ConfigurationRepository: Create2ConfigurationRepository
    
    init(_ create2ConfigurationRepository: Create2ConfigurationRepository) {
        self.create2ConfigurationRepository = create2ConfigurationRepository
        
        requestCreate2Configuration()
    }
    
    private func requestCreate2Configuration() {
        if #available(iOS 15, *) {
            requestCreate2ConfigAsync()
        } else {
            create2ConfigurationRepository.getCreate2Configuration { result in
                switch result {
                    case .success(let response):
                        self.create2Configuration = response
                    case .failure(let error):
                        self.onError("Failed to get CREATE2 configuration used to generate addresses", error: error)
                }
            }
        }
    }
    
    @available(iOS 15, *)
    private func requestCreate2ConfigAsync() {
        Task {
            do {
                let config = try await create2ConfigurationRepository.getCreate2Configuration()
                create2Configuration = config
            } catch {
                onError("Failed to get CREATE2 configuration used to generate addresses", error: error)
            }
        }
    }
    
    private func onError(_ topicMsg: String? = nil, error: Error) {
        var msg: String = "Reason: \(error.localizedDescription)"
        if let topicMsg = topicMsg {
            msg = "\(topicMsg). \(msg)"
        }
        fatalError(msg)
    }
    
    /**
     Generates new Identicons and appends them to the `identiconsData` array.
     */
    private func generateNewIdenticons() {
        let identicons = generateNewIdenticons(count: identiconPerPageCount)
        appendNewIdenticons(identicons)
    }
    
    private func appendNewIdenticons(_ identicons: [Identicon]) {
        identiconsData.append(contentsOf: identicons)
        if selectedIdenticon == nil {
            selectedIdenticon = identiconsData.first
            selectedIdenticon.isSelected = true
        }
        if currentPageIdenticons.isEmpty {
            currentPageIdenticons = identicons
        }
    }
    
    private func generateNewIdenticons(count: Int) -> [Identicon] {
        if count <= 0 {
            return []
        }
        return (0..<count).map { _ in Identicon(create2Configuration!.create2FactoryAddress,
                                                byteCode: create2Configuration!.universalProfileContractBytecode) }
    }
    
    func select(_ identicon: Identicon) {
        guard selectedIdenticon != identicon else {
            return
        }
        
        identicon.isSelected = true
        selectedIdenticon.isSelected = false
        selectedIdenticon = identicon
    }
    
    func getNextPage() {
        currentPageIdenticons = getPage(currentPage + 1)
    }
    
    func getPreviousPage() {
        currentPageIdenticons = getPage(currentPage - 1)
    }
    
    func getPage(_ page: Int) -> [Identicon] {
        guard canCreateIdenticons() else {
            return []
        }
        
        if page == currentPage && !currentPageIdenticons.isEmpty {
            return currentPageIdenticons
        }
        
        var shiftPages = false
        let clampedPage: Int
        if page < 0 {
            clampedPage = 0
        } else if page >= pageLimit {
            shiftPages = true
            clampedPage = pageLimit
        } else {
            clampedPage = page
        }
        
        if shiftPages {
            // If the limit is exceeded
            // 0) generate new identicons;
            // 1) drop first `identiconsPerPageCount` number of identicons;
            // 2) make sure selected identicon is always in the array
            // 3) append new `identiconsPerPageCount` number of identicons
            //    (happens outside of this if-statement).
            
            generateNewIdenticons()
            
            var _identicons = Array(identiconsData.dropFirst(identiconPerPageCount))
            if !_identicons.contains(selectedIdenticon) {
                _identicons[0] = selectedIdenticon
            }
            
            identiconsData = _identicons
        }
        
        let start = min(max(0, clampedPage * identiconPerPageCount),
                        (pageLimit - 1) * identiconPerPageCount)
        let end = min(max((clampedPage + 1) * identiconPerPageCount, identiconPerPageCount),
                      pageLimit * identiconPerPageCount)
        
        while end > identiconsData.count {
            generateNewIdenticons()
        }
        
        currentPage = clampedPage
        
        var subrange = [Identicon]()
        for i in start..<end {
            subrange.append(identiconsData[i])
        }
        currentPageIdenticons = subrange
        return subrange
    }
    
    func hasPrevious() -> Bool {
        return currentPage > 0
    }
    
    func canCreateIdenticons() -> Bool {
        return create2Configuration != nil
    }
}
