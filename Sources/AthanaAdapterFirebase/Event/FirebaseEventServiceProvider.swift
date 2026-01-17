import Foundation
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
        Analytics.logEvent(event.key, parameters: event.params)
    }

    /// 批量记录事件
    /// - Parameter events: 
    public func logEvents(_ events: [GamesEvent]) {
        events.forEach { logEvent($0) }
    }

}
