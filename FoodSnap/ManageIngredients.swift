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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.secondaryText)
                
                Text(ingredient)
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.text)
                    .strikethrough(!isSelected, color: Theme.Colors.secondaryText)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
}

// MARK: - Navigation Button
struct NavigationButtonView: View {
    let title: String
    let icon: String
    let action: () -> Void
    let isPrimary: Bool
    
    var body: some View {
        Group {
            if isPrimary {
                primaryButton
            } else {
                secondaryButton
            }
        }
    }
    
    private var primaryButton: some View {
        Button(action: action) {
            HStack {
                if icon == "chevron.left" {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(Theme.Typography.title3)
                
                if icon == "chevron.right" || icon == "arrow.right" {
                    Image(systemName: icon)
                        .font(.headline)
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle())
    }
    
    private var secondaryButton: some View {
        Button(action: action) {
            HStack {
                if icon == "chevron.left" {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(Theme.Typography.title3)
                
                if icon == "chevron.right" || icon == "arrow.right" {
                    Image(systemName: icon)
                        .font(.headline)
                }
            }
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

// MARK: - Progress Indicator
struct ProgressIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Theme.Colors.primary : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Section Types
enum SurveySection: Int, CaseIterable {
    case ingredients = 1
    case mealType = 2
    case skillLevel = 3
    case cookTime = 4
    case cuisineTypes = 5
    case allergies = 6
    case dietaryRestrictions = 7
    case nutritionalRequirements = 8
    
    var title: String {
        switch self {
        case .ingredients: return "Ingredients"
        case .mealType: return "Meal Type"
        case .skillLevel: return "Skill Level"
        case .cookTime: return "Cook Time"
        case .cuisineTypes: return "Cuisine Types"
        case .allergies: return "Allergies/Intolerances"
        case .dietaryRestrictions: return "Dietary Restrictions"
        case .nutritionalRequirements: return "Nutritional Requirements"
        }
    }
    
    var icon: String {
        switch self {
        case .ingredients: return "carrot"
        case .mealType: return "fork.knife"
        case .skillLevel: return "chart.bar"
        case .cookTime: return "clock"
        case .cuisineTypes: return "globe"
        case .allergies: return "exclamationmark.triangle"
        case .dietaryRestrictions: return "leaf"
        case .nutritionalRequirements: return "heart"
        }
    }
    
    var description: String {
        switch self {
        case .ingredients: return "These are the analyzed ingredients, add or select/deselect ingredients for your recipe."
        case .mealType: return "What type of meal would you like to make?"
        case .skillLevel: return "What's your cooking experience level?"
        case .cookTime: return "How much time do you have for cooking?"
        case .cuisineTypes: return "Select your preferred cuisine styles."
        case .allergies: return "Any food allergies or intolerances to avoid?"
        case .dietaryRestrictions: return "Any specific diet preferences?"
        case .nutritionalRequirements: return "Any nutritional requirements?"
        }
    }
}

struct ManageIngredients: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Current section in the survey
    @State private var currentSection: SurveySection = .ingredients
    
    // Navigation state
    @State private var navigateToRecipeResults = false
    
    // Sample data - would be populated from analysis in real implementation
    @State private var identifiedIngredients: [String]
    @State private var selectedIngredients: [String]
    @State private var newIngredient = ""
    
    // Preferences
    @State private var selectedMealType: String? = nil
    @State private var selectedMealTime: String? = nil
    @State private var selectedSkillLevel: String? = nil
    @State private var selectedCookTime: String? = nil
    @State private var selectedCuisines: Set<String> = []
    @State private var selectedAllergies: Set<String> = []
    @State private var selectedDiets: Set<String> = []
    @State private var selectedNutrition: Set<String> = []
    
    // Options
    let mealTimes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    let mealOptions = [
        "Breakfast": ["No preference", "Cereal", "Pancakes", "Eggs & Toast", "Smoothie Bowl", "Oatmeal"],
        "Lunch": ["No preference", "Sandwich", "Salad", "Soup", "Wrap", "Bowl"],
        "Dinner": ["No preference", "Appetizer", "Main Course", "Side Dish", "Dessert"],
        "Snack": ["No preference", "Sweet", "Savory", "Healthy", "Indulgent"]
    ]
    let skillLevels = ["Beginner", "Intermediate", "Advanced"]
    let cookTimes = ["No preference", "Under 15 minutes", "15-30 minutes", "30-60 minutes", "Over 60 minutes"]
    let cuisines = ["Italian", "Mexican", "Asian", "Mediterranean", "American", "Indian", "French", "Middle Eastern"]
    let allergies = ["Dairy", "Eggs", "Nuts", "Shellfish", "Wheat", "Soy"]
    let diets = ["Vegetarian", "Vegan", "Pescatarian", "Keto", "Paleo", "Low Carb", "Gluten Free"]
    let nutritionOptions = ["High Protein", "Low Fat", "Low Calorie", "Low Sodium", "Low Sugar"]
    
    // Initialize with ingredients from Gemini analysis
    init(identifiedIngredients: [String] = ["Chicken", "Tomatoes", "Onions", "Garlic", "Olive Oil"]) {
        // Log the incoming ingredients
        print("ManageIngredients received \(identifiedIngredients.count) ingredients: \(identifiedIngredients)")
        
        // Ensure all initial ingredients have their first letter capitalized and are unique
        let capitalizedIngredients = identifiedIngredients.map { ingredient in
            ingredient.prefix(1).capitalized + ingredient.dropFirst()
        }
        
        // Remove duplicates and sort alphabetically for better user experience
        let uniqueIngredients = Array(Set(capitalizedIngredients)).sorted()
        
        print("ManageIngredients processed \(uniqueIngredients.count) unique ingredients")
        
        _identifiedIngredients = State(initialValue: uniqueIngredients)
        _selectedIngredients = State(initialValue: uniqueIngredients)
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
                
                // App description
                Text("Review identified ingredients and set preferences")
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                    .padding(.bottom, 16)
                
                // Progress indicator
                ProgressIndicatorView(currentStep: currentSection.rawValue, totalSteps: SurveySection.allCases.count)
                    .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                    .padding(.bottom, 16)
                
                // Main content area - survey section content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Section Header
                        HStack {
                            Image(systemName: currentSection.icon)
                                .font(.system(size: 22))
                                .foregroundColor(Theme.Colors.primary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(currentSection.title)
                                    .font(Theme.Typography.title2)
                                    .foregroundColor(Theme.Colors.text)
                                    
                                Text(currentSection.description)
                                    .font(Theme.Typography.callout)
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 12)
                        
                        switch currentSection {
                        case .ingredients:
                            ingredientsSectionView
                        case .mealType:
                            mealTypeSectionView
                        case .skillLevel:
                            skillLevelSectionView
                        case .cookTime:
                            cookTimeSectionView
                        case .cuisineTypes:
                            cuisineTypesSectionView
                        case .allergies:
                            allergiesSectionView
                        case .dietaryRestrictions:
                            dietaryRestrictionsSectionView
                        case .nutritionalRequirements:
                            nutritionalRequirementsSectionView
                        }
                    }
                    .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                    .padding(.bottom, 24)
                }
                
                // Navigation buttons
                HStack(spacing: 16) {
                    // Back button (not shown on first section)
                    if currentSection != .ingredients {
                        NavigationButtonView(
                            title: "Back",
                            icon: "chevron.left",
                            action: goToPreviousSection,
                            isPrimary: false
                        )
                    }
                    
                    // Next/Generate button
                    NavigationButtonView(
                        title: currentSection == .nutritionalRequirements ? "Recipify" : "Next",
                        icon: currentSection == .nutritionalRequirements ? "arrow.right" : "chevron.right",
                        action: goToNextSection,
                        isPrimary: true
                    )
                    .disabled(!canProceedToNextSection)
                    .opacity(canProceedToNextSection ? 1.0 : 0.7)
                }
                .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                .padding(.bottom, 24)
            }
            .padding(.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToRecipeResults) {
                RecipeResults(
                    ingredients: selectedIngredients,
                    mealType: selectedMealTime,
                    mealSubtype: selectedMealType,
                    skillLevel: selectedSkillLevel,
                    cookTime: selectedCookTime,
                    cuisines: Array(selectedCuisines),
                    allergies: Array(selectedAllergies),
                    dietaryRestrictions: Array(selectedDiets),
                    nutritionalRequirements: Array(selectedNutrition)
                )
            }
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
    
    // MARK: - Navigation Functions
    
    func goToNextSection() {
        // First check if we can proceed
        if !canProceedToNextSection {
            return
        }
        
        if currentSection == .nutritionalRequirements {
            // Print debug info before navigating
            print("🚀 Navigating to RecipeResults with:")
            print("📋 Ingredients: \(selectedIngredients)")
            print("🕰️ Meal Type: \(selectedMealTime ?? "None")")
            print("🍲 Meal Subtype: \(selectedMealType ?? "None")")
            print("📊 Skill Level: \(selectedSkillLevel ?? "None")")
            print("⏱️ Cook Time: \(selectedCookTime ?? "None")")
            print("🌍 Cuisines: \(selectedCuisines)")
            print("⚠️ Allergies: \(selectedAllergies)")
            print("🥦 Dietary Restrictions: \(selectedDiets)")
            print("💪 Nutritional Requirements: \(selectedNutrition)")
            
            // Navigate to recipe generation screen
            navigateToRecipeResults = true
            return
        }
        
        withAnimation {
            currentSection = SurveySection(rawValue: currentSection.rawValue + 1) ?? .ingredients
        }
    }
    
    func goToPreviousSection() {
        withAnimation {
            currentSection = SurveySection(rawValue: currentSection.rawValue - 1) ?? .ingredients
        }
    }
    
    // Computed property to check if can proceed to next section
    var canProceedToNextSection: Bool {
        switch currentSection {
        case .ingredients:
            // Can always proceed from ingredients as long as at least one is selected
            return !selectedIngredients.isEmpty
        case .mealType:
            // Need both meal time and meal type selected
            return selectedMealTime != nil && selectedMealType != nil
        case .skillLevel:
            // Need skill level selected
            return selectedSkillLevel != nil
        case .cookTime:
            // Need cook time selected
            return selectedCookTime != nil
        default:
            // Other sections don't require selection
            return true
        }
    }
    
    // MARK: - Section Views
    
    // Ingredients Section
    var ingredientsSectionView: some View {
        VStack(spacing: 12) {
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
                        // Capitalize the first letter of the new ingredient
                        let capitalizedIngredient = newIngredient.prefix(1).capitalized + newIngredient.dropFirst()
                        identifiedIngredients.append(capitalizedIngredient)
                        selectedIngredients.append(capitalizedIngredient)
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
    }
    
    // Meal Type Section
    var mealTypeSectionView: some View {
        VStack(spacing: 8) {
            ForEach(mealTimes, id: \.self) { mealTime in
                VStack(spacing: 0) {
                    SingleSelectionOptionView(
                        option: mealTime,
                        title: mealTime,
                        isSelected: selectedMealTime == mealTime,
                        action: { selectedMealTime = $0 }
                    )
                    
                    if selectedMealTime == mealTime, let options = mealOptions[mealTime] {
                        // Connector line
                        Rectangle()
                            .fill(Theme.Colors.primary.opacity(0.5))
                            .frame(width: 2)
                            .frame(height: 8)
                            .padding(.leading, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 2)
                        
                        VStack(spacing: 8) {
                            ForEach(options, id: \.self) { option in
                                HStack(spacing: 0) {
                                    // Connector line
                                    Rectangle()
                                        .fill(Theme.Colors.primary.opacity(0.5))
                                        .frame(width: 2, height: 12)
                                        .padding(.horizontal, 7)
                                        
                                    SingleSelectionOptionView(
                                        option: option,
                                        title: option,
                                        isSelected: selectedMealType == option,
                                        action: { selectedMealType = $0 }
                                    )
                                }
                            }
                        }
                        .padding(.bottom, 8)
                        .transition(.opacity)
                    }
                }
            }
        }
    }
    
    // Skill Level Section
    var skillLevelSectionView: some View {
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
    }
    
    // Cook Time Section
    var cookTimeSectionView: some View {
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
    }
    
    // Cuisine Types Section
    var cuisineTypesSectionView: some View {
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
    }
    
    // Allergies Section
    var allergiesSectionView: some View {
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
    }
    
    // Dietary Restrictions Section
    var dietaryRestrictionsSectionView: some View {
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
    }
    
    // Nutritional Requirements Section
    var nutritionalRequirementsSectionView: some View {
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
    }
}

#Preview {
    ManageIngredients()
} 