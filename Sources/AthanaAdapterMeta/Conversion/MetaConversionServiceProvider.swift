//
//  ConversionMeta.swift
//  ConversionMeta
//
//  Created by CWJoy on 2025/7/28.
//

import Foundation
import AthanaCore
import FBSDKCoreKit

public class MetaConversionServiceProvider: ConversionServiceProvider {

    public let name: String = "MetaConversionServiceProvider"
    
    private var serviceInfoMap: Dictionary<String, Any> = [:]
    
    public init() { }
    
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        FacebookInitial.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        return false
    }
    
    public func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) {
        
    }
    
    public func initialize(config: (any ServiceProviderConfig)?) {
        LoggingService.shared.debug(tag: ConversionService.TAG, message: "[\(name)] initialized")
    }
    
    public func start() {
        AppLinkUtility.fetchDeferredAppLink{ (url, error) in
            if let error = error{
                print("Error %a", error)
            }
            if let url = url {
                self.serviceInfoMap["deeplink"] = url
            }
        }
    }
    
    public func setUserId(userId: String) {
        
    }

    public func setCustomUserId(customUserId: String) {
        
    }
    
    public func getServiceInfo() -> [String : Any] {
        return serviceInfoMap
    }

}
