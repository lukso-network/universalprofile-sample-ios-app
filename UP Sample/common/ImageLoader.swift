//
//  ImageLoader.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import Combine
import universalprofile_ios_sdk

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data?, Never>()
    var data: Data? = nil {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString: String) {
        let rawUrl: String
        let ipfsConfig = DependencyInjectorContainer.resolve(IPFSServiceEnvironment.self)!
        if urlString.starts(with: "ipfs://") {
            rawUrl = urlString.replacingOccurrences(of: "ipfs://", with: ipfsConfig.gatewayUrl())
        } else {
            rawUrl = urlString
        }
        
        guard let url = URL(string: rawUrl) else {
            data = nil
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}
