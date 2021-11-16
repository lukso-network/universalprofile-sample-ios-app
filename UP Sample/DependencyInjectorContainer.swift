//
//  DependencyInjectorContainer.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import web3swift
import Swinject
import universalprofile_ios_sdk

class DependencyInjectorContainer {
    
    static let INSTANCE = DependencyInjectorContainer()
    
    let container = Container()
    
    private let web3Instance = web3(provider: Web3HttpProvider(URL(string: Lukso.RPCTestNetwork)!)!)
    
    private init() {
        container.register(KeyValueStore.self) { _ in DefaultKeyValueStore() }
        container.register(LuksoRelayServiceEnvironment.self) { _ in DefaultLuksoRelayServiceEnvironment() }
        container.register(UPIpServiceEnvironment.self) { _ in TestIpServiceEnvornment() }
        container.register(IPFSServiceEnvironment.self) { _ in TestIPFSServiceEnvironment() }
        container.register(UPIpService.self) { r in
            UPIpServiceImpl(environment: r.resolve(UPIpServiceEnvironment.self)!)
        }
        
        container.register(ResourceServiceEnvironment.self) { _ in TestResourceServiceEnvironment() }
        container.register(AuthStore.self) { r in AuthStore.init(keyValueStore: r.resolve(KeyValueStore.self)!)}
        container.register(SampleResourceService.self) { r in
            SampleResourceServiceImpl(environment: r.resolve(ResourceServiceEnvironment.self)!, authStore: r.resolve(AuthStore.self)!)
        }
        
        container.register(Web3KeyStore.self) { r in
            Web3KeyStore(keyValueStore: r.resolve(KeyValueStore.self)!)
        }
        container.register(PasswordStore.self) { r in
            PasswordStore(keyValueStore: r.resolve(KeyValueStore.self)!)
        }
        container.register(IdentityProviderBaseFlowViewModel.self) { r in
            let web3Ks: Web3KeyStore = r.resolve(Web3KeyStore.self)!
            let signInUseCase = SignInUsecase(ipService: r.resolve(UPIpService.self)!,
                                              web3KeyStore: web3Ks,
                                              passwordStore: r.resolve(PasswordStore.self)!,
                                              authStore: r.resolve(AuthStore.self)!)
            
            return IdentityProviderBaseFlowViewModel(signInUsecase: signInUseCase,
                                     sampleResourceService: r.resolve(SampleResourceService.self)!,
                                     web3KeyStore: web3Ks)
        }
        container.register(web3.self) { _ in
            self.web3Instance
        }
        container.register(LuksoRelayService.self) { r in
            LuksoRelayServiceImpl(r.resolve(LuksoRelayServiceEnvironment.self)!)
        }
        container.register(LSP3ProfileProvider.self) { r in
            let environment = r.resolve(IPFSServiceEnvironment.self)!
            return LSP3ProfileProviderImpl(IPFSConfig(environment: environment), r.resolve(web3.self)!)
        }
        container.register(LSP3ProfileRepository.self) { r in
            LSP3ProfileRepository(r.resolve(LSP3ProfileProvider.self)!,
                                  r.resolve(KeyValueStore.self)!)
        }
        container.register(LSP3ProfileListViewModel.self) { r in
            LSP3ProfileListViewModel(r.resolve(LSP3ProfileRepository.self)!)
        }
        container.register(LSP3CreateProfileViewModel.self) { r in
            LSP3CreateProfileViewModel(r.resolve(LSP3ProfileRepository.self)!,
                                       UniversalProfileRepository(r.resolve(LuksoRelayService.self)!,
                                                                  r.resolve(KeyValueStore.self)!),
                                       r.resolve(Web3KeyStore.self)!)
        }
        container.register(LSP3ProfileSearchViewModel.self) { r in
            LSP3ProfileSearchViewModel(r.resolve(LSP3ProfileRepository.self)!)
        }
    }
    
    
    public static func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        return INSTANCE.container.resolve(serviceType)
    }
    
    public static func resolve<Service>(_ serviceType: Service.Type, name: String?) -> Service? {
        return INSTANCE.container.resolve(serviceType, name: name)
    }
}

