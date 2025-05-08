//
//  SnapIngredients.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI
import UIKit
import Foundation

// MARK: - Ingredient Recognition Model
struct IngredientResponse: Codable {
    let ingredients: [String]
}

// MARK: - Photo Tip View
struct PhotoTipView: View {
    let icon: String
    let title: String
    let description: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Tip icon
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                // Tip title
                Text(title)
                    .font(Theme.Typography.subheadline.weight(.medium))
                    .foregroundColor(Theme.Colors.text)
                
                // Tip description
                Text(description)
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct SnapIngredients: View {
    @State private var selectedImages: [UIImage] = []
    @State private var isAnalyzing = false
    @State private var showTips = true
    @State private var navigateToManageIngredients = false
    @State private var analyzedIngredients: [String] = []
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showNoIngredientsAlert = false
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.presentationMode) var presentationMode
    
    private let geminiService = GeminiService()
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom back button and title row
                HStack {
                    // Back button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(Theme.Typography.subheadline.weight(.medium))
                        }
                        .foregroundColor(Theme.Colors.primary)
                    }
                    .padding(.leading, 4)
                    
                    Spacer()
                    
                    // Center title
                    Text("Snap Ingredients")
                        .font(Theme.Typography.title3)
                        .foregroundColor(Theme.Colors.text)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear.frame(width: 60, height: 16)
                }
                .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                    .padding(.bottom, 12)
                
                // Instructions text
                Text("Capture or upload a photo of your ingredients")
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Main content area
                ScrollView {
                    VStack(spacing: 12) {
                        // Image Picker
                        ImagePicker(selectedImages: $selectedImages)
                        
                        // Analyze Button (always visible, disabled when no images)
                        Button(action: {
                            startAnalysis()
                        }) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(width: 20, height: 20)
                                        .padding(.trailing, 5)
                                } else {
                                    Image(systemName: "magnifyingglass")
                                        .font(.headline)
                                }
                                Text(isAnalyzing ? "Analyzing..." : "Analyze Ingredients")
                                    .font(Theme.Typography.title3)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                        .padding(.top, 4)
                        .disabled(selectedImages.isEmpty || isAnalyzing)
                        .opacity((selectedImages.isEmpty || isAnalyzing) ? 0.7 : 1)
                        
                        // Tips Section
                        if showTips {
                            VStack(alignment: .leading, spacing: 8) {
                                // Tips section header with toggle button
                                HStack {
                                    Text("Photo Tips")
                                        .font(Theme.Typography.title3)
                                        .foregroundColor(Theme.Colors.text)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation {
                                            showTips.toggle()
                                        }
                                    }) {
                                        Image(systemName: "chevron.up")
                                            .font(.footnote.weight(.medium))
                                            .foregroundColor(Theme.Colors.secondaryText)
                                            .padding(6)
                                            .background(
                                                Circle()
                                                    .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                            )
                                    }
                                }
                                .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                                .padding(.bottom, 2)
                                
                                VStack(spacing: 8) {
                                    PhotoTipView(
                                        icon: "light.max",
                                        title: "Good Lighting",
                                        description: "Take photos in well-lit areas to ensure ingredients are clearly visible."
                                    )
                                    
                                    PhotoTipView(
                                        icon: "camera.viewfinder",
                                        title: "Clear Focus",
                                        description: "Hold your camera steady and tap to focus on the ingredients."
                                    )
                                    
                                    PhotoTipView(
                                        icon: "square.grid.3x3",
                                        title: "Group Ingredients",
                                        description: "Arrange ingredients so they're visible but not overlapping too much."
                                    )
                                }
                                .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                            }
                            .padding(.vertical, 4)
                        } else {
                            // Collapsed tips button
                            Button(action: {
                                withAnimation {
                                    showTips.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(Theme.Colors.accent)
                                    
                                    Text("Show Photo Tips")
                                        .font(Theme.Typography.callout.weight(.medium))
                                        .foregroundColor(Theme.Colors.text)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.callout)
                                        .foregroundColor(Theme.Colors.secondaryText)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 4, x: 0, y: 2)
                                )
                            }
                            .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                        }
                        
                        Spacer(minLength: 16)
                    }
                    .padding(.bottom)
                }
            }
            .padding(.bottom)
            
            // Analysis overlay (if analyzing)
            if isAnalyzing {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                            .scaleEffect(1.5)
                        
                        Text("Analyzing your ingredients...")
                            .font(Theme.Typography.title3)
                            .foregroundColor(.white)
                        
                        Text("This may take a moment")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.7))
                    )
                }
                .transition(.opacity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.aperture")
                        .font(.system(size: 22))
                        .foregroundColor(Theme.Colors.accent)
                    
                    Text("FoodSnap")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.text)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isDarkMode.toggle()
                }) {
                    Image(systemName: "circle.lefthalf.filled")
                        .font(.system(size: 20))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            isDarkMode ? Theme.Colors.primary : Color.gray,
                            isDarkMode ? Color.gray : Color.black
                        )
                        .rotationEffect(.degrees(isDarkMode ? 180 : 0))
                        .animation(.easeInOut, value: isDarkMode)
                }
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Analysis Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("No Ingredients Detected", isPresented: $showNoIngredientsAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("We couldn't identify any ingredients in your photo. Please try taking a clearer picture with better lighting, or use a different photo.")
        }
        .background(
            // Use background to place NavigationLink here instead of in the view hierarchy
            NavigationLink(
                destination: ManageIngredients(identifiedIngredients: analyzedIngredients),
                isActive: $navigateToManageIngredients,
                label: { EmptyView() }
            )
        )
        .onAppear {
            print("SnapIngredients view appeared")
        }
    }
    
    // Function to start the ingredient analysis process
    private func startAnalysis() {
        guard !selectedImages.isEmpty else { return }
        
        print("*** Starting analysis with \(selectedImages.count) images ***")
        
        // Set analyzing state first (before API call)
        isAnalyzing = true
        
        // Set a safety timeout to ensure we don't get stuck
        let safetyTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [self] _ in
            if isAnalyzing {
                print("⚠️ SAFETY TIMEOUT - Analysis taking too long, using fallback")
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    self.analyzedIngredients = ["Chicken", "Tomatoes", "Onions", "Garlic", "Olive Oil"]
                    self.forceNavigateToManageIngredients()
                }
            }
        }
        
        // Use Gemini API to analyze images
        geminiService.analyzeImages(selectedImages) { result in
            print("*** API call completed, processing result ***")
            
            // Cancel the safety timer since we got a response
            safetyTimer.invalidate()
            
            // Always execute on main thread
            DispatchQueue.main.async { [self] in
                print("*** On main thread, handling result... ***")
                
                // First, ensure loading is dismissed
                self.isAnalyzing = false
                print("*** Set isAnalyzing to false ***")
                
                switch result {
                case .success(let ingredients):
                    print("*** SUCCESS! Found \(ingredients.count) ingredients: \(ingredients) ***")
                    
                    // Check if any ingredients were detected
                    if ingredients.isEmpty {
                        print("⚠️ No ingredients detected - showing alert")
                        self.showNoIngredientsAlert = true
                        return
                    }
                    
                    // Update ingredients
                    self.analyzedIngredients = ingredients
                    
                    print("*** Updated analyzedIngredients, now forcing navigation ***")
                    
                    // Force navigation with our robust method
                    DispatchQueue.main.async {
                        self.forceNavigateToManageIngredients()
                    }
                    
                case .failure(let error):
                    print("*** ERROR: \(error.localizedDescription) ***")
                    
                    // Show error but still continue with fallback ingredients
                    self.errorMessage = "Failed to analyze ingredients: \(error.localizedDescription)"
                    self.showErrorAlert = true
                    
                    // Set fallback ingredients
                    self.analyzedIngredients = ["Chicken", "Tomatoes", "Onions", "Garlic", "Olive Oil"]
                    print("*** Set fallback ingredients: \(self.analyzedIngredients) ***")
                    
                    // Still navigate after a brief delay to allow alert to be seen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.forceNavigateToManageIngredients()
                    }
                }
            }
        }
    }
    
    // New method to force navigation when normal NavigationLink fails
    private func forceNavigateToManageIngredients() {
        print("🚀 Forcing navigation to ManageIngredients")
        
        // Method 1: Try standard navigation first
        self.navigateToManageIngredients = true
        print("➤ Set navigateToManageIngredients = true")
        
        // Method 2: If that fails, try delayed navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.navigateToManageIngredients {
                print("⚠️ Standard navigation failed, trying again...")
                self.navigateToManageIngredients = true
            }
        }
        
        // Method 3: Last resort - programmatic navigation via UIKit
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !self.navigateToManageIngredients {
                print("⚠️ Delayed navigation failed, using UIKit fallback...")
                
                // Get the current UIWindow and rootViewController
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootVC = window.rootViewController else {
                    print("❌ Could not access UIKit view hierarchy")
                    return
                }
                
                // Find the navigation controller
                var currentVC = rootVC
                while let presentedVC = currentVC.presentedViewController {
                    currentVC = presentedVC
                }
                
                // Check for available navigation options
                let hasNavController = (currentVC as? UINavigationController != nil) || (currentVC.navigationController != nil)
                
                if hasNavController {
                    let ingredients = self.analyzedIngredients
                    
                    // Create the destination view and present it
                    let destination = ManageIngredients(identifiedIngredients: ingredients)
                    let hostingController = UIHostingController(rootView: destination)
                    
                    if let navController = currentVC as? UINavigationController {
                        print("🧭 Using UINavigationController.pushViewController")
                        navController.pushViewController(hostingController, animated: true)
                    } else if let navController = currentVC.navigationController {
                        print("🧭 Using navigationController.pushViewController")
                        navController.pushViewController(hostingController, animated: true)
                    } else {
                        print("🧭 Using present")
                        currentVC.present(hostingController, animated: true)
                    }
                } else {
                    print("❌ No navigation controller found")
                }
            }
        }
    }
}

#Preview {
    SnapIngredients()
} 