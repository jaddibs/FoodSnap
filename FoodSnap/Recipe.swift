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
        description: "A colorful and appetizing dish with fresh ingredients arranged beautifully on a plate.",
        imageData: createPlaceholderImage()
    )
    
    // Create a placeholder image for development and preview
    private static func createPlaceholderImage() -> Data? {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Fill background
            UIColor.systemGray6.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw placeholder content
            let rect = CGRect(x: 50, y: 50, width: size.width - 100, height: size.height - 100)
            UIColor.systemGray4.setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 12).fill()
            
            // Draw placeholder text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor.gray
            ]
            
            let text = "Placeholder Image"
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        return image.jpegData(compressionQuality: 0.8)
    }
} 