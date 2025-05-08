//
//  RecipeResults.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI

struct RecipeCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Placeholder image
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius, style: .continuous))
                .padding(.bottom, 16)
            
            // Recipe title
            Text("Delicious Recipe")
                .font(Theme.Typography.title2.weight(.bold))
                .foregroundColor(Theme.Colors.text)
                .padding(.bottom, 8)
            
            // Recipe details
            HStack(spacing: 16) {
                Label("30 min", systemImage: "clock")
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                Label("Medium", systemImage: "chart.bar")
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                Label("4 servings", systemImage: "person.2")
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            .padding(.bottom, 16)
            
            // Ingredients section
            Text("Ingredients")
                .font(Theme.Typography.title3.weight(.semibold))
                .foregroundColor(Theme.Colors.text)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(["Ingredient 1", "Ingredient 2", "Ingredient 3", "Ingredient 4", "Ingredient 5"], id: \.self) { ingredient in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(Theme.Colors.primary)
                        Text(ingredient)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                    }
                }
            }
            .padding(.bottom, 16)
            
            // Instructions section
            Text("Instructions")
                .font(Theme.Typography.title3.weight(.semibold))
                .foregroundColor(Theme.Colors.text)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(1...4, id: \.self) { step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(step)")
                            .font(Theme.Typography.title3.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Theme.Colors.primary)
                            .clipShape(Circle())
                        
                        Text("This is step \(step) of the recipe instructions. It explains what to do in this part of the cooking process.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct RecipeResults: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Recipe parameters
    let ingredients: [String]
    let mealType: String?
    let skillLevel: String?
    let cookTime: String?
    let cuisines: [String]
    let allergies: [String]
    let dietaryRestrictions: [String]
    let nutritionalRequirements: [String]
    
    // UI state
    @State private var isLoading = false
    @State private var showIngredientDetails = false
    
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
                    Text("Get a Recipe")
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
                Text("Discover delicious recipes")
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                    .padding(.bottom, 16)
                
                // Main content area
                ScrollView {
                    VStack(spacing: 16) {
                        // Recipe info header
                        HStack {
                            Button(action: {
                                showIngredientDetails.toggle()
                            }) {
                                HStack {
                                    Text("Recipe Details")
                                        .font(Theme.Typography.title3)
                                        .foregroundColor(Theme.Colors.text)
                                    
                                    Image(systemName: showIngredientDetails ? "chevron.up" : "chevron.down")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundColor(Theme.Colors.secondaryText)
                                }
                            }
                            
                            Spacer()
                            
                            // Swipe instruction
                            HStack(spacing: 4) {
                                Image(systemName: "hand.draw")
                                    .font(.footnote)
                                    .foregroundColor(Theme.Colors.secondaryText)
                                
                                Text("Swipe for more")
                                    .font(Theme.Typography.footnote)
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                        }
                        .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                        
                        // Ingredient details (collapsible)
                        if showIngredientDetails {
                            VStack(alignment: .leading, spacing: 12) {
                                // Selected ingredients
                                DetailsGroupView(
                                    title: "Ingredients",
                                    icon: "carrot",
                                    items: ingredients
                                )
                                
                                // Selected preferences
                                if let mealType = mealType {
                                    DetailsItemView(
                                        title: "Meal Type",
                                        icon: "fork.knife",
                                        value: mealType
                                    )
                                }
                                
                                if let skillLevel = skillLevel {
                                    DetailsItemView(
                                        title: "Skill Level",
                                        icon: "chart.bar",
                                        value: skillLevel
                                    )
                                }
                                
                                if let cookTime = cookTime {
                                    DetailsItemView(
                                        title: "Cook Time",
                                        icon: "clock",
                                        value: cookTime
                                    )
                                }
                                
                                if !cuisines.isEmpty {
                                    DetailsGroupView(
                                        title: "Cuisines",
                                        icon: "globe",
                                        items: cuisines
                                    )
                                }
                                
                                if !allergies.isEmpty {
                                    DetailsGroupView(
                                        title: "Allergies",
                                        icon: "exclamationmark.triangle",
                                        items: allergies
                                    )
                                }
                                
                                if !dietaryRestrictions.isEmpty {
                                    DetailsGroupView(
                                        title: "Dietary Restrictions",
                                        icon: "leaf",
                                        items: dietaryRestrictions
                                    )
                                }
                                
                                if !nutritionalRequirements.isEmpty {
                                    DetailsGroupView(
                                        title: "Nutritional Requirements",
                                        icon: "heart",
                                        items: nutritionalRequirements
                                    )
                                }
                            }
                            .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                            .padding(.bottom, 8)
                        }
                        
                        // Recipe card
                        RecipeCard()
                            .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                        
                        // Action buttons
                        HStack(spacing: 16) {
                            // Dislike button
                            Button(action: {
                                // Handle dislike action
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            
                            // Save button
                            Button(action: {
                                // Handle save action
                            }) {
                                Image(systemName: "bookmark")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Theme.Colors.accent)
                                    .clipShape(Circle())
                            }
                            
                            // Like button
                            Button(action: {
                                // Handle like action
                            }) {
                                Image(systemName: "heart")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Theme.Colors.primary)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.vertical, 24)
                    }
                    .padding(.bottom, 24)
                }
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
        }
    }
}

// MARK: - Supporting Views

struct DetailsItemView: View {
    let title: String
    let icon: String
    let value: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 20)
            
            Text(title + ":")
                .font(Theme.Typography.footnote.weight(.medium))
                .foregroundColor(Theme.Colors.secondaryText)
            
            Text(value)
                .font(Theme.Typography.footnote)
                .foregroundColor(Theme.Colors.text)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.6))
        )
    }
}

struct DetailsGroupView: View {
    let title: String
    let icon: String
    let items: [String]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            headerView
            
            // Items grid
            itemsGridView
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.6))
        )
    }
    
    private var headerView: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 20)
            
            Text(title + ":")
                .font(Theme.Typography.footnote.weight(.medium))
                .foregroundColor(Theme.Colors.secondaryText)
            
            Spacer()
        }
    }
    
    private var itemsGridView: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 6) {
            ForEach(items, id: \.self) { item in
                itemView(for: item)
            }
        }
    }
    
    private func itemView(for item: String) -> some View {
        Text(item)
            .font(Theme.Typography.footnote)
            .foregroundColor(Theme.Colors.text)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? 
                          Theme.Colors.primary.opacity(0.2) : 
                          Theme.Colors.primary.opacity(0.1))
            )
            .lineLimit(1)
    }
}

#Preview {
    RecipeResults(
        ingredients: ["Chicken", "Tomatoes", "Onions", "Garlic", "Olive Oil"],
        mealType: "Main Course",
        skillLevel: "Intermediate",
        cookTime: "30-60 minutes",
        cuisines: ["Italian", "Mediterranean"],
        allergies: ["Dairy"],
        dietaryRestrictions: ["Gluten Free"],
        nutritionalRequirements: ["High Protein"]
    )
} 