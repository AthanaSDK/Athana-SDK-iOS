//
//  GameCenterAccountServiceProvider.swift
//  AthanaAdapters
//
//  Created by CWJoy on 10/3/2026.
//

import AthanaCore
import GameKit

public class GameCenterAccountServiceProvider: AccountServiceProvider {
    
    public let target: AthanaCore.SignInType = .APPLE_GAME_CENTER
    
    public let name: String = "GameCenterAccountServiceProvider"
    
    private var signInResult: ((Result<Bool, (any Error)>) -> Void)? = nil
    
    /// 用户未登录 Game Center
    private var notAuthenticated: Bool = false
    
    public init() {
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return false
    }
    
    public func initialize(config: (any AthanaCore.ServiceProviderConfig)?) {
        LoggingService.shared.debug(tag: AccountService.TAG, message: "[\(name)] initialized")
    }
    
    public func currentUser() async -> AthanaCore.AccountInfo? {
        if (!GKLocalPlayer.local.isAuthenticated) {
            return nil
        }
        if #available(iOS 13.5, *) {
            do {
                return try await buildAccountInfo()
            } catch {
                LoggingService.shared.warn(tag: AccountService.TAG, message: "[\(name)] Failed to build account info.", error: error)
                ErrorRecordService.shared.recordError(error)
                return nil
            }
        } else {
            LoggingService.shared.warn(tag: AccountService.TAG, message: "[\(name)] This feature is only compatible with iOS 13.5 and above.")
        }
        return nil
    }
    
    public func signInWith(_ signInType: String) async throws -> AthanaCore.AccountInfo {
        if #available(iOS 13.5, *) {
            if GKLocalPlayer.local.isAuthenticated {
                notAuthenticated = false
                return try await buildAccountInfo()
            }
            
            if notAuthenticated {
                throw AthanaError(.SDK_REQUEST_ERROR, message: "Please sign-in to Game Center [System Settings -> Game Center]")
            }
            
            let result: Bool = try await withCheckedThrowingContinuation { continuation in
                signInResult = { result in
                    self.destroyCallback()
                    switch result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        if let gkError = error as? GKError {
                            switch gkError.code {
                            case .notAuthenticated:
                                self.notAuthenticated = true
                                break
                            default:
                                break
                            }
                        }
                        continuation.resume(throwing: error)
                    }
                }
                setAuthenticateHandler()
            }
            return try await buildAccountInfo()
        } else {
            throw AthanaError(.SDK_REQUEST_ERROR, message: "This feature is only compatible with iOS 13.5 and above.")
        }
    }
    
    public func signOut() async throws {
        
    }
    
    private func setAuthenticateHandler() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let controller = viewController {
                guard let topViewController = UIApplication.shared.topViewController() else {
                    self.signInResult?(.failure(AthanaError(.SDK_REQUEST_ERROR, message: "[\(self.name)] Cannot access Top UIViewController.")))
                    return
                }
                controller.present(topViewController, animated: true)
                return
            }
            if let err = error {
                self.signInResult?(.failure(err))
                return
            }
            
            self.signInResult?(.success(true))
        }
    }
    
    private func destroyCallback() {
        GKLocalPlayer.local.authenticateHandler = nil
        signInResult = nil
    }
    
    @available(iOS 13.5, *)
    private func buildAccountInfo(needSignature: Bool = false) async throws -> AccountInfo {
        let teamPlayerID: String = GKLocalPlayer.local.teamPlayerID
        let nickname = GKLocalPlayer.local.alias
        
        var extra: [String: Any] = [
            // 未成年，应当屏蔽未成年人禁止访问的内容
            "isUnderage": GKLocalPlayer.local.isUnderage,
            // 限制多人游戏
            "isMultiplayerGamingRestricted": GKLocalPlayer.local.isMultiplayerGamingRestricted
        ]
        
        if #available(iOS 14.0, *) {
            // 限制游戏内通讯功能
            extra["isPersonalizedCommunicationRestricted"] = GKLocalPlayer.local.isPersonalizedCommunicationRestricted
        }
        
        if needSignature {
            let signatureResult = try await GKLocalPlayer.local.fetchItemsForIdentityVerificationSignature()
            let publicKeyURL: URL = signatureResult.0
            let signature: Data = signatureResult.1
            let salt: Data = signatureResult.2
            let timestamp: UInt64 = signatureResult.3
            
            let payload: [String: String] = [
                "publicKeyURL" : publicKeyURL.absoluteString,
                "timestamp" : String(timestamp)
            ]
            
            let payloadJSONData = try defaultJsonEncoder.encode(payload)
            let triAccessTokenJSON = base64String(data: salt) + "." + base64String(data: payloadJSONData) + "." + base64String(data: signature)
            
            return AccountInfo(
                userId: 0,
                accessToken: "",
                signInType: target.name,
                triOpenId: teamPlayerID,
                triAccessToken: needSignature ? triAccessTokenJSON : nil,
                triNonce: nil,
                userProperty: UserProperty(nickname: nickname, email: nil, phone: nil, avatarUrl: nil, extra: nil)
            )
        } else {
            return AccountInfo(
                userId: 0,
                accessToken: "",
                signInType: target.name,
                triOpenId: teamPlayerID,
                triAccessToken: nil,
                triNonce: nil,
                userProperty: UserProperty(nickname: nickname, email: nil, phone: nil, avatarUrl: nil, extra: nil)
            )
        }
        
    }
    
}
