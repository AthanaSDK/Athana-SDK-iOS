//
//  ConversionAppsFlyer.swift
//  ConversionAppsFlyer
//
//  Created by CWJoy on 2025/4/23.
//

import Foundation
import AthanaCore
import AppsFlyerLib
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public class AppsFlyerConversionServiceProvider: ConversionServiceProvider {
    
    public let name: String = "AppsFlyerConversionServiceProvider"
    
    private lazy var afSdk: AppsFlyerLib = AppsFlyerLib.shared()
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
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return false
    }
    
    public func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) {
        AppsFlyerLib.shared().continue(
            userActivity,
            restorationHandler: nil
        )
    }
    
    public func initialize(config: (any ServiceProviderConfig)?) {
        if !(config is AppsFlyerServiceProviderConfig) {
            LoggingService.shared.warn(tag: ConversionService.TAG, message: "[\(name)] Invalid config")
            return
        }
        let providerConfig = config as! AppsFlyerServiceProviderConfig

        let sdkKey = providerConfig.devKey
        if (sdkKey.isEmpty) {
            LoggingService.shared.warn(tag: ConversionService.TAG, message: "[\(name)] Missing devKey on the config", error: nil)
            return
        }
        
        let afGCDDelegate: AFGCDDelegate = AFGCDDelegate(serviceInfoMap: serviceInfoMap)
        let afDLDelegate: AFDLDelegate = AFDLDelegate(serviceInfoMap: serviceInfoMap)
        
        afSdk.isDebug = providerConfig.debug
        afSdk.appsFlyerDevKey = sdkKey
        afSdk.appleAppID = providerConfig.appId
        afSdk.deepLinkDelegate = afDLDelegate
        afSdk.delegate = afGCDDelegate
        afSdk.waitForATTUserAuthorization(timeoutInterval: 60)
        LoggingService.shared.debug(tag: ConversionService.TAG, message: "[\(name)] initialized")
    }
    
    public func start() {
        afSdk.start { (dictionary, error) in
            if (error != nil) {
                // 启动失败
                LoggingService.shared.warn(tag: ConversionService.TAG, message: "[\(self.name)] Failed to start AppsFlyer", error: error)
            } else {
                LoggingService.shared.debug(tag: ConversionService.TAG, message: "[\(self.name)] Started")
            }
        }
    }
    
    public func setUserId(userId: String) {
        afSdk.customerUserID = userId
    }
    
    public func setCustomUserId(customUserId: String) {
        
    }
    
    public func getServiceInfo() -> [String : Any] {
        let afUid = afSdk.getAppsFlyerUID()
        if (!afUid.isEmpty) {
            serviceInfoMap["appsflyer_id"] = afUid
        }
        return serviceInfoMap
    }
    
}

internal class AFGCDDelegate: NSObject, AppsFlyerLibDelegate {
    
    private let gcdDelegate: GCDDelegate?
    private var serviceInfoMap: Dictionary<String, Any> = [:]
    
    init(serviceInfoMap: Dictionary<String, Any>, gcdDelegate: GCDDelegate? = nil) {
        self.serviceInfoMap = serviceInfoMap
        self.gcdDelegate = gcdDelegate
    }
    
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        let data = conversionInfo.reduce(into: [String: Any]()) { result, tuple in
            if let key = tuple.key as? String {
                result[key] = tuple.value
            }
        }
        serviceInfoMap.merge(data) { (_, new) in new }
        gcdDelegate?.onConversionDataSuccess(conversionInfo)
    }
    
    public func onConversionDataFail(_ error: any Error) {
        LoggingService.shared.warn(tag: ConversionService.TAG, message: "[AFGCDDelegate] Failed to get GCD from AppsFlyer", error: error)
        gcdDelegate?.onConversionDataFail(error)
    }
    
}

internal class AFDLDelegate: NSObject, DeepLinkDelegate {
    
    private let udlDelegate: UDLDelegate?
    private var serviceInfoMap: Dictionary<String, Any> = [:]
    
    init(serviceInfoMap: Dictionary<String, Any>, udlDelegate: UDLDelegate? = nil) {
        self.serviceInfoMap = serviceInfoMap
        self.udlDelegate = udlDelegate
    }
    
    public func didResolveDeepLink(_ result: DeepLinkResult) {
        
        switch result.status {
        case .notFound:
            LoggingService.shared.info(tag: ConversionService.TAG, message: "[AFDLDelegate] Deep link not found")
            udlDelegate?.didResolveDeepLink(nil, nil)
            return
        case .failure:
            LoggingService.shared.warn(tag: ConversionService.TAG, message: "[AFDLDelegate] DL Error", error: result.error)
            udlDelegate?.didResolveDeepLink(nil, result.error)
            return
        default:
            break
        }
        
        guard let deepLinkObj: DeepLink = result.deepLink else {
            LoggingService.shared.warn(tag: ConversionService.TAG, message: "[AFDLDelegate] Deep link object is empty", error: nil)
            udlDelegate?.didResolveDeepLink(nil, nil)
            return
        }
        
        LoggingService.shared.info(tag: ConversionService.TAG, message: "[AFDLDelegate] Deep link found")
        let data = deepLinkObj.clickEvent.reduce(into: [String: Any]()) { result, tuple in
            result[tuple.key] = tuple.value
        }
        udlDelegate?.didResolveDeepLink(data, nil)
        serviceInfoMap.merge(data) { (_, new) in new }
    }
    
}
