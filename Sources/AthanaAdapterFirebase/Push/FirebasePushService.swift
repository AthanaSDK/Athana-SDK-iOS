import AthanaCore
import FirebaseMessaging
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public class FirebasePushServiceProvider: NSObject, PushServiceProvider, MessagingDelegate {
    
    public let name: String = "FirebasePushServiceProvider"
    
    private lazy var msgInstance = Messaging.messaging()
    
    public override init() { }
    
    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        msgInstance.delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    /// 初始化
    public func initialize(config: (any ServiceProviderConfig)?) {
        FirebaseInitial.shared.initialize()
        LoggingService.shared.debug(tag: PushService.TAG, message: "[\(name)] initialized")
    }
    
    public func getPushToken() async -> String? {
        do {
            return try await msgInstance.token()
        } catch {
            LoggingService.shared.debug(tag: PushService.TAG, message: "[\(name)] Failed to get token")
            ErrorRecordService.shared.recordError(error)
            return nil
        }
    }
    
}

// 系统通知代理
extension FirebasePushServiceProvider: UNUserNotificationCenterDelegate {
    
    @MainActor
    public func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult {
        msgInstance.appDidReceiveMessage(userInfo)
        Messaging.serviceExtension().exportDeliveryMetricsToBigQuery(withMessageInfo: userInfo)
        return UIBackgroundFetchResult.newData
    }
    
    // 前台接收
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        LoggingService.shared.debug(tag: PushService.TAG, message: "Received Message: \(notification.request.content.userInfo)")
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.sound])
        }
    }
    
    // 点击通知响应
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        LoggingService.shared.debug(tag: PushService.TAG, message: "User Click Notification: \(userInfo)")
        completionHandler()
    }
}
