//
//  StabilityService.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI
import Foundation

class StabilityService {
    private let baseURL = "https://api.stability.ai"
    private let engineId = "stable-diffusion-xl-1024-v1-0"
    
    /// Generate an image based on recipe description
    /// - Parameters:
    ///   - recipe: The recipe to generate an image for
    ///   - completion: Callback with the image data or error
    func generateImage(for recipe: Recipe, completion: @escaping (Result<Data, Error>) -> Void) {
        print("🎨 Generating image for recipe: \(recipe.title)")
        
        guard let apiKey = loadAPIKey() else {
            print("⚠️ Stability API Key not found")
            completion(.failure(StabilityError.apiKeyNotFound))
            return
        }
        
        let url = URL(string: "\(baseURL)/v1/generation/\(engineId)/text-to-image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create the prompt from recipe title and description
        let prompt = createPrompt(from: recipe)
        print("📝 Image generation prompt: \(prompt)")
        
        let requestBody: [String: Any] = [
            "text_prompts": [
                ["text": prompt, "weight": 1]
            ],
            "cfg_scale": 7,
            "height": 1024,
            "width": 1024,
            "samples": 1,
            "steps": 30
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("⚠️ Error serializing request: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        print("📤 Sending image generation request")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Always return to main thread for completion handler
            let returnResult: (Result<Data, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            // Handle network errors
            if let error = error {
                print("⚠️ Network error: \(error.localizedDescription)")
                returnResult(.failure(error))
                return
            }
            
            // Handle missing data
            guard let data = data else {
                print("⚠️ No data received from API")
                returnResult(.failure(StabilityError.noDataReceived))
                return
            }
            
            // Print raw response info for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("🔢 HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            // Try parsing the JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Check for API errors
                    if let errors = json["errors"] as? [[String: Any]], !errors.isEmpty {
                        if let firstError = errors.first, let message = firstError["message"] as? String {
                            print("🚫 API Error: \(message)")
                            returnResult(.failure(StabilityError.apiError(message)))
                            return
                        }
                    }
                    
                    // Extract the image data
                    if let artifacts = json["artifacts"] as? [[String: Any]], let firstArtifact = artifacts.first {
                        if let base64Image = firstArtifact["base64"] as? String, 
                           let imageData = Data(base64Encoded: base64Image) {
                            print("✅ Successfully generated image")
                            returnResult(.success(imageData))
                            return
                        }
                    }
                }
                
                // If we got here, something went wrong with parsing
                print("⚠️ Failed to parse response")
                returnResult(.failure(StabilityError.invalidResponse))
                
            } catch {
                print("⚠️ JSON parsing error: \(error.localizedDescription)")
                returnResult(.failure(error))
            }
        }.resume()
    }
    
    // Create an optimized prompt for food image generation
    private func createPrompt(from recipe: Recipe) -> String {
        var promptComponents = [String]()
        
        // Start with the title
        promptComponents.append("A professional food photography image of \(recipe.title),")
        
        // Add the description if available
        if let description = recipe.description {
            promptComponents.append(description)
        }
        
        // Add some key ingredients (but not all to avoid an overly complex prompt)
        let keyIngredients = recipe.ingredients.prefix(min(5, recipe.ingredients.count))
        if !keyIngredients.isEmpty {
            promptComponents.append("featuring \(keyIngredients.joined(separator: ", ")),")
        }
        
        // Add photography style details for better results
        promptComponents.append("professional food photography, high resolution, beautiful lighting, styled food plating, shallow depth of field, restaurant quality presentation")
        
        return promptComponents.joined(separator: " ")
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
                        print("🔑 Found Stability API key in .env file")
                        return apiKey
                    }
                } catch {
                    print("Error reading .env file: \(error)")
                }
            }
        }
        
        // Use env var as fallback (for development)
        if let apiKey = ProcessInfo.processInfo.environment["STABILITY_API_KEY"], !apiKey.isEmpty {
            print("🔑 Found Stability API key in environment variables")
            return apiKey
        }
        
        return nil
    }
    
    private func parseAPIKey(from contents: String) -> String? {
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix("STABILITY_API_KEY=") {
                let key = line.replacingOccurrences(of: "STABILITY_API_KEY=", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !key.isEmpty {
                    return key
                }
            }
        }
        return nil
    }
    
    enum StabilityError: Error, LocalizedError {
        case apiKeyNotFound
        case noDataReceived
        case invalidResponse
        case apiError(String)
        
        var errorDescription: String? {
            switch self {
            case .apiKeyNotFound:
                return "Stability API key not found. Please add it to your .env file."
            case .noDataReceived:
                return "No data received from the API."
            case .invalidResponse:
                return "Invalid response from the API."
            case .apiError(let message):
                return "API Error: \(message)"
            }
        }
    }
} 