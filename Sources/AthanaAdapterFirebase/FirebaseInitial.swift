//
//  FirebaseInitial.swift
//  Athana
//
//  Created by CWJoy on 30/8/2025.
//
import FirebaseCore

class FirebaseInitial {

    public static let shared = FirebaseInitial()
    
    private var isInitialized = false
    
    private init() {}
    
    func initialize() {
        if (isInitialized) {
            return
        }
        isInitialized = true
        FirebaseApp.configure()
    }
}
