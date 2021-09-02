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
    
    private init() {
        container.register(KeyValueStore.self) { _ in DefaultKeyValueStore() }
        container.register(UPIpServiceEnvornment.self) { _ in TestIpServiceEnvornment() }
        container.register(UPIpService.self) { r in
            UPIpServiceImpl(environment: r.resolve(UPIpServiceEnvornment.self)!)
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
        container.register(BaseFlowViewModel.self) { r in
            let web3Ks: Web3KeyStore = r.resolve(Web3KeyStore.self)!
            let signInUseCase = SignInUsecase(ipService: r.resolve(UPIpService.self)!,
                          web3KeyStore: web3Ks,
                          passwordStore: r.resolve(PasswordStore.self)!,
                          authStore: r.resolve(AuthStore.self)!)
            
            return BaseFlowViewModel(signInUsecase: signInUseCase,
                                     sampleResourceService: r.resolve(SampleResourceService.self)!,
                                     web3KeyStore: web3Ks)
        }
    }
    
    
    public static func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        return INSTANCE.container.resolve(serviceType)
    }
    
    public static func resolve<Service>(_ serviceType: Service.Type, name: String?) -> Service? {
        return INSTANCE.container.resolve(serviceType, name: name)
    }
}
