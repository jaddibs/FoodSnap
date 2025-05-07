//
//  SnapIngredients.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI
import UIKit

struct SnapIngredients: View {
    @State private var selectedImages: [UIImage] = []
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
                    .padding(.bottom, Theme.Dimensions.largeSpacing)
                
                // Main content area
                ScrollView {
                    VStack(spacing: Theme.Dimensions.largeSpacing) {
                        // Image Picker
                        ImagePicker(selectedImages: $selectedImages)
                            .padding(.horizontal)
                        
                        // Analyze Button (shows when at least one image is selected)
                        if !selectedImages.isEmpty {
                            Button(action: {
                                // TODO: Process images with Gemini API
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
}

#Preview {
    SnapIngredients()
} 