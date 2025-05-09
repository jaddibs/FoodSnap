//
//  Recipe.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI

struct Recipe: Identifiable, Codable {
    var id = UUID()
    var title: String
    var cookTime: String
    var difficulty: String
    var servings: Int
    var ingredients: [String]
    var instructions: [String]
    var description: String?
    var imageURL: String?
    var imageData: Data?
    
    // For previews and fallback
    static let placeholder = Recipe(
        title: "Delicious Recipe",
        cookTime: "30 min",
        difficulty: "Medium",
        servings: 4,
        ingredients: ["Ingredient 1", "Ingredient 2", "Ingredient 3", "Ingredient 4", "Ingredient 5"],
        instructions: [
            "This is step 1 of the recipe instructions. It explains what to do in this part of the cooking process.",
            "This is step 2 of the recipe instructions. It explains what to do in this part of the cooking process.",
            "This is step 3 of the recipe instructions. It explains what to do in this part of the cooking process.",
            "This is step 4 of the recipe instructions. It explains what to do in this part of the cooking process."
        ],
        description: "A colorful and appetizing dish with fresh ingredients arranged beautifully on a plate."
    )
} 