import AthanaCore
import AuthenticationServices

public class AppleAccountServiceProvider: AccountServiceProvider {
    
    private lazy var appleIDProvider = ASAuthorizationAppleIDProvider()
    
    public let name: String = "AppleAccountServiceProvider"

    public let target: SignInType = .APPLE
    
    public init() { }
    
    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        
    }
    
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        return false
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
            
            // 验证有效性
            let userId = info!.triOpenId
            
            let state = try await appleIDProvider.credentialState(forUserID: userId!)
            switch state {
            case .authorized:
                break
            case .revoked, .notFound:
                AccountRepository.shared.clean()
                return nil
            default:
                break
            }
            
            return info
        } catch {
            LoggingService.shared.warn(tag: AccountService.TAG, message: "[\(name)] Failed to currentUser.",  error: error)
            return nil
        }
    }
    
    @MainActor
    public func signInWith(_ signInType: String, extra: Dictionary<String, Any>? = nil) async throws -> AccountInfo {
        let controller = AppleSignInController()
        let result = try await withCheckedThrowingContinuation { continuation in
            controller.performRequests { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                    break
                case .failure(let error):
                    continuation.resume(throwing: error)
                    break
                }
            }
        }
        return result
    }
    
    public func signOut() async throws {
    }


}

class AppleSignInController: NSObject, ASAuthorizationControllerDelegate {
    
    private var _callback: ((Result<AccountInfo, Error>) -> Void)? = nil
    
    public func performRequests(_ callback: @escaping (Result<AccountInfo, Error>) -> Void) {
        self._callback = callback
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.nonce = createUUID()
        
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    public func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let info = AccountInfo(
                userId: 0,
                accessToken: "",
                signInType: SignInType.APPLE.name,
                triOpenId: appleIDCredential.user,
                triAccessToken: String(data: appleIDCredential.identityToken!, encoding: .utf8),
                userProperty: UserProperty(
                    nickname: appleIDCredential.fullName?.givenName,
                    email: appleIDCredential.email,
                    phone: nil,
                    avatarUrl: nil,
                    extra: nil
                )
            )
            _callback?(.success(info))
            break
            
        default:
            _callback?(.failure(AthanaError(.SDK_REQUEST_ERROR, message: "Unknown Credentials")))
            break
        }
    }

    public func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if (error is ASAuthorizationError) {
            let aError = error as? ASAuthorizationError
            if aError != nil {
                if (aError!.code == .canceled) {
                    _callback?(.failure(AthanaError(.SDK_USER_CANCELLED, message: "Cancelled")))
                    return
                }
            }
        }
        _callback?(.failure(error))
    }
}
