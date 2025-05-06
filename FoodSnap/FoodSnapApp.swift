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
    
    @Environment(\.colorScheme) var colorScheme
    
    init() {
        setupApp()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.none) // Allow system to control dark/light mode
        }
    }
    
    private func setupApp() {
        // Pre-check camera permissions at app start to handle initialization issues
        _ = AVCaptureDevice.authorizationStatus(for: .video)
        
        // Set app-wide UI appearance
        if #available(iOS 15.0, *) {
            // Navigation bar appearance
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.backgroundColor = UIColor(Theme.Colors.background)
            navAppearance.titleTextAttributes = [.foregroundColor: UIColor(Theme.Colors.text)]
            navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Theme.Colors.text)]
            
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance
            
            // Tab bar appearance
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithOpaqueBackground()
            tabAppearance.backgroundColor = UIColor(Theme.Colors.background)
            
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
    }
}
