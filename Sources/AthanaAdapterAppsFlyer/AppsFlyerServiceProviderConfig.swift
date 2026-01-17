import Foundation
import AthanaCore

/// AppsFlyer GCD 回调代理协议
@objc public protocol GCDDelegate {
    
    /// 获得归因数据回调
    @objc func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any])

    /// 获得归因数据失败回调
    @objc func onConversionDataFail(_ error: any Error)
    
}

/// AppsFlyer UDL 回调代理协议
@objc public protocol UDLDelegate {
    
    /// 深度链接解析回调
    @objc func didResolveDeepLink(_ result: [String: Any]?, _ error: (any Error)?)
    
}

/// AppsFlyer 服务提供者配置
@objc public class AppsFlyerServiceProviderConfig: NSObject, ServiceProviderConfig {
    public let providerName: String = "AppsFlyerConversionServiceProvider"
    
    /// AppsFlyer 开发者密钥
    public let devKey: String

    /// AppsFlyer 应用程序 ID
    public let appId: String
    
    /// GCD 回调代理
    let gcdDelegate: GCDDelegate?

    /// UDL 回调代理
    let udlDelegate: UDLDelegate?

    /// 是否启用调试模式
    /// 默认为 false
    public let debug: Bool
    
    /// 构造函数
    ///
    /// 初始化 AppsFlyer 服务提供者配置
    /// - Parameters:
    ///   - devKey: AppsFlyer 开发者密钥
    ///   - appId: AppsFlyer 应用程序 ID
    ///   - debug: 是否启用调试模式，默认为 false
    ///   - gcdDelegate: GCD 回调代理
    ///   - udlDelegate: UDL 回调代理
    @objc public init(devKey: String, appId: String, debug: Bool = false, gcdDelegate: GCDDelegate? = nil, udlDelegate: UDLDelegate? = nil) {
        self.devKey = devKey
        self.appId = appId
        self.debug = debug
        self.gcdDelegate = gcdDelegate
        self.udlDelegate = udlDelegate
    }
}
