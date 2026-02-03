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
            url: "https://athana.inonesdk.com/ios/sdk/1.0.5/AthanaCore.xcframework.zip",
            checksum: "bb58561b7d50a942cf83f4c79ef8755238fb1e7c6e79e95e8401dd7a49fc89b5"
        ),
        .binaryTarget(
            name: "AthanaSDK",
            url: "https://athana.inonesdk.com/ios/sdk/1.0.5/AthanaSDK.xcframework.zip",
            checksum: "c98e92af1d10037f51f63dbc3228acebe42c9a4e0bac815d71c7054a9bca27b4"
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
            name: "AthanaAdapterMeta",
            dependencies: [
                "AthanaCoreWrapper",
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
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
