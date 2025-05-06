//
//  FoodSnapApp.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI
import AVFoundation

// Define Info.plist values in code (modern approach)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
}

@main
struct FoodSnapApp: App {
    // Add the app delegate to handle Info.plist requirements
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        setupApp()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupApp() {
        // Pre-check camera permissions at app start to handle initialization issues
        _ = AVCaptureDevice.authorizationStatus(for: .video)
        
        // Set app-wide UI appearance
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
