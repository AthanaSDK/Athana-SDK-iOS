import AppTrackingTransparency
import AthanaCore
import FBSDKLoginKit
import FBSDKCoreKit

public class FacebookAccountServiceProvider: AccountServiceProvider {
    
    public let name: String = "FacebookAccountServiceProvider"
    
    public let target: SignInType = .FACEBOOK

    private lazy var loginManager: LoginManager = LoginManager()
    
    public init() { }
    
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        FacebookInitial.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        return ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[
                UIApplication.OpenURLOptionsKey.sourceApplication
            ] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    public func initialize(config: (any ServiceProviderConfig)?) {
        LoggingService.shared.debug(tag: AccountService.TAG, message: "[\(name)] initialized")
    }
    
    public func currentUser() async -> AccountInfo? {
        do {
            let info = try AccountRepository.shared.getAccountInfo()
            if (info == nil) {
                return nil
            }
            let token = AccessToken.current
            if (token == nil || token?.isExpired == true) {
                AccountRepository.shared.clean()
                return nil
            }
            return info
        } catch {
            LoggingService.shared.warn(tag: AccountService.TAG, message: "[\(name)] Failed to currentUser.", error: error)
            return nil
        }
    }
    
    @MainActor
    public func signInWith(_ signInType: String) async throws -> AccountInfo {
        var limited: Bool
        if #available(iOS 14.0, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            limited = (status != .authorized)
            if #unavailable(iOS 17.1) {
                Settings.shared.isAdvertiserTrackingEnabled = !limited
            }
        } else {
            limited = false
        }
        
        let configuration: LoginConfiguration?
        let nonce: String?
        if !limited {
            nonce = nil
            configuration = LoginConfiguration(
                permissions: ["email", "public_profile"],
                tracking: FBSDKLoginKit.LoginTracking.enabled,
            )
        } else {
            nonce = String(Int(Date().timeIntervalSince1970))
            configuration = LoginConfiguration(
                permissions: ["email", "public_profile"],
                tracking: FBSDKLoginKit.LoginTracking.limited,
                nonce: nonce!
            )
        }
        
        if (configuration == nil) {
            throw AthanaError(.SDK_REQUEST_ERROR, message: "Cannot create LoginConfiguration")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.loginManager.logIn(configuration: configuration) { result in
                switch result {
                case .failed(let error):
                    continuation.resume(throwing: error)
                    break
                case .cancelled:
                    continuation.resume(throwing: AthanaError(.SDK_USER_CANCELLED, message: "Cancelled"))
                    break
                case .success(granted: let granted, declined: let declined, token: let token):
                    continuation.resume(returning: self.getAccountInfoBy(
                        accessToken: token,
                        nonce: nonce
                    ))
                    break
                }
            }
        }
    }
    
    public func signOut() async throws {
        self.loginManager.logOut()
        Profile.current = nil
    }
    
    private func getAccountInfoBy(
        accessToken: AccessToken?,
        nonce: String? = nil
    ) -> AccountInfo {
        if nonce != nil {
            let token = AuthenticationToken.current
            let openId = Profile.current?.userID
            return AccountInfo(
                userId: 0,
                accessToken: "",
                signInType: SignInType.FACEBOOK.name,
                triOpenId: openId,
                triAccessToken: token?.tokenString,
                triNonce: nonce,
                userProperty: UserProperty(
                    nickname: Profile.current?.name,
                    email: Profile.current?.email,
                    phone: nil,
                    avatarUrl: Profile.current?.imageURL?.absoluteString,
                    extra: nil
                )
            )
        } else {
            return AccountInfo(
                userId: 0,
                accessToken: "",
                signInType: SignInType.FACEBOOK.name,
                triOpenId: accessToken?.userID,
                triAccessToken: accessToken?.tokenString,
                triNonce: nil,
                userProperty: UserProperty(
                    nickname: Profile.current?.name,
                    email: Profile.current?.email,
                    phone: nil,
                    avatarUrl: Profile.current?.imageURL?.absoluteString,
                    extra: nil
                )
            )
        }
        
    }
}
