//
//  ContentView.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "camera.fill")
                }
                .tag(0)
            
            SavedRecipesView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(1)
            
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "fork.knife")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(Theme.Colors.accent)
        .onAppear {
            // Set the tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.backgroundEffect = UIBlurEffect(style: colorScheme == .dark ? .systemMaterialDark : .systemUltraThinMaterial)
            appearance.backgroundColor = UIColor(Theme.Colors.background.opacity(0.9))
            
            // Set the tab bar item colors
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = UIColor(Theme.Colors.secondaryText)
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.Colors.secondaryText)]
            itemAppearance.selected.iconColor = UIColor(Theme.Colors.accent)
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.Colors.accent)]
            
            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct HomeView: View {
    @State private var selectedImage: UIImage?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.Dimensions.largeSpacing) {
                    // App Header
                    VStack(spacing: 4) {
                        Text("FoodSnap")
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Theme.Colors.text)
                        
                        Text("Snap, Identify, Cook")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                    .padding(.top)
                    
                    // Main content area
                    ScrollView {
                        VStack(spacing: Theme.Dimensions.largeSpacing) {
                            if let image = selectedImage {
                                // Selected Image Preview
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 260)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.largeCornerRadius))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.Dimensions.largeCornerRadius)
                                            .stroke(Theme.Colors.secondary, lineWidth: 3)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .padding(.horizontal)
                            } else {
                                // Placeholder
                                VStack(spacing: Theme.Dimensions.spacing) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(Theme.Colors.primary.opacity(0.8))
                                        .padding()
                                    
                                    Text("Take or select a photo of your ingredients")
                                        .font(Theme.Typography.callout)
                                        .foregroundColor(Theme.Colors.secondaryText)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.Dimensions.largeCornerRadius)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.1) : Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Dimensions.largeCornerRadius)
                                        .stroke(Theme.Colors.secondary, lineWidth: 1.5)
                                )
                                .padding(.horizontal)
                            }
                            
                            // Image Picker
                            ImagePicker(selectedImage: $selectedImage)
                                .padding(.horizontal)
                            
                            // Analyze Button (shows when image is selected)
                            if selectedImage != nil {
                                Button(action: {
                                    // TODO: Process image with Gemini API
                                }) {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .font(.headline)
                                        Text("Analyze Ingredients")
                                            .font(Theme.Typography.title3)
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            
                            Spacer(minLength: 30)
                        }
                        .padding(.bottom)
                    }
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
    }
}

// Placeholder Views for other tabs
struct SavedRecipesView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack {
                    Text("Saved Recipes")
                        .font(Theme.Typography.title)
                        .padding(.top)
                    
                    Spacer()
                    
                    // Placeholder content
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.Colors.primary)
                        
                        Text("Your saved recipes will appear here")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ExploreView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack {
                    Text("Explore")
                        .font(Theme.Typography.title)
                        .padding(.top)
                    
                    Spacer()
                    
                    // Placeholder content
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.Colors.primary)
                        
                        Text("Discover curated recipes and ideas")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack {
                    Text("Profile")
                        .font(Theme.Typography.title)
                        .padding(.top)
                    
                    Spacer()
                    
                    // Placeholder content
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.Colors.primary)
                        
                        Text("Manage your preferences and settings")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
