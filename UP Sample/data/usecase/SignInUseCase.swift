//
//  SignInUseCase.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import web3swift
import CryptoSwift
import universalprofile_ios_sdk
import Alamofire

class SignInUsecase {
    private let ipService: UPIpService
    private let web3KeyStore: Web3KeyStore
    private let passwordStore: PasswordStore
    private let authStore: AuthStore
    
    init(ipService: UPIpService, web3KeyStore: Web3KeyStore, passwordStore: PasswordStore, authStore: AuthStore) {
        self.ipService = ipService
        self.web3KeyStore = web3KeyStore
        self.passwordStore = passwordStore
        self.authStore = authStore
    }
    
    /*
     sign in process different steps to receive a token from the identity provider
     
     0. get a ec key
     1. sends a random message to server and a erc725Address of the service
     2. verifies the return and creates a token request
     3. call token endpoint of ip
     4. verifies the token (unnecessary step)
     */
    func signIn(_ responseHandler: @escaping (Result<UPUserIdentity, AppError>) -> Void) {
        switch web3KeyStore.loadOrGenerateDefaultKeyPair() {
            case .success(let ethereumKeystore):
                /// FIXME: - MUST NOT USE A STATIC CONSTANT PASSWORD!
                self.startSignInProcessWithKey(ethereumKeystore, Web3KeyStore.DefaultPassword) { response in
                    responseHandler(response)
                }
            case .failure(let appError):
                responseHandler(.failure(appError))
        }
    }
    
    private func startSignInProcessWithKey(_ keystore: EthereumKeystoreV3,
                                           _ keystorePassword: String,
                                           _ responseHandler: @escaping (Result<UPUserIdentity, AppError>) -> Void) {
        let body = UPRequestBodySignMessage(erc725Address: "",
                                          messageBase64: createRandomMessage())
        ipService.signMessage(body: body) { result in
            switch result {
                case .success(let response):
                    let verificationResult = verifyIPSignatureAndCreateTokenRequest(response: response,
                                                           keystore: keystore,
                                                           keystorePassword: keystorePassword)

                    switch verificationResult {
                        case .success(let requestBodyToken):
                            self.getAndValidateToken(requestBodyToken, responseHandler)
                        case .failure(let appError):
                            responseHandler(.failure(appError))
                    }
                case .failure(let error):
                    responseHandler(.failure(.simpleException(error: error)))

            }
        }
    }
    
    private func getAndValidateToken(_ requestBodyToken: UPRequestBodyToken, _ responseHandler: @escaping (Result<UPUserIdentity, AppError>) -> Void) {
        
        func validateToken(_ token: UPToken) {
            let body = UPTokenRequestBody(token: token.token)
            
            var requestUrl = URL(string: "http://35.246.184.226")!
            requestUrl.appendPathComponent("api/v1/auth/token/verify")
            
            let headers: HTTPHeaders = [.contentType("application/json"), .userAgent(UserAgent.header)]
            AF.request(requestUrl, method: .post,
                       parameters: body,
                       encoder: JSONParameterEncoder(),
                       headers: headers)
                .responseString { response in
                    switch response.result {
                        case .success(let json):
                            do {
                                let trimmedJson = json.trimmingCharacters(in: .whitespacesAndNewlines)
                                let userIdentity = try JSONDecoder().decode(UPUserIdentity.self, from: Data(trimmedJson.bytes))
                                responseHandler(.success(userIdentity))
                            } catch {
                                responseHandler(.failure(.simpleException(error: error)))
                            }
                        case .failure(let error):
                            responseHandler(.failure(.simpleException(error: error)))
                    }
                    
                }
            // ipService.verify fails due to bad JSON format
//            self.ipService.verify(body: UPTokenRequestBody(token: token.token)) { verificationResult in
//                switch verificationResult {
//                    case .success(let userIdentity):
//                        responseHandler(.success(userIdentity))
//                    case .failure(let error):
//                        responseHandler(.appError(.simpleException(error: error)))
//                }
//            }
        }
        
        
        ipService.token(body: requestBodyToken) { tokenResult in
            switch tokenResult {
                case .success(let token):
                    let _ = self.authStore.setToken(token)
                    validateToken(token)
                case .failure(let error):
                    responseHandler(.failure(.simpleException(error: error)))
            }
        }
    }
    
    private func createRandomMessage() -> String {
        return "asdlasda23asfknasd" // not really random but for now good enough
    }
}


func verifyIPSignatureAndCreateTokenRequest(
    response: UPResponseBodySignMessage,
    keystore: EthereumKeystoreV3,
    keystorePassword: String
) -> Result<UPRequestBodyToken, AppError> {
    let verificationResult = UPIpUtils.verifyIPSignatureAndCreateTokenRequest(response: response,
                                                                            keystore: keystore,
                                                                            keystorePassword: keystorePassword)
    
    switch verificationResult {
        case .success(let requestBodyToken):
            return .success(requestBodyToken)
        case .failure(let error):
            return .failure(.simpleException(error: error))
    }
}
