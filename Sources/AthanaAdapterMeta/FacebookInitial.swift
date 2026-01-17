//
//  FacebookInitial.swift
//  AthanaAdapters
//
//  Created by CWJoy on 14/1/2026.
//
import FBSDKCoreKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class FacebookInitial {
    
    var initialized = false
    
    static let shared = FacebookInitial()

    private init() {}
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        if (initialized) {
            return
        }
        initialized = true
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions ?? [:]
        )
    }
    
}
