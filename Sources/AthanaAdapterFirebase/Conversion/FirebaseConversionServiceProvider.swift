//
//  ConversionFirebase.swift
//  ConversionFirebase
//
//  Created by CWJoy on 2025/6/5.
//

import Foundation
import AthanaCore
import FirebaseAnalytics

public class FirebaseConversionServiceProvider: ConversionServiceProvider {

    public let name: String = "FirebaseConversionServiceProvider"
    
    private var serviceInfoMap: Dictionary<String, Any> = [:]
    
    public init() { }
    
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        
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
        FirebaseInitial.shared.initialize()
        LoggingService.shared.debug(tag: ConversionService.TAG, message: "[\(name)] initialized")
    }
    
    public func start() {
        
    }
    
    public func setUserId(userId: String) {
        Analytics.setUserID(userId)
    }
    
    public func setCustomUserId(customUserId: String) {
        Analytics.setUserProperty(customUserId, forName: "custom_user_id")
    }

    public func getServiceInfo() -> [String : Any] {
        let instanceId = Analytics.appInstanceID()
        if (instanceId != nil) {
            serviceInfoMap["app_instance_id"] = instanceId
        }
        return serviceInfoMap
    }

}
