import Foundation
import StoreKit
import AthanaCore
import FirebaseAnalytics

public class FirebaseEventServiceProvider: EventServiceProvider {
    
    public let name: String = "FirebaseEventServiceProvider"
    
    public init() { }
    
    /// 初始化
    public func initialize(config: (any ServiceProviderConfig)?) {
        FirebaseInitial.shared.initialize()
        LoggingService.shared.debug(tag: EventService.TAG, message: "[\(name)] initialized")
        
#if DEBUG
        Analytics.setUserProperty("Developer", forName: "user_type")
#endif
    }
    
    /// 设置用户ID
    /// - Parameter userId:
    public func setUserId(_ userId: Int) {
        if (userId > 0) {
            Analytics.setUserID(String(userId))
        }
    }
    
    /// 设置游戏用户Id
    /// - Parameter customUserId: 游戏用户ID
    public func setCustomUserId(_ customUserId: Int) {
        if (customUserId > 0) {
            Analytics.setUserProperty(String(customUserId), forName: "custom_user_id")
        }
    }
    
    /// 设置设备ID
    /// - Parameter deviceId:
    public func setDeviceId(_ deviceId: String) {
        Analytics.setUserProperty(deviceId, forName: "deviceId")
    }
    
    /// 获取会话
    /// - Returns:
    public func getSession() -> GamesSession? {
        return nil
    }
    
    /// 记录事件
    /// - Parameter event:
    public func logEvent(_ event: GamesEvent) {
        let sendTargets = event.sendTargets
        if let s = sendTargets,
           s.contains("firebase") == false {
            return
        }
        
        var paramDist: [String : Any] = [:]
        if let p = event.params, p.isEmpty == false {
            p.forEach { k, v in
                if k == "items", let items = v as? [IapProduct] {
                    paramDist[AnalyticsParameterItems] = items.map {
                        [
                            AnalyticsParameterItemID : $0.key,
                            AnalyticsParameterItemName : $0.title,
                            AnalyticsParameterPrice : $0.rawPrice,
                            AnalyticsParameterQuantity : 1
                        ]
                    }
                } else {
                    if let stringV = v as? String {
                        paramDist[k] = stringV
                    } else if let intV = v as? Int {
                        paramDist[k] = intV
                    } else if let doubleV = v as? Double {
                        paramDist[k] = doubleV
                    } else if let floatV = v as? Float {
                        paramDist[k] = floatV
                    } else if let boolV = v as? Bool {
                        paramDist[k] = boolV
                    } else if let dateV = v as? Date {
                        paramDist[k] = dateV
                    }
                }
            }
        }
        
        Analytics.logEvent(event.key, parameters: paramDist)
    }
    
    /// 批量记录事件
    /// - Parameter events:
    public func logEvents(_ events: [GamesEvent]) {
        events.forEach { logEvent($0) }
    }
    
    @available(iOS 15.0, *)
    public func logTransaction(_ transaction: Transaction) {
        if #available(iOS 16.0, *) {
            if (transaction.environment == .production) {
                Analytics.logTransaction(transaction)
            }
        } else {
            Analytics.logTransaction(transaction)
        }
    }
    
    @available(iOS 15.0, *)
    public func logRefund(_ transaction: Transaction) {
        if #available(iOS 16.0, *) {
            if (transaction.environment == .production) {
                Analytics.logEvent(AnalyticsEventRefund, parameters: [
                    AnalyticsParameterTransactionID: transaction.id,
                    AnalyticsParameterCurrency: transaction.currency?.identifier,
                    AnalyticsParameterValue: transaction.price,
                    AnalyticsParameterItemID: transaction.productID
                ])
            }
        } else {
            Analytics.logEvent(AnalyticsEventRefund, parameters: [
                AnalyticsParameterTransactionID: transaction.id,
                AnalyticsParameterCurrency: transaction.currencyCode,
                AnalyticsParameterValue: transaction.price,
                AnalyticsParameterItemID: transaction.productID
            ])
        }
    }
}
