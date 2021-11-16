//
//  Web3KeyStore.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import web3swift
import CryptoSwift

class Web3KeyStore {
    
    private static let KeyPairFileLocation = "KeyPairFileLocatio1n"
    
    #warning("There must be no static/default passwords used to generate EC key pair. `DefaultPassword` is only for demo purposes.")
    internal static let DefaultPassword = "1234nedfs9efn23r!23123"
    
    private let keyValueStore: KeyValueStore
    
    var credentials: EthereumKeystoreV3? = nil
    
    init(keyValueStore: KeyValueStore) {
        self.keyValueStore = keyValueStore
    }
    
    func loadOrGenerateDefaultKeyPair() -> Result<EthereumKeystoreV3, AppError> {
        let keyPairFileLocation = getKeyPairFileLocation()

        if let fileLocation = try? keyPairFileLocation.get(),
           !fileLocation.isEmpty,
           FileManager.default.fileExists(atPath: getValidPath().appendingPathComponent(fileLocation).path) {
            return loadKeyPairWithDefaultPassword()
        } else {
            let _ = keyValueStore.delete(key: Web3KeyStore.KeyPairFileLocation)
            return generateKeyPairWithDefaultPassword()
        }
        
    }
    
    private func getKeyPairFileLocation() -> Result<String, AppError> {
        return .success(try! keyValueStore.get(key: Web3KeyStore.KeyPairFileLocation) ?? "")
    }
    
    private func loadKeyPairWithDefaultPassword() -> Result<EthereumKeystoreV3, AppError> {
        do {
            let filename = try getKeyPairFileLocation().get()
            return loadKeyPair(password: Web3KeyStore.DefaultPassword, filename: filename)
        } catch {
            return .failure(AppError.simpleException(error: error))
        }
    }
    
    private func generateKeyPairWithDefaultPassword() -> Result<EthereumKeystoreV3, AppError> {
        return generateKeyPair(password: Web3KeyStore.DefaultPassword)
    }
    
    private func generateKeyPair(password: String) -> Result<EthereumKeystoreV3, AppError> {
        do {
            let keystore = try EthereumKeystoreV3(password: password)!
            let keyData = try JSONEncoder().encode(keystore.keystoreParams)
            
            NSLog("Generating device from with pass \(password)")
            let path = getValidPath()
            let filename = filenameForWallet(keystore)
            
            let _ = try! keyValueStore.save(key: Web3KeyStore.KeyPairFileLocation, value: filename)
            
            let filePath = path.appendingPathComponent(filename)
            try! keyData.write(to: filePath, options: .completeFileProtection)
            
            NSLog("File created: \(filename) and credentials loaded: \(keystore.getAddress()!)")
            
            credentials = keystore
            
            return .success(keystore)
        } catch {
            return .failure(AppError.simpleException(error: error))
        }
    }
        
    private func loadKeyPair(
        password: String,
        filename: String
    ) -> Result<EthereumKeystoreV3, AppError> {
        do {
            #if DEBUG
            NSLog("Loading device from \(filename) with pass \(password)")
            #endif
            
            let path = getValidPath()
            let data = try Data(contentsOf: path.appendingPathComponent(filename))
            let keystoreParams = try JSONDecoder().decode(KeystoreParamsV3.self, from: data)
            
            NSLog("Credentials loaded: \(keystoreParams)")
            
            credentials = EthereumKeystoreV3(keystoreParams)
            
            return .success(credentials!)
        } catch {
            return .failure(AppError.simpleException(error: error))
        }
    }
    
    private func filenameForWallet(_ wallet: EthereumKeystoreV3) -> String {
        return "\(Date().withFormat(DateFormat.DD_MM_yyyy_HH_mm_ss_file_system_safe))_\(wallet.getAddress()!.address).json"
    }
    
    private func getValidPath() -> URL {
        // Return different URL if simulator is used
        if TARGET_OS_SIMULATOR != 0 {
            let url = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first!
            
            if !FileManager.default.fileExists(atPath: url.path) {
                try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            
            return url
        }


        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        if !FileManager.default.fileExists(atPath: url.path) {
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }

        return url
    }
}
