//
//  ManageIngredients.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI

// MARK: - Section Header
struct SectionHeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(Theme.Typography.title3.weight(.semibold))
                .foregroundColor(Theme.Colors.text)
            
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Single Selection Option
struct SingleSelectionOptionView<T: Hashable>: View {
    let option: T
    let title: String
    let isSelected: Bool
    let action: (T) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            action(option)
        }) {
            HStack {
                Text(title)
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.text)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                    .fill(isSelected ? 
                          (colorScheme == .dark ? Theme.Colors.primary.opacity(0.2) : Theme.Colors.primary.opacity(0.1)) : 
                          (colorScheme == .dark ? Color.black.opacity(0.2) : Color.white))
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                    .stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Multi Selection Option
struct MultiSelectionOptionView<T: Hashable>: View {
    let option: T
    let title: String
    let isSelected: Bool
    let action: (T) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            action(option)
        }) {
            HStack {
                Text(title)
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.text)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.secondaryText)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                    .fill(isSelected ? 
                          (colorScheme == .dark ? Theme.Colors.primary.opacity(0.2) : Theme.Colors.primary.opacity(0.1)) : 
                          (colorScheme == .dark ? Color.black.opacity(0.2) : Color.white))
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
}

// MARK: - Ingredient Item View
struct IngredientItemView: View {
    let ingredient: String
    let isSelected: Bool
    let onToggle: () -> Void
    let onRemove: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.secondaryText)
                    
                    Text(ingredient)
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.text)
                        .strikethrough(!isSelected, color: Theme.Colors.secondaryText)
                }
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.Colors.secondaryText)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct ManageIngredients: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Sample data - would be populated from analysis in real implementation
    @State private var identifiedIngredients: [String]
    @State private var selectedIngredients: [String]
    @State private var newIngredient = ""
    
    // Preferences
    @State private var selectedMealType: String = "Main Course"
    @State private var selectedSkillLevel: String = "Intermediate"
    @State private var selectedCookTime: String = "30-60 minutes"
    @State private var selectedCuisines: Set<String> = []
    @State private var selectedAllergies: Set<String> = []
    @State private var selectedDiets: Set<String> = []
    @State private var selectedNutrition: Set<String> = []
    
    // Initialize with ingredients from Gemini analysis
    init(identifiedIngredients: [String] = ["Chicken", "Tomatoes", "Onions", "Garlic", "Olive Oil"]) {
        _identifiedIngredients = State(initialValue: identifiedIngredients)
        _selectedIngredients = State(initialValue: identifiedIngredients)
    }
    
    // Options
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Appetizer", "Main Course", "Side Dish", "Dessert"]
    let skillLevels = ["Beginner", "Intermediate", "Advanced"]
    let cookTimes = ["Under 15 minutes", "15-30 minutes", "30-60 minutes", "Over 60 minutes"]
    let cuisines = ["Italian", "Mexican", "Asian", "Mediterranean", "American", "Indian", "French", "Middle Eastern"]
    let allergies = ["Dairy", "Eggs", "Nuts", "Shellfish", "Wheat", "Soy"]
    let diets = ["Vegetarian", "Vegan", "Pescatarian", "Keto", "Paleo", "Low Carb", "Gluten Free"]
    let nutritionOptions = ["High Protein", "Low Fat", "Low Calorie", "Low Sodium", "Low Sugar"]
    
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
                    Text("Manage Mise en Place")
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
                Text("Review identified ingredients and set preferences")
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Main content area
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // MARK: - Ingredients Section
                        SectionHeaderView(title: "Ingredients", icon: "carrot")
                        
                        VStack(spacing: 8) {
                            ForEach(identifiedIngredients, id: \.self) { ingredient in
                                IngredientItemView(
                                    ingredient: ingredient,
                                    isSelected: selectedIngredients.contains(ingredient),
                                    onToggle: {
                                        if selectedIngredients.contains(ingredient) {
                                            selectedIngredients.removeAll { $0 == ingredient }
                                        } else {
                                            selectedIngredients.append(ingredient)
                                        }
                                    },
                                    onRemove: {
                                        identifiedIngredients.removeAll { $0 == ingredient }
                                        selectedIngredients.removeAll { $0 == ingredient }
                                    }
                                )
                            }
                            
                            // Add new ingredient
                            HStack {
                                TextField("Add ingredient", text: $newIngredient)
                                    .font(Theme.Typography.callout)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                                            .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 4, x: 0, y: 2)
                                    )
                                
                                Button(action: {
                                    if !newIngredient.isEmpty && !identifiedIngredients.contains(newIngredient) {
                                        identifiedIngredients.append(newIngredient)
                                        selectedIngredients.append(newIngredient)
                                        newIngredient = ""
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Theme.Colors.primary)
                                }
                                .disabled(newIngredient.isEmpty)
                                .opacity(newIngredient.isEmpty ? 0.5 : 1)
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // MARK: - Meal Type Section
                        SectionHeaderView(title: "Meal Type", icon: "fork.knife")
                        
                        VStack(spacing: 8) {
                            ForEach(mealTypes, id: \.self) { mealType in
                                SingleSelectionOptionView(
                                    option: mealType,
                                    title: mealType,
                                    isSelected: selectedMealType == mealType,
                                    action: { selectedMealType = $0 }
                                )
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // MARK: - Skill Level Section
                        SectionHeaderView(title: "Skill Level", icon: "chart.bar")
                        
                        VStack(spacing: 8) {
                            ForEach(skillLevels, id: \.self) { level in
                                SingleSelectionOptionView(
                                    option: level,
                                    title: level,
                                    isSelected: selectedSkillLevel == level,
                                    action: { selectedSkillLevel = $0 }
                                )
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // MARK: - Cook Time Section
                        SectionHeaderView(title: "Cook Time", icon: "clock")
                        
                        VStack(spacing: 8) {
                            ForEach(cookTimes, id: \.self) { time in
                                SingleSelectionOptionView(
                                    option: time,
                                    title: time,
                                    isSelected: selectedCookTime == time,
                                    action: { selectedCookTime = $0 }
                                )
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // MARK: - Cuisine Types Section
                        SectionHeaderView(title: "Cuisine Types", icon: "globe")
                        
                        VStack(spacing: 8) {
                            ForEach(cuisines, id: \.self) { cuisine in
                                MultiSelectionOptionView(
                                    option: cuisine,
                                    title: cuisine,
                                    isSelected: selectedCuisines.contains(cuisine),
                                    action: { cuisine in
                                        if selectedCuisines.contains(cuisine) {
                                            selectedCuisines.remove(cuisine)
                                        } else {
                                            selectedCuisines.insert(cuisine)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // MARK: - Allergies/Intolerances Section
                        SectionHeaderView(title: "Allergies/Intolerances", icon: "exclamationmark.triangle")
                        
                        VStack(spacing: 8) {
                            ForEach(allergies, id: \.self) { allergy in
                                MultiSelectionOptionView(
                                    option: allergy,
                                    title: allergy,
                                    isSelected: selectedAllergies.contains(allergy),
                                    action: { allergy in
                                        if selectedAllergies.contains(allergy) {
                                            selectedAllergies.remove(allergy)
                                        } else {
                                            selectedAllergies.insert(allergy)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // MARK: - Dietary Restrictions Section
                        SectionHeaderView(title: "Dietary Restrictions", icon: "leaf")
                        
                        VStack(spacing: 8) {
                            ForEach(diets, id: \.self) { diet in
                                MultiSelectionOptionView(
                                    option: diet,
                                    title: diet,
                                    isSelected: selectedDiets.contains(diet),
                                    action: { diet in
                                        if selectedDiets.contains(diet) {
                                            selectedDiets.remove(diet)
                                        } else {
                                            selectedDiets.insert(diet)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // MARK: - Nutritional Requirements Section
                        SectionHeaderView(title: "Nutritional Requirements", icon: "heart")
                        
                        VStack(spacing: 8) {
                            ForEach(nutritionOptions, id: \.self) { option in
                                MultiSelectionOptionView(
                                    option: option,
                                    title: option,
                                    isSelected: selectedNutrition.contains(option),
                                    action: { option in
                                        if selectedNutrition.contains(option) {
                                            selectedNutrition.remove(option)
                                        } else {
                                            selectedNutrition.insert(option)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 24)
                        
                        // MARK: - Next Button
                        Button(action: {
                            // TODO: Navigate to recipe generation screen
                        }) {
                            HStack {
                                Text("Generate Recipes")
                                    .font(Theme.Typography.title3)
                                
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, Theme.Dimensions.horizontalPadding)
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

#Preview {
    ManageIngredients()
} 