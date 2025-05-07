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
                WelcomeView()
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    SplashScreenView()
                        .opacity(isLoading ? 1 : 0)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                // Simple cross-fade transition after 1.2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut(duration: 0.8)) {
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
    @State private var logoScale: CGFloat = 0.9
    
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
            .scaleEffect(logoScale)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    logoScale = 1.0
                }
            }
        }
    }
}
