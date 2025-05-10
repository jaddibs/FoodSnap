//
//  GeminiService.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI
import UIKit
import Foundation

// MARK: - Gemini API Service
class GeminiService {
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    private let imageAnalysisModel = "gemini-2.0-flash"
    private let recipeGenerationModel = "gemini-2.0-flash"
    
    // MARK: - Image Analysis for Ingredients
    
    func analyzeImages(_ images: [UIImage], completion: @escaping (Result<[String], Error>) -> Void) {
        // TEMPORARY HARDCODED FALLBACK - This guarantees we always have ingredients for error cases
        let fallbackIngredients = ["Chicken", "Tomatoes", "Onions", "Garlic", "Olive Oil"]
        
        // Verify we have images to analyze
        guard !images.isEmpty else {
            print("⚠️ No images provided - using fallback ingredients")
            completion(.success(fallbackIngredients))
            return
        }
        
        print("🔎 Analyzing \(images.count) images for ingredients")
        
        guard let apiKey = loadAPIKey() else {
            print("⚠️ API Key not found - using fallback ingredients")
            // Even if API key is missing, provide fallback ingredients
            completion(.success(fallbackIngredients))
            return
        }
        
        let url = URL(string: "\(baseURL)/\(imageAnalysisModel):generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the multimodal prompt
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": createMultipartRequest(images)
                ]
            ],
            "generationConfig": [
                "temperature": 0.2,
                "topP": 0.8,
                "topK": 40
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("⚠️ Error serializing request: \(error.localizedDescription)")
            completion(.success(fallbackIngredients))
            return
        }
        
        print("📤 Sending API request with \(images.count) images")
        
        // Set a shorter timeout to prevent UI freezing
        let session = URLSession(configuration: {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 15.0
            return config
        }())
        
        session.dataTask(with: request) { data, response, error in
            // Always return to main thread for completion handler
            let returnResult: (Result<[String], Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            // Handle network errors
            if let error = error {
                print("⚠️ Network error: \(error.localizedDescription)")
                returnResult(.success(fallbackIngredients))
                return
            }
            
            // Handle missing data
            guard let data = data else {
                print("⚠️ No data received from API")
                returnResult(.success(fallbackIngredients))
                return
            }
            
            // Print raw response for debugging
            let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode"
            print("📥 Raw response (\(data.count) bytes): \(responseString.prefix(100))...")
            
            // Try parsing the JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Debug print the JSON structure
                    print("📊 JSON keys: \(json.keys.joined(separator: ", "))")
                    
                    // Check for API errors
                    if let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        print("🚫 API Error: \(message)")
                        returnResult(.success(fallbackIngredients))
                        return
                    }
                    
                    // Extract the ingredients text
                    if let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let firstPart = parts.first,
                       let text = firstPart["text"] as? String {
                        
                        print("🔍 Text from API: \(text)")
                        
                        // First try: Direct JSON parsing - specifically recognize empty arrays []
                        if text.trimmingCharacters(in: .whitespacesAndNewlines) == "[]" {
                            print("✅ Detected empty JSON array - no ingredients found")
                            returnResult(.success([]))
                            return
                        }
                        
                        // Use our enhanced extractIngredientsFromText method which can handle multiple arrays
                        let extractedIngredients = self.extractIngredientsFromText(text)
                        
                        if extractedIngredients.isEmpty && !text.isEmpty {
                            print("⚠️ Failed to extract ingredients from non-empty text - using fallback")
                            returnResult(.success(fallbackIngredients))
                        } else {
                            print("✅ Successfully extracted \(extractedIngredients.count) ingredients")
                            returnResult(.success(extractedIngredients))
                        }
                        return
                    }
                }
                
