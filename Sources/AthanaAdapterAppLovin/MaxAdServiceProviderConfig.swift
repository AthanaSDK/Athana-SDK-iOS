import AthanaCore
import Foundation

/// AppLovin MAX 广告服务提供商配置
@objc public class MaxAdServiceProviderConfig: NSObject, AdServiceProviderConfig {

    public let providerName: String = "MaxAdServiceProvider"

    public let parameters: [String: Any]? = [:]

    @objc public let devKey: String
    @objc public let privacyPolicyUrl: String?
    @objc public let termsOfServiceUrl: String?
    @objc public let preloadAds: [Int: String]
    @objc public let autoLoadNext: Bool
    @objc public let debug: Bool

    /// 初始化配置
    /// - Parameters:
    ///   - devKey: SDK Key
    ///   - privacyPolicyUrl: 隐私政策 URL
    ///   - termsOfServiceUrl: 服务条款 URL
    ///   - preloadAds: 预加载广告位字典，键为广告类型（见 AdType），值为广告位 ID
    ///   - autoLoadNext: 是否自动加载下一个广告
    ///   - debug: 是否启用调试模式
    @objc public init(
        devKey: String,
        privacyPolicyUrl: String? = nil,
        termsOfServiceUrl: String? = nil,
        preloadAds: [Int: String]? = nil,
        autoLoadNext: Bool = true,
        debug: Bool = false
    ) {
        self.devKey = devKey
        self.privacyPolicyUrl = privacyPolicyUrl
        self.termsOfServiceUrl = termsOfServiceUrl
        self.preloadAds = preloadAds ?? [:]
        self.autoLoadNext = autoLoadNext
        self.debug = debug
    }
}
