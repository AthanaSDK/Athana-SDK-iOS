// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Athana-SDK-iOS",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "AthanaCore", targets: ["AthanaCoreWrapper"]),
        .library(name: "AthanaSDK", targets: ["AthanaSDK", "AthanaSDKWrapper"]),
        .library(name: "AthanaAdapterApple", targets: ["AthanaAdapterApple"]),
        .library(name: "AthanaAdapterAppLovin", targets: ["AthanaAdapterAppLovin"]),
        .library(name: "AthanaAdapterAppsFlyer", targets: ["AthanaAdapterAppsFlyer"]),
        .library(name: "AthanaAdapterFirebase", type: .static, targets: ["AthanaAdapterFirebase"]),
        .library(name: "AthanaAdapterGoogle", targets: ["AthanaAdapterGoogle"]),
        .library(name: "AthanaAdapterGameCenter", targets: ["AthanaAdapterGameCenter"]),
        .library(name: "AthanaAdapterMeta", targets: ["AthanaAdapterMeta"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git",
            .upToNextMajor(from: "13.2.0")),
        .package(
            url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework.git",
            .upToNextMajor(from: "6.17.0")),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.15.0")
        ),  // 12.+.0 要求 iOS 15
        .package(
            url: "https://github.com/facebook/facebook-ios-sdk.git", .upToNextMajor(from: "18.0.0")),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS.git", .upToNextMajor(from: "7.0.0")),
    ],
    targets: [
        .binaryTarget(
            name: "AthanaCore",
            url: "https://athana.inonesdk.com/ios/sdk/1.1.3/AthanaCore.xcframework.zip",
            checksum: "2f79ffb13d4d477fcf99d53cbe98922722521294c4d4bc6617eff1d74348a610"
        ),
        .binaryTarget(
            name: "AthanaSDK",
            url: "https://athana.inonesdk.com/ios/sdk/1.1.3/AthanaSDK.xcframework.zip",
            checksum: "074a98aaacb2cd7a27deb4ec623e85370a2dfdb5174ebd200169afa92111ecc6"
        ),

        .target(
            name: "AthanaCoreWrapper",
            dependencies: [
                "AthanaCore"
            ],
        ),
        .testTarget(
            name: "AthanaCoreWrapperTests",
            dependencies: [
                "AthanaCoreWrapper"
            ],
        ),
        
        .target(
            name: "AthanaSDKWrapper",
            dependencies: [
                "AthanaCoreWrapper"
            ],
        ),
        .testTarget(
            name: "AthanaSDKWrapperTests",
            dependencies: [
                "AthanaSDKWrapper"
            ],
        ),
        .target(
            name: "AthanaAdapterApple",
            dependencies: [
                "AthanaCoreWrapper",
            ],
            linkerSettings: []
        ),
        .testTarget(
            name: "AthanaAdapterAppleTests",
            dependencies: [
                "AthanaAdapterApple"
            ],
        ),
        .target(
            name: "AthanaAdapterAppLovin",
            dependencies: [
                "AthanaCoreWrapper",
                .product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package"),
            ],
            linkerSettings: []
        ),
        .testTarget(
            name: "AthanaAdapterAppLovinTests",
            dependencies: [
                "AthanaAdapterAppLovin"
            ],
        ),
        .target(
            name: "AthanaAdapterAppsFlyer",
            dependencies: [
                "AthanaCoreWrapper",
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework"),
            ],
            linkerSettings: []
        ),
        .testTarget(
            name: "AthanaAdapterAppsFlyerTests",
            dependencies: [
                "AthanaAdapterAppsFlyer"
            ],
        ),
        .target(
            name: "AthanaAdapterFirebase",
            dependencies: [
                "AthanaCoreWrapper",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            ],
            linkerSettings: [
                .linkedFramework("AdSupport", .when(platforms: [.iOS])),
            ]
        ),
        .testTarget(
            name: "AthanaAdapterFirebaseTests",
            dependencies: [
                "AthanaAdapterFirebase"
            ],
        ),
        .target(
            name: "AthanaAdapterGoogle",
            dependencies: [
                "AthanaCoreWrapper",
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ],
            linkerSettings: []
        ),
        .testTarget(
            name: "AthanaAdapterGoogleTests",
            dependencies: [
                "AthanaAdapterGoogle"
            ],
        ),
        .target(
            name: "AthanaAdapterGameCenter",
            dependencies: [
                "AthanaCoreWrapper",
            ],
            linkerSettings: []
        ),
        .testTarget(
            name: "AthanaAdapterGameCenterTests",
            dependencies: [
                "AthanaAdapterGameCenter"
            ],
        ),
        .target(
            name: "AthanaAdapterMeta",
            dependencies: [
                "AthanaCoreWrapper",
                .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
            ],
            linkerSettings: [],
        ),
        .testTarget(
            name: "AthanaAdapterMetaTests",
            dependencies: [
                "AthanaAdapterMeta"
            ],
        ),
    ]
)
