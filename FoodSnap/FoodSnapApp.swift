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
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isLoading = true
    
    init() {
        setupApp()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    SplashScreenView()
                } else {
                    ContentView()
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                // Show splash screen for 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
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

struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            HStack(spacing: 12) {
                Image(systemName: "camera.aperture")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.accent)
                
                Text("FoodSnap")
                    .font(Theme.Typography.largeTitle)
                    .foregroundColor(Theme.Colors.text)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: true)
    }
}
