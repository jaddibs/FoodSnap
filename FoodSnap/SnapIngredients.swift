//
//  SnapIngredients.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI
import UIKit

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
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.presentationMode) var presentationMode
    
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
            
            // Navigation link to ManageIngredients (hidden)
            NavigationLink(
                destination: ManageIngredients(),
                isActive: $navigateToManageIngredients,
                label: { EmptyView() }
            )
            
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
    }
    
    // Function to start the ingredient analysis process
    private func startAnalysis() {
        guard !selectedImages.isEmpty else { return }
        
        withAnimation {
            isAnalyzing = true
        }
        
        // Simulate API call with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // TODO: Process images with Gemini API
            
            withAnimation {
                isAnalyzing = false
                navigateToManageIngredients = true
            }
        }
    }
}

#Preview {
    SnapIngredients()
} 