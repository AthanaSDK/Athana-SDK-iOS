//
//  LoggingService.swift
//  Athana
//
//  Created by CWJoy on 14/8/2025.
//

import Foundation
import AthanaCore
import FirebaseCrashlytics

/// 日志服务
public class FirebaseLoggingServiceProvider: LoggingServiceProvider {

    public let name: String = "FirebaseLoggingServiceProvider"

    public init() { }
    
    /// 初始化
    public func initialize(config: (any ServiceProviderConfig)?) {
        FirebaseInitial.shared.initialize()
    }

    /// 设置用户ID
    /// - Parameter userId: 
    public func setUserId(_ userId: Int) {
        Crashlytics.crashlytics().setUserID(String(userId))
    }

    /// 设置游戏用户Id
    /// - Parameter customUserId: 游戏用户ID
    public func setCustomUserId(_ customUserId: Int) {
        Crashlytics.crashlytics().setCustomValue(String(customUserId), forKey: "custom_user_id")
    }

    /// 日志 - 等级: DEBUG
    public func debug(tag: String, message: String) {
        record(tag: tag, message: message)
    }

    /// 日志 - 等级: VERBOSE
    public func verbose(tag: String, message: String) {
        record(tag: tag, message: message)
    }

    /// 日志 - 等级: INFO
    public func info(tag: String, message: String) {
        record(tag: tag, message: message)
    }

    /// 日志 - 等级: WARN
    public func warn(tag: String, message: String, error: Error?) {
        record(tag: tag, message: message)
    }

    /// 日志 - 等级: ERROR
    public func error(tag: String, message: String, error: Error?) {
        record(tag: tag, message: message)
    }

    private func record(tag: String, message: String) {
        Crashlytics.crashlytics().log("[\(tag)] \(message)")
    }
}
