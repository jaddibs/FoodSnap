# FoodSnap Design Framework

## 1. Color Scheme

### Primary Palette - Fresh & Natural Feel
- **Primary Green**: `#A8D5BA` - Freshness, health, nature
- **Secondary Green**: `#CFE8CF` - Softer variant for backgrounds and accents
- **Accent Terracotta**: `#D97B66` - Warm, appetizing color for CTAs
- **Background Cream**: `#FAF9F6` - Soft, neutral background

### Alternative Palette - Modern & Clean Feel
- **Primary Blue**: `#7FB3D5` - Trust, clarity, calm
- **Primary Teal**: `#58BFA9` - Fresh, modern alternative
- **Accent Coral**: `#FF6F61` - Vibrant, attention-grabbing for CTAs
- **Background Light**: `#F5F5F5` - Clean, minimal background

### Dark Mode
- **Dark Background**: `#2E2E2E` - Rich dark background, not pure black
- **Accent Lime**: `#BFFF00` - Vibrant accent for dark mode
- **Soft White**: `#F0F0F0` - Text color, not harsh white

## 2. Typography

### Headings
- Large Title: System Rounded, Large Title, Bold
- Title: System Rounded, Title, Semibold
- Title 2: System Rounded, Title 2, Semibold
- Title 3: System Rounded, Title 3, Semibold

### Body Text
- Body: System Default, Body
- Callout: System Default, Callout
- Subheadline: System Default, Subheadline
- Footnote: System Default, Footnote

## 3. UI Components

### Buttons
- **Primary Button**: Accent color background, white text, rounded corners
- **Secondary Button**: White background, primary color border, primary color text

### Cards
- **Standard Card**: White background, soft shadow, rounded corners
- **Recipe Card**: Image, title, quick info, soft shadow, rounded corners

### Navigation
- **Bottom Tab Bar**: 4 core tabs with SF Symbols icons
  - Home (Scan/Results) - `camera.fill`
  - Saved Recipes - `bookmark.fill`
  - Explore (curated ideas) - `fork.knife`
  - Profile/Preferences - `person.fill`
  
  Implementation:
  ```swift
  TabView(selection: $selectedTab) {
      HomeView()
          .tabItem {
              Label("Home", systemImage: "camera.fill")
          }
          .tag(0)
      
      SavedRecipesView()
          .tabItem {
              Label("Saved", systemImage: "bookmark.fill")
          }
          .tag(1)
      
      ExploreView()
          .tabItem {
              Label("Explore", systemImage: "fork.knife")
          }
          .tag(2)
      
      ProfileView()
          .tabItem {
              Label("Profile", systemImage: "person.fill")
          }
          .tag(3)
  }
  .accentColor(Theme.Colors.accent)
  ```
  
  Styling:
  ```swift
  .onAppear {
      let appearance = UITabBarAppearance()
      appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
      appearance.backgroundColor = UIColor(Theme.Colors.background.opacity(0.9))
      
      let itemAppearance = UITabBarItemAppearance()
      itemAppearance.normal.iconColor = UIColor(Theme.Colors.secondaryText)
      itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.Colors.secondaryText)]
      itemAppearance.selected.iconColor = UIColor(Theme.Colors.accent)
      itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.Colors.accent)]
      
      appearance.stackedLayoutAppearance = itemAppearance
      appearance.inlineLayoutAppearance = itemAppearance
      appearance.compactInlineLayoutAppearance = itemAppearance
      
      UITabBar.appearance().standardAppearance = appearance
      UITabBar.appearance().scrollEdgeAppearance = appearance
  }
  ```

### Image Handling
- **Image Preview**: Displayed with soft shadow and rounded corners
- **Camera Interface**: Clean, minimal, focus on food

## 4. Design Principles

### Minimalism
- Remove clutter
- Keep CTAs prominent and single-action
- Use white space effectively

### Visual Hierarchy
- Use typography, size, and color to guide user flow
- Keep important actions accessible
- Prioritize content over decoration

### Microinteractions
- Subtle animation for button presses
- Visual feedback for scanning
- Haptic feedback for important actions

### Accessibility
- Support Dynamic Type
- Ensure proper contrast ratios
- Support VoiceOver
- Dark mode support

## 5. Page Structure

### Home Screen
- App title and tagline
- Camera/upload interface
- Recent activity (if applicable)

### Scanner Interface
- Live camera view with a centered bounding box
- Simple CTA: "Scan Ingredients"
- Instant preview of detected items in chips

### Recipe Detail
- Hero image
- Ingredient list with "match" tags
- Step-by-step instructions
- Save/share options
- Generate shopping list option

### Recipe Results
- Grid/list of recipe options
- Quick filter options
- Sort by relevance, popularity, etc.

### Saved Recipes
- Collection of saved recipes in a grid/list format
- Quick filter/search functionality
- Sort by date saved, name, etc.

### Explore Tab
- Curated recipe suggestions
- Categories and collections
- Trending recipes

### Profile Tab
- User preferences
- Dietary restrictions
- Saved items
- App settings

## 6. SF Symbols Usage

### Core Icons
- Camera/Home: `camera.fill`
- Gallery: `photo.fill`
- Search/Analyze: `magnifyingglass`
- Save: `bookmark.fill`
- Settings: `gear`
- Recipes/Explore: `fork.knife`
- Share: `square.and.arrow.up`
- Profile: `person.fill`

## 7. Design Implementation Notes

### SwiftUI Implementation
- Use the Theme struct for consistent design application
- Apply custom button styles and view modifiers
- Leverage environment values for dynamic theming
- Use SF Symbols for consistent iconography

### Animation Guidelines
- Keep animations subtle and purposeful
- Use standard animation timings
- Avoid excessive or distracting animations

### Tab-based Navigation
- Organize app content into logical tabs
- Provide clear visual indication of the current tab
- Support fluid navigation between related tabs
- Maintain state when switching between tabs 