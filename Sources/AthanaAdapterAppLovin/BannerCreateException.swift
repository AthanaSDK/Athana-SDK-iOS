import Foundation

///
///  横幅广告创建异常
///
///  Created by CWJoy on 30/7/2025.
///
@objc public class BannerCreateException: NSObject, Error, @unchecked Sendable {
    
    @objc public let message: String
    
    @objc public init(_ message: String) {
        self.message = message
    }
    
}
