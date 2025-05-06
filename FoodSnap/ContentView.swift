//
//  ContentView.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.Dimensions.largeSpacing) {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("FoodSnap")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.text)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Settings button action (does nothing for now)
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