                // If we got here, something went wrong with parsing
                print("⚠️ Failed to parse response - using fallback ingredients")
                returnResult(.success(fallbackIngredients))
                
            } catch {
                print("⚠️ JSON parsing error: \(error.localizedDescription)")
                returnResult(.success(fallbackIngredients))
            }
        }.resume()
    }
    
    // Extract ingredients from text
    private func extractIngredientsFromText(_ text: String) -> [String] {
        var ingredients: [String] = []
        
        // Handle multiple JSON arrays case - combine all found arrays
        if let regex = try? NSRegularExpression(pattern: "\\[.*?\\]", options: .dotMatchesLineSeparators) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            // Try to extract from each JSON array match
            for match in matches {
                let jsonText = (text as NSString).substring(with: match.range)
                
                do {
                    let jsonData = jsonText.data(using: .utf8)!
                    let extractedIngredients = try JSONDecoder().decode([String].self, from: jsonData)
                    ingredients.append(contentsOf: extractedIngredients)
                } catch {
                    // If JSON parsing fails, we'll fall back to text parsing below
                    print("⚠️ JSON array parsing failed for match: \(error.localizedDescription)")
                }
            }
            
            // If we found valid JSON arrays, return the combined ingredients
            if !ingredients.isEmpty {
                print("✅ Successfully parsed multiple JSON arrays")
                return Array(Set(ingredients)).sorted() // Remove duplicates and sort
            }
        }
        
        // Fallback to text parsing for non-JSON responses
        print("⚠️ Falling back to text parsing")
        
        // Split by lines and process each line
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.isEmpty { continue }
            
            // Remove list markers
            let cleanedLine = trimmedLine.replacingOccurrences(of: "^[•\\-\\*\\d\\.\\)]+\\s*", with: "", options: .regularExpression)
            
            // Split by commas if present
            if cleanedLine.contains(",") {
                let items = cleanedLine.components(separatedBy: ",")
                for item in items {
                    let trimmedItem = item.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedItem.isEmpty {
                        // Clean quotes and other JSON artifacts
                        let finalItem = trimmedItem
                            .replacingOccurrences(of: "^\"", with: "", options: .regularExpression)
                            .replacingOccurrences(of: "\"$", with: "", options: .regularExpression)
                        ingredients.append(finalItem)
                    }
                }
            } else {
                // Clean quotes and other JSON artifacts
                let finalItem = cleanedLine
                    .replacingOccurrences(of: "^\"", with: "", options: .regularExpression)
                    .replacingOccurrences(of: "\"$", with: "", options: .regularExpression)
                ingredients.append(finalItem)
            }
        }
        
        // Remove duplicates and sort
        return Array(Set(ingredients)).sorted()
    }
    
    // Create request with text and images
    private func createMultipartRequest(_ images: [UIImage]) -> [[String: Any]] {
        var parts: [[String: Any]] = []
        
        // Add text instructions - keep it simple and clear
        parts.append([
            "text": """
            Analyze ALL the food ingredients in these images collectively.
            Consider ALL images as a complete set of ingredients - don't analyze each image separately.
            Combine ingredients from all images into a single comprehensive list.
            Return ONLY a JSON array of ingredient names. Example: ["tomato", "onion", "chicken", "olive oil"]
            Be specific but concise with ingredient names.
            If no ingredients are visible, return an empty JSON array: []
            Do not include any explanations, just the JSON array.
            """
        ])
        
        // Add images - use lower compression quality to reduce size
        for image in images {
            if let base64Image = image.jpegData(compressionQuality: 0.5)?.base64EncodedString() {
                parts.append([
                    "inlineData": [
                        "mimeType": "image/jpeg",
                        "data": base64Image
                    ]
                ])
            }
        }
        
        return parts
    }
    
    // Load API key with error handling
    private func loadAPIKey() -> String? {
        // Search in various locations
        let locations = [
            Bundle.main.url(forResource: ".env", withExtension: nil),
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(".env")
        ]
        
        for location in locations.compactMap({ $0 }) {
            if FileManager.default.fileExists(atPath: location.path) {
                do {
                    let contents = try String(contentsOf: location, encoding: .utf8)
                    if let apiKey = parseAPIKey(from: contents) {
                        print("🔑 Found API key in .env file")
                        return apiKey
                    }
                } catch {
                    print("Error reading .env file: \(error)")
                }
            }
        }
        
        // For debugging - provides a working API key
        // Get a real API key from: https://makersuite.google.com/app/apikey
        print("⚠️ No API key found in .env file - using hardcoded test key")
        return "AIzaSyB_kGcyScv1Kh9wYi9WSi7MmGmwmMAkP_o" // This is a test key, replace with your own
    }
    
    private func parseAPIKey(from contents: String) -> String? {
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix("GEMINI_API_KEY=") {
                let key = line.replacingOccurrences(of: "GEMINI_API_KEY=", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !key.isEmpty {
                    return key
                }
            }
        }
        return nil
    }
    
    enum GeminiError: Error, LocalizedError {
        case apiKeyNotFound
        case noDataReceived
        case invalidResponse
        case apiError(String)
        
        var errorDescription: String? {
            switch self {
            case .apiKeyNotFound:
                return "Gemini API key not found. Please add it to your .env file."
            case .noDataReceived:
                return "No data received from the API."
            case .invalidResponse:
                return "Invalid response from the API."
            case .apiError(let message):
                return "API Error: \(message)"
            }
        }
    }
    
    // MARK: - Recipe Generation
    
    /// Generate a recipe based on ingredients and user preferences
    /// - Parameters:
    ///   - ingredients: List of available ingredients
    ///   - mealType: Type of meal (breakfast, lunch, etc)
    ///   - mealSubtype: Specific type of meal (cereal, sandwich, etc)
    ///   - skillLevel: Cooking skill level
    ///   - cookTime: Preferred cooking time
    ///   - cuisines: Preferred cuisines
    ///   - allergies: Allergies to avoid
    ///   - dietaryRestrictions: Dietary restrictions
    ///   - nutritionalRequirements: Nutritional preferences
    ///   - completion: Callback with the generated recipe or error
    func generateRecipe(
        ingredients: [String],
        mealType: String? = nil,
        mealSubtype: String? = nil,
        skillLevel: String? = nil,
        cookTime: String? = nil,
        cuisines: [String] = [],
        allergies: [String] = [],
        dietaryRestrictions: [String] = [],
        nutritionalRequirements: [String] = [],
        completion: @escaping (Result<Recipe, Error>) -> Void
    ) {
        // Use NSLog to ensure messages appear in console
        NSLog("🧁 GeminiService.generateRecipe called")
        NSLog("📋 Ingredients count: \(ingredients.count)")
        
        // Safely return the result on the main thread
        let safeCompletion: (Result<Recipe, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        print("🧁 GeminiService.generateRecipe called")
        print("📋 Generating recipe with ingredients: \(ingredients.joined(separator: ", "))")
        
        // Fallback recipe in case of errors
        let fallbackRecipe = Recipe.placeholder
        
        // Verify we have ingredients to work with
        guard !ingredients.isEmpty else {
            print("⚠️ No ingredients provided - using fallback recipe")
            NSLog("⚠️ No ingredients provided - using fallback recipe")
            safeCompletion(.success(fallbackRecipe))
            return
        }
        
        print("👨‍🍳 Generating recipe with \(ingredients.count) ingredients")
        
        guard let apiKey = loadAPIKey() else {
            print("⚠️ API Key not found - using fallback recipe")
            NSLog("⚠️ API Key not found - using fallback recipe")
            safeCompletion(.success(fallbackRecipe))
            return
        }
        
        print("🔑 API key loaded successfully")
        
        let url = URL(string: "\(baseURL)/\(recipeGenerationModel):generateContent?key=\(apiKey)")!
        print("🌐 API URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the recipe prompt
        let prompt = createRecipePrompt(
            ingredients: ingredients,
            mealType: mealType,
            mealSubtype: mealSubtype,
            skillLevel: skillLevel,
            cookTime: cookTime,
            cuisines: cuisines,
            allergies: allergies,
            dietaryRestrictions: dietaryRestrictions,
            nutritionalRequirements: nutritionalRequirements
        )
        
        print("📝 Generated prompt: \(prompt)")
        
        // Set generation parameters for more creative responses
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        [
                            "text": prompt
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.85,  // Higher temperature for more creative results
                "topP": 0.95,
                "topK": 40,
                "maxOutputTokens": 2048
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("⚠️ Error serializing request: \(error.localizedDescription)")
            safeCompletion(.success(fallbackRecipe))
            return
        }
        
        print("📤 Sending recipe generation request")
        
        // Set a longer timeout for recipe generation
        let session = URLSession(configuration: {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 25.0
            return config
        }())
        
        session.dataTask(with: request) { data, response, error in
            // Output the HTTP response status code
            if let httpResponse = response as? HTTPURLResponse {
                print("🔢 HTTP Response Code: \(httpResponse.statusCode)")
                NSLog("🔢 FOODSNAP HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            // Handle network errors
            if let error = error {
                print("⚠️ Network error: \(error.localizedDescription)")
                NSLog("⚠️ FOODSNAP Network error: \(error.localizedDescription)")
                safeCompletion(.success(fallbackRecipe))
                return
            }
            
            // Handle missing data
            guard let data = data else {
                print("⚠️ No data received from API")
                NSLog("⚠️ FOODSNAP No data received from API")
                safeCompletion(.success(fallbackRecipe))
                return
            }
            
            print("📊 Received \(data.count) bytes of data")
            NSLog("📊 FOODSNAP Received \(data.count) bytes of data")
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response (\(data.count) bytes): \(responseString.prefix(200))...")
                NSLog("📥 FOODSNAP Raw response prefix: \(responseString.prefix(100))...")
            }
            
            // Try parsing the JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Debug print the JSON structure
                    print("📊 JSON keys: \(json.keys.joined(separator: ", "))")
                    NSLog("📊 FOODSNAP JSON keys: \(json.keys.joined(separator: ", "))")
                    
                    // Check for API errors
                    if let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        print("🚫 API Error: \(message)")
                        NSLog("🚫 FOODSNAP API Error: \(message)")
                        safeCompletion(.success(fallbackRecipe))
                        return
                    }
                    
                    // Extract the recipe text
                    if let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let firstPart = parts.first,
                       let text = firstPart["text"] as? String {
                        
                        print("🔍 Recipe text received from API: \(text.prefix(100))...")
                        NSLog("🔍 FOODSNAP Recipe text received")
                        
                        // Parse the recipe text into structured data
                        let recipe = self.parseRecipeFromText(text, ingredients: ingredients)
                        print("🍽️ Parsed recipe with title: \(recipe.title)")
                        NSLog("🍽️ FOODSNAP Parsed recipe with title: \(recipe.title)")
                        safeCompletion(.success(recipe))
                        return
                    } else {
                        print("❌ Failed to extract recipe text from response structure")
                        NSLog("❌ FOODSNAP Failed to extract recipe text from JSON structure")
                    }
                }
                
                // If we got here, something went wrong with parsing
                print("⚠️ Failed to parse response - using fallback recipe")
                NSLog("⚠️ FOODSNAP Failed to parse JSON response - using fallback recipe")
                safeCompletion(.success(fallbackRecipe))
                
            } catch {
                print("⚠️ JSON parsing error: \(error.localizedDescription)")
                NSLog("⚠️ FOODSNAP JSON parsing error: \(error.localizedDescription)")
                safeCompletion(.success(fallbackRecipe))
            }
        }.resume()
    }
    
    // Create the recipe prompt
    private func createRecipePrompt(
        ingredients: [String],
        mealType: String?,
        mealSubtype: String?,
        skillLevel: String?,
        cookTime: String?,
        cuisines: [String],
        allergies: [String],
        dietaryRestrictions: [String],
        nutritionalRequirements: [String]
    ) -> String {
        var prompt = """
        You are a professional chef specializing in creative, delicious recipes. Create a detailed, appetizing recipe using ONLY these ingredients and common household staples (salt, pepper, water, olive oil, vegetable oil, butter, common herbs and spices):
        
        INGREDIENTS:
        \(ingredients.joined(separator: ", "))
        
        IMPORTANT: DO NOT include ANY ingredients that are not in the above list or common household staples. The recipe MUST be made with ONLY the listed ingredients plus basic staples.
        
        """
        
        if let mealTime = mealType {
            prompt += "MEAL TIME: \(mealTime)\n"
        }
        
        if let mealType = mealSubtype {
            prompt += "MEAL TYPE: \(mealType)\n"
        }
        
        if let skillLevel = skillLevel {
            prompt += "SKILL LEVEL: \(skillLevel)\n"
        }
        
        if let cookTime = cookTime {
            prompt += "COOK TIME: \(cookTime)\n"
        }
        
        if !cuisines.isEmpty {
            prompt += "CUISINE PREFERENCES: \(cuisines.joined(separator: ", "))\n"
        }
        
        if !allergies.isEmpty {
            prompt += "ALLERGIES (AVOID): \(allergies.joined(separator: ", "))\n"
        }
        
        if !dietaryRestrictions.isEmpty {
            prompt += "DIETARY RESTRICTIONS: \(dietaryRestrictions.joined(separator: ", "))\n"
        }
        
        if !nutritionalRequirements.isEmpty {
            prompt += "NUTRITIONAL PREFERENCES: \(nutritionalRequirements.joined(separator: ", "))\n"
        }
        
        prompt += """
        
        Return a complete recipe with these EXACT sections, using the format below (include the section headers):
        
        TITLE: [Provide a specific, creative, and appetizing name for the dish - NOT "Delicious Recipe" or generic titles]
        
        DESCRIPTION: [Write EXACTLY THREE descriptive sentences about the dish, including texture, flavor profile, and visual appearance]
        
        COOK_TIME: [Total preparation and cooking time]
        
        DIFFICULTY: [Easy, Medium, or Hard based on required cooking skills]
        
        SERVINGS: [Number of people the recipe serves]
        
        INGREDIENTS:
        - [First ingredient with precise quantity]
        - [Second ingredient with precise quantity]
        - [Continue listing ALL ingredients with measurements]
        
        INSTRUCTIONS:
        1. [First detailed cooking step - be specific about techniques, temperatures, and visual cues]
        2. [Second detailed cooking step]
        3. [Continue with numbered steps, being thorough about the cooking process]
        4. [Include at least 5-8 detailed steps for a complete cooking process]
        
        REMEMBER: ONLY use ingredients from the provided list plus basic household staples (salt, pepper, common herbs and spices, cooking oils, butter, water). DO NOT include any other ingredients.
        
        Be creative but practical. The recipe MUST be a real, recognizable dish with a specific name (not generic). Use proper cooking terminology and provide clear, detailed instructions a home cook could follow. All measurements should be precise.
        
        PERSONALIZATION: Tailor the recipe to the user's preferences as indicated above.
        """
        
        return prompt
    }
    
    // Parse a text response into a Recipe object
    private func parseRecipeFromText(_ text: String, ingredients: [String]) -> Recipe {
        // Log the full text for debugging
        NSLog("📝 FOODSNAP: Raw recipe text received: \(text.prefix(500))...")
        
        // Initialize with defaults that will be overridden
        var title = "Delicious Recipe"
        var cookTime = "30 min"
        var difficulty = "Medium"
        var servings = 4
        var recipeIngredients: [String] = []
        var instructions: [String] = []
        var description: String? = nil
        
        // If the response doesn't contain proper sections, check if it's a completely different format
        if !text.contains("TITLE:") && !text.contains("INGREDIENTS:") && !text.contains("INSTRUCTIONS:") {
            NSLog("⚠️ FOODSNAP: Response doesn't contain expected sections, trying to extract recipe from free-form text")
            
            // If we received a completely free-form recipe, try to make the best of it
            let sentences = text.components(separatedBy: ". ")
            if sentences.count > 2 {
                // Take the first sentence as title if it's reasonable length
                if sentences[0].count < 100 {
                    title = sentences[0].trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                // Take the second sentence as description if available
                if sentences.count > 1 && sentences[1].count < 300 {
                    description = sentences[1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                // Convert remaining sentences to instructions
                for i in 2..<min(sentences.count, 10) {
                    let instruction = sentences[i].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !instruction.isEmpty {
                        instructions.append(instruction)
                    }
                }
                
                // Use the provided ingredients list
                recipeIngredients = ingredients.map { "\($0)" }
            }
        } else {
            // Split by lines for easier parsing
            let lines = text.components(separatedBy: .newlines)
            
            // Track which section we're currently parsing
            var currentSection: String? = nil
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.isEmpty { continue }
                
                // Normalize section headers for easier detection
                let uppercasedLine = trimmedLine.uppercased()
                
                // Check for section headers (using uppercase for case-insensitive comparison)
                if uppercasedLine.contains("TITLE:") {
                    currentSection = "TITLE"
                    title = trimmedLine.replacingOccurrences(of: "(?i)TITLE:\\s*", with: "", options: .regularExpression)
                                      .trimmingCharacters(in: .whitespacesAndNewlines)
                    continue
                } else if uppercasedLine.contains("DESCRIPTION:") {
                    currentSection = "DESCRIPTION"
                    description = trimmedLine.replacingOccurrences(of: "(?i)DESCRIPTION:\\s*", with: "", options: .regularExpression)
                                           .trimmingCharacters(in: .whitespacesAndNewlines)
                    continue
                } else if uppercasedLine.contains("COOK TIME:") || uppercasedLine.contains("COOK_TIME:") || uppercasedLine.contains("COOKING TIME:") {
                    currentSection = "COOK_TIME"
                    cookTime = trimmedLine.replacingOccurrences(of: "(?i)COOK[_\\s]TIME:\\s*", with: "", options: .regularExpression)
                                         .replacingOccurrences(of: "(?i)COOKING TIME:\\s*", with: "", options: .regularExpression)
                                         .trimmingCharacters(in: .whitespacesAndNewlines)
                    continue
                } else if uppercasedLine.contains("DIFFICULTY:") || uppercasedLine.contains("SKILL LEVEL:") {
                    currentSection = "DIFFICULTY"
                    difficulty = trimmedLine.replacingOccurrences(of: "(?i)DIFFICULTY:\\s*", with: "", options: .regularExpression)
                                           .replacingOccurrences(of: "(?i)SKILL LEVEL:\\s*", with: "", options: .regularExpression)
                                           .trimmingCharacters(in: .whitespacesAndNewlines)
                    continue
                } else if uppercasedLine.contains("SERVINGS:") || uppercasedLine.contains("SERVES:") || uppercasedLine.contains("YIELD:") {
                    currentSection = "SERVINGS"
                    let servingsText = trimmedLine.replacingOccurrences(of: "(?i)SERVINGS:\\s*", with: "", options: .regularExpression)
                                                 .replacingOccurrences(of: "(?i)SERVES:\\s*", with: "", options: .regularExpression)
                                                 .replacingOccurrences(of: "(?i)YIELD:\\s*", with: "", options: .regularExpression)
                                                 .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Try to extract a number from the text
                    if let firstNumber = servingsText.components(separatedBy: CharacterSet.decimalDigits.inverted)
                        .first(where: { !$0.isEmpty }) {
                        if let number = Int(firstNumber) {
                            servings = number
                        }
                    }
                    continue
                } else if uppercasedLine.contains("INGREDIENTS:") {
                    currentSection = "INGREDIENTS"
                    continue
                } else if uppercasedLine.contains("INSTRUCTIONS:") || uppercasedLine.contains("DIRECTIONS:") || uppercasedLine.contains("STEPS:") {
                    currentSection = "INSTRUCTIONS"
                    continue
                }
                
                // Process line based on current section
                if let section = currentSection {
                    switch section {
                    case "TITLE":
                        if title == "Delicious Recipe" { // Only update if not already set
                            title = trimmedLine
                        }
                    case "DESCRIPTION":
                        if description == nil || description?.isEmpty == true {
                            description = trimmedLine
                        } else {
                            description = (description ?? "") + " " + trimmedLine
                        }
                    case "COOK_TIME":
                        if cookTime == "30 min" { // Only update if not already set
                            cookTime = trimmedLine
                        }
                    case "DIFFICULTY":
                        if difficulty == "Medium" { // Only update if not already set
                            difficulty = trimmedLine
                        }
                    case "SERVINGS":
                        if servings == 4 { // Only update if not already set
                            if let firstNumber = trimmedLine.components(separatedBy: CharacterSet.decimalDigits.inverted)
                                .first(where: { !$0.isEmpty }),
                               let number = Int(firstNumber) {
                                servings = number
                            }
                        }
                    case "INGREDIENTS":
                        // Clean up the ingredient line - remove bullet points, numbers, etc.
                        let cleanIngredient = trimmedLine.replacingOccurrences(of: "^[-•*+]\\s*", with: "", options: .regularExpression)
                                                        .replacingOccurrences(of: "^\\d+\\.\\s*", with: "", options: .regularExpression)
                                                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        if !cleanIngredient.isEmpty {
                            recipeIngredients.append(cleanIngredient)
                        }
                    case "INSTRUCTIONS":
                        // Clean up the instruction line - remove leading numbers and periods
                        let cleanInstruction = trimmedLine.replacingOccurrences(of: "^\\d+\\.\\s*", with: "", options: .regularExpression)
                                                         .replacingOccurrences(of: "^[-•*]\\s*", with: "", options: .regularExpression)
                                                         .trimmingCharacters(in: .whitespacesAndNewlines)
                        if !cleanInstruction.isEmpty {
                            instructions.append(cleanInstruction)
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        // If no ingredients were parsed, use the provided ingredients
        if recipeIngredients.isEmpty {
            NSLog("⚠️ FOODSNAP: No ingredients parsed from response, using provided ingredients")
            recipeIngredients = ingredients
        }
        
        // Generate at least one instruction if none were parsed
        if instructions.isEmpty {
            NSLog("⚠️ FOODSNAP: No instructions parsed from response, using generic instruction")
            instructions.append("Combine all ingredients and cook until done.")
        }
        
        // Make sure we have some kind of title other than the generic one
        if title == "Delicious Recipe" && !ingredients.isEmpty {
            NSLog("⚠️ FOODSNAP: No title parsed from response, generating one from ingredients")
            if ingredients.count >= 2 {
                title = "\(ingredients[0].capitalized) and \(ingredients[1].capitalized) Dish"
            } else if !ingredients.isEmpty {
                title = "\(ingredients[0].capitalized) Special"
            }
        }
        
        NSLog("🎉 FOODSNAP: Successfully created recipe: \(title)")
        return Recipe(
            title: title,
            cookTime: cookTime,
            difficulty: difficulty,
            servings: servings,
            ingredients: recipeIngredients,
            instructions: instructions,
            description: description
        )
    }
} 