//
//  FirebaseErrorRecordService.swift
//  ConversionFirebase
//
//  Created by CWJoy on 18/8/2025.
//

import Foundation
import AthanaCore
import FirebaseCrashlytics

public class FirebaseErrorRecordServiceProvider: ErrorRecordServiceProvider {

    public let name: String = "FirebaseErrorRecordServiceProvider"

    public init() { }
    
    /// 初始化
    public func initialize(config: (any ServiceProviderConfig)?) {
        FirebaseInitial.shared.initialize()
        LoggingService.shared.debug(tag: ErrorRecordService.TAG, message: "[\(name)] initialized")
    }

    /// 设置用户ID
    public func setUserId(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }

    /// 设置游戏用户ID
    public func setCustomUserId(customUserId: String) {
        Crashlytics.crashlytics().setCustomValue(customUserId, forKey: "custom_user_id")
    }

    public func setCustomKey(key: String, value: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    /// 记录异常信息
    public func recordError(error: any Error) {
        Crashlytics.crashlytics().record(error: error)
    }

    /// 记录异常信息
    public func recordError(error: any Error, extra: [String: String]?) {
        if (extra != nil) {
            Crashlytics.crashlytics().setCustomKeysAndValues(extra!)
        }
        Crashlytics.crashlytics().record(error: error)
    }

}
