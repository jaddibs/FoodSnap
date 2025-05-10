//
//  RecipeResults.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI

struct RecipeCard: View {
    @Environment(\.colorScheme) var colorScheme
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Recipe image
            Group {
                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius, style: .continuous))
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius, style: .continuous))
                }
            }
            .padding(.bottom, 16)
            
            // Recipe title
            Text(recipe.title)
                .font(Theme.Typography.title2.weight(.bold))
                .foregroundColor(Theme.Colors.text)
                .padding(.bottom, 8)
            
            // Recipe details
            HStack(spacing: 16) {
                Label(recipe.cookTime, systemImage: "clock")
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                Label(recipe.difficulty, systemImage: "chart.bar")
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                Label("\(recipe.servings) servings", systemImage: "person.2")
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            .padding(.bottom, 16)
            
            // Recipe description
            if let description = recipe.description {
                Text(description)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .italic()
                    .lineLimit(3)
                    .padding(.bottom, 16)
            }
            
            // Show tap to expand hint
            HStack {
                Spacer()
                Text("Tap to view full recipe")
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .padding(.top, 8)
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 4, x: 0, y: 2)
        )
        .onTapGesture {
            onTap()
        }
    }
}

struct RecipeFullView: View {
    @Environment(\.colorScheme) var colorScheme
    let recipe: Recipe
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Recipe image with dismiss button overlay
                    ZStack(alignment: .topTrailing) {
                        Group {
                            if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 250)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 250)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .padding(16)
                        }
                    }
                    .padding(.bottom, 24)
                    
                    // Recipe content
                    VStack(alignment: .leading, spacing: 24) {
                        // Title and details
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.title)
                                .font(Theme.Typography.title.weight(.bold))
                                .foregroundColor(Theme.Colors.text)
                            
                            HStack(spacing: 16) {
                                Label(recipe.cookTime, systemImage: "clock")
                                    .font(Theme.Typography.callout)
                                    .foregroundColor(Theme.Colors.secondaryText)
                                
                                Label(recipe.difficulty, systemImage: "chart.bar")
                                    .font(Theme.Typography.callout)
                                    .foregroundColor(Theme.Colors.secondaryText)
                                
                                Label("\(recipe.servings) servings", systemImage: "person.2")
                                    .font(Theme.Typography.callout)
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                        }
                        
                        // Description
                        if let description = recipe.description {
                            Text(description)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.secondaryText)
                                .italic()
                        }
                        
                        // Ingredients section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ingredients")
                                .font(Theme.Typography.title2.weight(.semibold))
                                .foregroundColor(Theme.Colors.text)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(recipe.ingredients, id: \.self) { ingredient in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .foregroundColor(Theme.Colors.primary)
                                        Text(ingredient)
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.text)
                                    }
                                }
                            }
                        }
                        
                        // Instructions section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Instructions")
                                .font(Theme.Typography.title2.weight(.semibold))
                                .foregroundColor(Theme.Colors.text)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(Array(zip(recipe.instructions.indices, recipe.instructions)), id: \.0) { index, instruction in
                                    HStack(alignment: .top, spacing: 16) {
                                        Text("\(index + 1)")
                                            .font(Theme.Typography.title3.weight(.bold))
                                            .foregroundColor(.white)
                                            .frame(width: 36, height: 36)
                                            .background(Theme.Colors.primary)
                                            .clipShape(Circle())
                                        
                                        Text(instruction)
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.text)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

struct RecipeResults: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Recipe parameters
    let ingredients: [String]
    
    // UI state
    @State private var showFullRecipe = false
    
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
                    Text("Recipify")
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
                
                // App description
                Text("Discover your perfect recipe")
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                    .padding(.bottom, 16)
                
                // Main content area
                ScrollView {
                    VStack(spacing: 16) {
                        // Recipe card
                        RecipeCard(
                            recipe: Recipe.placeholder,
                            onTap: {
                                withAnimation {
                                    showFullRecipe = true
                                }
                            }
                        )
                        .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                    }
                    .padding(.bottom, 24)
                }
                
                Spacer()
                
                // Another Recipe button at bottom of screen
                Button(action: {
                    // No implementation yet
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                        
                        Text("Another Recipe!")
                            .font(Theme.Typography.title3)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                .padding(.bottom, 32)
            }
            .padding(.bottom)
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
            
            // Full recipe overlay
            if showFullRecipe {
                RecipeFullView(
                    recipe: Recipe.placeholder,
                    onDismiss: {
                        withAnimation {
                            showFullRecipe = false
                        }
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
    }
}

#Preview {
    RecipeResults(ingredients: ["Chicken", "Tomatoes", "Onions", "Garlic", "Olive Oil"])
} 