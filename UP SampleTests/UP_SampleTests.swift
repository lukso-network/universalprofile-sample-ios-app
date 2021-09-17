//
//  UP_SampleTests.swift
//  UP SampleTests
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import XCTest
import web3swift
@testable import UP_Sample

class UP_SampleTests: XCTestCase {

    func testExample() throws {
        let w3ks = Web3KeyStore(keyValueStore: DefaultKeyValueStore())
        let result = w3ks.loadOrGenerateDefaultKeyPair()
        NSLog(String(describing: result.right!))
    }
    
    func testSignatureCreationAndConversion() throws {
        let privateKey = SECP256K1.generatePrivateKey()!
        let publicKey = SECP256K1.privateToPublic(privateKey: privateKey)!
        let publicKeyString = publicKey.toHexString()
        
        let msg = "ec1dd684eb036981a1ebe8221bb67cb6f04bcec510a96299f5a0a051cdce4d971d949d158415ee998ffef9a00c24120aa6da526b3121753392ca1ca73c3125fe01"
        let msgData = Data(msg.bytes)
        
        let keystorePassword = "keystorePassword"
        let ks = try! EthereumKeystoreV3(privateKey: privateKey, password: keystorePassword)!
        let signatureData = try Web3Signer.signPersonalMessage(msgData, keystore: ks, account: ks.addresses!.first!, password: keystorePassword)!
        
        let hashedMessage = Web3.Utils.hashPersonalMessage(msgData)!
        let recoveredPublicKey = SECP256K1.recoverPublicKey(hash: hashedMessage, signature: signatureData)!
        
        if recoveredPublicKey.toHexString() != publicKeyString {
            fatalError("Failed to recover public key")
        }
    }

}
