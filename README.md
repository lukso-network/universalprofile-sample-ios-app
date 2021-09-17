# universalprofile-sample-ios-app

Xcode 12 and Carthage
----

In the repository you can find a script that handles issues with Carthage and Xcode 12.
Script is called `carthage_update.sh`. It should be enought to execute it to get your dependencies updated and get them ready for iOS app.

If you decide to update Carthage dependencies manually your attempt could fail with a similar error:

```
...
.../Alamofire have the same architectures (arm64) and can't be in the same fat output file

Building universal frameworks with common architectures is not possible. The device and simulator slices for "Alamofire" both build for: arm64
Rebuild with --use-xcframeworks to create an xcframework bundle instead.
```

Script `carthage_update.sh` based on this solution for Carthage and Xcode 12: https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md
You can use the solution down the link manually.

-----------

Here will be a collection of mappings between `web3j` (left) and `web3swift` (right):
| web3j | web3swift | Note |
| ----- | --------- | ---- |
| `org.web3j.crypto.Sign.SignatureData` | `SECP256K1.UnmarshaledSignature` | - |
| `org.web3j.crypto.Sign.signedMessageToKey` | `SECP256K1.recoverPublicKey` | - |
| `org.web3j.crypto.Sign.signMessage` | `SECP256K1.signForRecovery` | Message without `"Ethereum Signed Message"` prefix. |
| `org.web3j.crypto.Sign.signPrefixedMessage` |`Web3Signer.signPersonalMessage`| Message with `"Ethereum Signed Message"` prefix. |
| `org.web3j.crypto.Sign.recoverFromSignature` | `SECP256K1.recoverPublicKey` | - |
| `org.web3j.crypto.WalletUtils.generateLightNewWalletFile` | No specific utility function | File should be generated manually |
| `org.web3j.crypto.WalletUtils.loadCredentials` | No specific utility function | File should be read and parsed manually |
| `org.web3j.crypto.WalletFile` | `KeystoreParamsV3` | Also see `EthereumKeystoreV3` which is a wrapper for `KeystoreParamsV3` |
| `org.web3j.crypto.ECKeyPair` | No specific class | Use `SECP256K1.generatePrivateKey()` and `SECP256K1.privateToPublic(privateKey: Data)` |
| `org.web3j.crypto.Credentials` | `EthereumKeystoreV3` | Use `func getAddress() -> EthereumAddress?` or `var addresses: [EthereumAddress]?` to get information about addresses. `func UNSAFE_getPrivateKeyData(...) -> Data` can be used to return private key |
