import SwiftUI

struct WelcomeView: View {
    @State private var navigateToSnapIngredients = false
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // App Logo and Name
                    VStack(spacing: Theme.Dimensions.spacing) {
                        Image(systemName: "camera.aperture")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.Colors.accent)
                            .padding(.bottom, 4)
                        
                        Text("Welcome to FoodSnap")
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Theme.Colors.text)
                            .multilineTextAlignment(.center)
                        
                        Text("Turn your ingredients into delicious recipes")
                            .font(Theme.Typography.title3)
                            .foregroundColor(Theme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // App Steps
                    VStack(spacing: Theme.Dimensions.spacing * 1.5) {
                        // Step 1
                        FeatureStep(
                            icon: "camera.fill",
                            iconColor: Theme.Colors.primary,
                            title: "Snap Ingredients",
                            description: "Take a photo of your ingredients using your camera"
                        )
                        
                        // Step 2
                        FeatureStep(
                            icon: "list.bullet.clipboard",
                            iconColor: Theme.Colors.accent,
                            title: "Manage Mise en Place",
                            description: "Review identified ingredients and set preferences"
                        )
                        
                        // Step 3
                        FeatureStep(
                            icon: "fork.knife",
                            iconColor: Theme.Colors.primary,
                            title: "Get a Recipe",
                            description: "Discover delicious recipes matching your ingredients"
                        )
                    }
                    .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                    
                    Spacer()
                    
                    // Get Started Button
                    NavigationLink(destination: SnapIngredients(), isActive: $navigateToSnapIngredients) {
                        Button(action: {
                            navigateToSnapIngredients = true
                        }) {
                            HStack {
                                Image(systemName: "camera")
                                    .font(.headline)
                                Text("Snap Ingredients")
                                    .font(Theme.Typography.title3)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, Theme.Dimensions.horizontalPadding)
                        .padding(.vertical, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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

// Feature step component for the three main app steps
struct FeatureStep: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Dimensions.largeSpacing) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(iconColor)
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.text)
                
                Text(description)
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 4)
            
            Spacer()
        }
        .padding(Theme.Dimensions.horizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 6, x: 0, y: 2)
        )
    }
}

#Preview {
    WelcomeView()
} 