//
//  RecipeResults.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI

struct FoodImageView: View {
    let imageData: Data?
    
    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius, style: .continuous))
        } else {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius, style: .continuous))
                
                VStack(spacing: 12) {
                    ProgressView("")
                        .scaleEffect(1.2)
                    Text("Generating food image...")
                        .font(Theme.Typography.footnote)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
    }
}

struct RecipeCard: View {
    @Environment(\.colorScheme) var colorScheme
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Recipe image
            FoodImageView(imageData: recipe.imageData)
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

struct FullRecipeImageView: View {
    let imageData: Data?
    let height: CGFloat
    
    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: height)
                .frame(maxWidth: .infinity)
        } else {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                
                VStack(spacing: 12) {
                    ProgressView("")
                        .scaleEffect(1.5)
                    Text("Generating food image...")
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
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
                        FullRecipeImageView(imageData: recipe.imageData, height: 250)
                        
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .padding(16)
                        }
                        
                        // Title with semi-transparent background
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.title)
                                .font(Theme.Typography.title.weight(.bold))
                                .foregroundColor(colorScheme == .dark ? .white : .white)
                            
                            HStack(spacing: 16) {
                                Label(recipe.cookTime, systemImage: "clock")
                                    .font(Theme.Typography.callout)
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .white.opacity(0.9))
                                
                                Label(recipe.difficulty, systemImage: "chart.bar")
                                    .font(Theme.Typography.callout)
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .white.opacity(0.9))
                                
                                Label("\(recipe.servings) servings", systemImage: "person.2")
                                    .font(Theme.Typography.callout)
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .white.opacity(0.9))
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(LinearGradient(
                            gradient: Gradient(colors: [
                                colorScheme == .dark ? Color.black.opacity(0.6) : Color.black.opacity(0.7), 
                                colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.5),
                                colorScheme == .dark ? Color.black.opacity(0.1) : Color.black.opacity(0.3),
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .padding(.top, 260)
                    }
                    .padding(.bottom, 24)
                    
                    // Recipe content
                    VStack(alignment: .leading, spacing: 24) {
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
                                        Text(ingredient.lowercased())
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
    var mealType: String?
    var mealSubtype: String?
    var skillLevel: String?
    var cookTime: String?
    var cuisines: [String]
    var allergies: [String]
    var dietaryRestrictions: [String]
    var nutritionalRequirements: [String]
    
    // UI state
    @State private var showFullRecipe = false
    @State private var isLoading = true
    @State private var recipe: Recipe = Recipe.placeholder
    @State private var errorMessage: String? = nil
    
    // Services
    private let geminiService = GeminiService()
    
    init(
        ingredients: [String],
        mealType: String? = nil,
        mealSubtype: String? = nil,
        skillLevel: String? = nil,
        cookTime: String? = nil,
        cuisines: [String] = [],
        allergies: [String] = [],
        dietaryRestrictions: [String] = [],
        nutritionalRequirements: [String] = []
    ) {
        print("📋 RecipeResults initialized with \(ingredients.count) ingredients")
        self.ingredients = ingredients
        self.mealType = mealType
        self.mealSubtype = mealSubtype
        self.skillLevel = skillLevel
        self.cookTime = cookTime
        self.cuisines = cuisines
        self.allergies = allergies
        self.dietaryRestrictions = dietaryRestrictions
        self.nutritionalRequirements = nutritionalRequirements
        
        // Initialize with loading state
        self._isLoading = State(initialValue: true)
    }
    
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
                
                if isLoading {
                    // Loading state
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                        .padding()
                    Text("Creating your recipe...")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .padding()
                    Spacer()
                } else if let error = errorMessage {
                    // Error state
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.Colors.primary)
                        .padding()
                    Text(error)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    // Main content area with recipe
                    ScrollView {
                        VStack(spacing: 16) {
                            // Recipe card
                            RecipeCard(
                                recipe: recipe,
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
                        generateNewRecipe()
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
                    recipe: recipe,
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
        .onAppear {
            print("🚀 RecipeResults view appeared")
            // Log appearance but don't trigger recipe generation here
        }
        .task {
            // This is the primary method to trigger recipe generation
            print("🔄 RecipeResults task modifier activated")
            generateNewRecipe()
        }
    }
    
    private func generateNewRecipe() {
        isLoading = true
        errorMessage = nil
        
        // Super explicit debug prints that will appear in the console
        NSLog("🚨 FOODSNAP: Generating recipe with ingredients: \(ingredients.joined(separator: ", "))")
        NSLog("🚨 FOODSNAP: User preferences - Meal: \(mealType ?? "None"), Type: \(mealSubtype ?? "None"), Skill: \(skillLevel ?? "None")")
        
        // Debug info
        print("🍽️ generateNewRecipe called")
        print("📋 Ingredients: \(ingredients.joined(separator: ", "))")
        print("🕰️ Meal Type: \(mealType ?? "None")")
        print("🍲 Meal Subtype: \(mealSubtype ?? "None")")
        print("📊 Skill Level: \(skillLevel ?? "None")")
        print("⏱️ Cook Time: \(cookTime ?? "None")")
        print("🌍 Cuisines: \(cuisines.joined(separator: ", "))")
        print("⚠️ Allergies: \(allergies.joined(separator: ", "))")
        print("🥦 Dietary Restrictions: \(dietaryRestrictions.joined(separator: ", "))")
        print("💪 Nutritional Requirements: \(nutritionalRequirements.joined(separator: ", "))")
        
        // Save completion handler to a local variable to ensure it's not lost
        let completionHandler: (Result<Recipe, Error>) -> Void = { [self] result in
            NSLog("🚨 FOODSNAP: Recipe generation completed")
            
            isLoading = false
            
            switch result {
            case .success(let generatedRecipe):
                NSLog("🚨 FOODSNAP: Recipe success: \(generatedRecipe.title)")
                print("✅ Recipe generation successful: \(generatedRecipe.title)")
                self.recipe = generatedRecipe
            case .failure(let error):
                NSLog("🚨 FOODSNAP: Recipe failed: \(error.localizedDescription)")
                print("❌ Recipe generation failed: \(error.localizedDescription)")
                self.errorMessage = "Failed to generate recipe: \(error.localizedDescription)"
                self.recipe = Recipe.placeholder
            }
        }
        
        // For debugging - print ingredients one more time
        for (index, ingredient) in ingredients.enumerated() {
            NSLog("🚨 FOODSNAP: Ingredient \(index+1): \(ingredient)")
        }
        
        NSLog("🚨 FOODSNAP: Calling geminiService.generateRecipe")
        
        // Call the Gemini service
        geminiService.generateRecipe(
            ingredients: ingredients,
            mealType: mealType,
            mealSubtype: mealSubtype,
            skillLevel: skillLevel,
            cookTime: cookTime,
            cuisines: cuisines,
            allergies: allergies,
            dietaryRestrictions: dietaryRestrictions,
            nutritionalRequirements: nutritionalRequirements,
            completion: completionHandler
        )
        
        NSLog("🚨 FOODSNAP: geminiService.generateRecipe call completed - waiting for callback")
    }
}

#Preview {
    RecipeResults(ingredients: ["Chicken", "Tomatoes", "Onions", "Garlic", "Olive Oil"])
} 