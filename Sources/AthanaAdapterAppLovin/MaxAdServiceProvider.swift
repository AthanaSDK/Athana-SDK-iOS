//
//  ADMax.swift
//  ADMax
//
//  Created by CWJoy on 2025/4/23.
//

import Foundation
import AthanaCore
import AppLovinSDK

/// AppLovin MAX 广告服务提供商
public class MaxAdServiceProvider: AdServiceProvider {
    
    public let name: String = "MaxAdServiceProvider"
    
    private lazy var maxSdk: ALSdk = ALSdk.shared()
    private var maxConfig: ALSdkInitializationConfiguration? = nil
    private var initialized = false
    private var clientListener: AdServiceListener? = nil
    
    private var userId: String? = nil
    private var customUserId: String? = nil

    private var appOpenAd: MAAppOpenAd? = nil
    private var interstitialAd: MAInterstitialAd? = nil
    private var rewardedAd: MARewardedAd? = nil
    
    private lazy var appOpenListener: CommonAdListener = CommonAdListener(
        type: MAAdFormat.appOpen.toType(),
        reload: { self.appOpenAd?.load() }
    )
    private lazy var interstitialListener: CommonAdListener = CommonAdListener(
        type: MAAdFormat.interstitial.toType(),
        reload: { self.interstitialAd?.load() }
    )
    private lazy var rewardedListener: RewardedAdListener = RewardedAdListener(
        reload: { self.rewardedAd?.load() }
    )
    
    public init() { }
    
    /// 初始化
    /// - Parameter privacyGrant: 是否同意隐私政策
    public func initialize(config: (any ServiceProviderConfig)?) {
        if (initialized) {
            LoggingService.shared.info(tag: AdService.TAG, message: "[\(name)] Already initialized")
            return
        }
        if (!(config is MaxAdServiceProviderConfig)) {
            LoggingService.shared.warn(tag: AdService.TAG, message: "[\(name)] Invalid config for MaxAdServiceProvider")
            return
        }
        let providreConfig = config as! MaxAdServiceProviderConfig

        let key = providreConfig.devKey
        if (key.isEmpty)  {
            LoggingService.shared.warn(tag: AdService.TAG, message: "[\(name)] SDK Key is empty")
            return
        }
        maxConfig = ALSdkInitializationConfiguration(sdkKey: key)  { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }
        if (maxConfig == nil) {
            LoggingService.shared.warn(tag: AdService.TAG, message: "[\(name)] Failed to create Max Sdk Config")
            return
        }
        initialized = true
        let ppUrl = providreConfig.privacyPolicyUrl ?? ""
        let tosUrl = providreConfig.termsOfServiceUrl ?? ""
        if (ppUrl.isEmpty == false && tosUrl.isEmpty == false) {
            let tpFlowSettings = maxSdk.settings.termsAndPrivacyPolicyFlowSettings
            tpFlowSettings.isEnabled = true
            tpFlowSettings.privacyPolicyURL = URL(string: ppUrl)
            tpFlowSettings.termsOfServiceURL = URL(string: tosUrl)
        }
        if (providreConfig.debug == true) {
            maxSdk.settings.isVerboseLoggingEnabled = true
        }
        maxSdk.settings.userIdentifier = PlatformService.shared.dataRepository().getDeviceId()

        maxSdk.initialize(with: maxConfig!) { sdkConfig in
            LoggingService.shared.info(tag: AdService.TAG, message: "[\(self.name)] Started")
        }
        LoggingService.shared.debug(tag: AdService.TAG, message: "[\(name)] initialized")
    }

    public func setPrivacyGrant(granted: Bool) {
        ALPrivacySettings.setHasUserConsent(granted)
    }
    
    /// 设置用户Id
    /// - Parameter userId: 用户ID
    public func setUserId(userId: String) {
        self.userId = userId
    }

    /// 设置游戏用户Id
    /// - Parameter customUserId: 游戏用户ID
    public func setCustomUserId(customUserId: String) {
        self.customUserId = customUserId
    }

