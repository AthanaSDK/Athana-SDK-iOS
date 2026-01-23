import AthanaCore
import GoogleSignIn
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum GIDSignInErrorCode: NSInteger {
    case unknown = -1
    case keychain = -2
    case hasNoAuthInKeychain = -4
    case canceled = -5
    case EMM = -6
    case scopesAlreadyGranted = -8
    case mismatchWithCurrentUser = -9
}

public class GoogleAccountServiceProvider: AccountServiceProvider {

    public let name: String = "GoogleAccountServiceProvider"

    public let target: SignInType = .GOOGLE
    
    public init() { }

    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        
    }
    
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    public func initialize(config: (any ServiceProviderConfig)?) {
        LoggingService.shared.debug(tag: AccountService.TAG, message: "[\(name)] initialized")
    }

    public func currentUser() async -> AccountInfo? {
        let googleUser = GIDSignIn.sharedInstance.currentUser
        let profile = googleUser?.profile
        return AccountInfo(
            userId: 0,
            accessToken: "",
            signInType: SignInType.GOOGLE.name,
            triOpenId: ((googleUser?.userID?.hashValue) != nil) == true ? googleUser?.userID! : "",
            triAccessToken: googleUser?.idToken?.tokenString,
            userProperty: UserProperty(
                nickname: profile?.name, email: profile?.email, phone: nil,
                avatarUrl: profile?.imageURL(withDimension: 200)?.absoluteString, extra: nil)
        )
        //        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
        //            if error != nil || user == nil {
        //                // Show the app's signed-out state.
        //
        //            } else {
        //                // Show the app's signed-in state.
        //
        //            }
        //        }
        //        return nil
    }

    @MainActor
    public func signInWith(_ signInType: String) async throws -> AccountInfo {

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                guard let viewController: UIViewController = UIApplication.shared.topViewController() else {
                    continuation.resume(throwing: AthanaError(.SDK_REQUEST_ERROR, message: "Cannot get this UIViewController"))
                    return
                }
                GIDSignIn.sharedInstance.signIn(withPresenting: viewController) {
                    signInResult, error in
                    guard let result = signInResult else {
                        // Inspect error
                        let errCode = (error! as NSError).code
                        if errCode == GIDSignInErrorCode.canceled.rawValue {
                            continuation.resume(throwing: AthanaError(.SDK_USER_CANCELLED, message: "Cancelled"))
                        } else {
                            continuation.resume(throwing: error!)
                        }
                        return
                    }
                    // If sign in succeeded, display the app's main content View.

                    //                    result.serverAuthCode
                    let googleUser = result.user
                    let profile = googleUser.profile

                    let account = AccountInfo(
                        userId: 0,
                        accessToken: "",
                        signInType: SignInType.GOOGLE.name,
                        triOpenId: ((googleUser.userID?.hashValue) != nil) == true
                            ? googleUser.userID! : "",
                        triAccessToken: googleUser.idToken?.tokenString,
                        userProperty: UserProperty(
                            nickname: profile?.name, email: profile?.email, phone: nil,
                            avatarUrl: profile?.imageURL(withDimension: 200)?.absoluteString,
                            extra: nil)
                    )

                    continuation.resume(returning: account)
                }
            }
        }
    }

    public func signOut() async throws {
        GIDSignIn.sharedInstance.signOut()
    }

}
