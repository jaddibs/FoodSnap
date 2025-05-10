# FoodSnap

FoodSnap is an iOS application that transforms your food ingredients into delicious recipes with just a snap.

## Features

- **Ingredient Detection**: Take photos or upload images of your ingredients and let AI identify them
- **Customizable Preferences**: Refine ingredients, set meal types, skill levels, and dietary restrictions
- **Recipe Generation**: Receive personalized recipes based on your ingredients and preferences
- **Beautiful UI**: Clean, minimalist design with full dark mode support

## App Flow

1. **Welcome Screen**: Introduction to the app's features
2. **Snap Screen**: Capture or upload up to 3 photos of ingredients
3. **Ingredients Management**: Review detected ingredients, add any missing ones, and set preferences
4. **Recipe Results**: View generated recipe with image, ingredients, and instructions

## Technical Details

### Core Technologies
- **Swift & SwiftUI**: Native iOS development
- **AVFoundation**: Camera access and image processing
- **Gemini API**: AI-powered ingredient detection and recipe generation
- **Stability AI**: AI image generation for recipes

### Features
- Dynamic light/dark mode support
- Real-time ingredient detection
- Customizable recipe preferences including:
  - Meal type (breakfast, lunch, dinner, snack)
  - Skill level (beginner, intermediate, advanced)
  - Cook time preferences
  - Cuisine preferences
  - Allergy handling
  - Dietary restrictions
  - Nutritional requirements

### Architecture
- Clean SwiftUI implementation with state management
- API services for AI integration
- Consistent theme system for UI

## Getting Started

1. Clone the repository
2. Add API keys:
   - Create a `.env` file in the project root
   - Add `GEMINI_API_KEY=your_key_here` for ingredient detection and recipe generation
   - Add `STABILITY_API_KEY=your_key_here` for recipe image generation
3. Open the project in Xcode and run on a simulator or device

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Camera access for ingredient detection
- Photo library access for uploading food images

## Focus on Sustainability

FoodSnap helps reduce food waste by suggesting recipes for ingredients you already have, promoting sustainable cooking practices. 