    /// 设置额外参数
    /// - Parameter params: 参数字典
    public func setExtraParam(params: [String: String]) {
        maxSdk.settings.extraParameters.merge(params) { (_, new) in new }
    }

    /// 设置广告状态监听器
    /// - Parameter listener:
    public func setAdListener(listener: AdServiceListener?) {
        clientListener = listener
    }

    /// 加载启动广告
    /// - Parameter adUnitId: 广告位ID
    /// - Returns: 操作结果
    public func loadAppOpenAd(adUnitId: String) -> Bool {
        if (!initialized) {
            return false
        }
        appOpenListener.listener = clientListener
        appOpenAd = MAAppOpenAd(adUnitIdentifier: adUnitId)
        appOpenAd?.delegate = appOpenListener
        
        appOpenAd?.load()
        return true
    }
    
    public func isReadyAppOpenAd(adUnitId: String) -> Bool {
        if (!initialized) {
            return false
        }
        return appOpenAd?.isReady ?? false
    }
    
    /// 展示激励广告
    /// - Parameters:
    ///   - adUnitId: 广告位ID
    ///   - placement: 展示位置
    /// - Returns: 操作结果
    public func showAppOpenAd(adUnitId: String, placement: String?) -> Bool {
        if (!initialized) {
            return false
        }
        if (appOpenAd?.isReady == true) {
            appOpenAd?.show(forPlacement: placement, customData: userId)
            return true
        } else {
            return false
        }
    }
    
    /// 加载激励广告
    /// - Parameter adUnitId: 广告位ID
    /// - Returns: 操作结果
    public func loadRewardedAd(adUnitId: String) -> Bool {
        if (!initialized) {
            return false
        }
        rewardedListener.listener = clientListener
        rewardedAd = MARewardedAd.shared(withAdUnitIdentifier: adUnitId)
        rewardedAd?.delegate = rewardedListener
        
        rewardedAd?.load()
        return true
    }

    public func isReadyRewardedAd(adUnitId: String) -> Bool {
        if (!initialized) {
            return false
        }
        return rewardedAd?.isReady ?? false
    }
    
    /// 展示激励广告
    /// - Parameters:
    ///   - adUnitId: 广告位ID
    ///   - placement: 展示位置
    /// - Returns: 操作结果
    public func showRewardedAd(adUnitId: String, placement: String?) -> Bool {
        if (!initialized) {
            return false
        }
        if (rewardedAd?.isReady == true) {
            rewardedAd?.show(forPlacement: placement, customData: userId)
            return true
        } else {
            return false
        }
    }

    /// 加载插屏广告
    /// - Parameter adUnitId: 广告位ID
    /// - Returns: 操作结果
    public func loadInterstitialAd(adUnitId: String) -> Bool {
        if (!initialized) {
            return false
        }
        interstitialListener.listener = clientListener
        interstitialAd = MAInterstitialAd(adUnitIdentifier: adUnitId)
        interstitialAd?.delegate = interstitialListener
        
        interstitialAd?.load()
        return true
    }

    public func isReadyInterstitialAd(adUnitId: String) -> Bool {
        if (!initialized) {
            return false
        }
        return interstitialAd?.isReady ?? false
    }
    
    /// 展示插屏广告
    /// - Parameters:
    ///   - adUnitId: 广告位ID
    ///   - placement: 展示位置
    /// - Returns: 操作结果
    public func showInterstitialAd(adUnitId: String, placement: String?) -> Bool {
        if (!initialized) {
            return false
        }
        if (interstitialAd?.isReady == true) {
            interstitialAd?.show(forPlacement: placement, customData: userId)
            return true
        } else {
            return false
        }
    }
 
    public func createBanner(adUnitId: String,
                             placement: String?,
                             size: AdSize,
                             alignment: AdAlignment) -> (any AdBanner)? {
        if (!initialized) {
            return nil
        }
        do {
            let banner = MaxADBanner(adUnitId: adUnitId, placement: placement, size: size, alignment: alignment)
            banner.listener = clientListener
            try banner.show()
            return banner
        } catch {
            LoggingService.shared.warn(tag: AdService.TAG, message: "Failed to create banner", error: error)
            return nil
        }
    }
}
