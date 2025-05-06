import SwiftUI

/// Defines the design system for the FoodSnap app
struct Theme {
    // MARK: - Color Scheme
    struct Colors {
        // Fresh & Natural Feel
        static let primaryGreen = Color("PrimaryGreen") // #A8D5BA
        static let secondaryGreen = Color("SecondaryGreen") // #CFE8CF
        static let accentTerracotta = Color("AccentTerracotta") // #D97B66
        static let backgroundCream = Color("BackgroundCream") // #FAF9F6
        
        // Modern & Clean Feel
        static let primaryBlue = Color("PrimaryBlue") // #7FB3D5
        static let primaryTeal = Color("PrimaryTeal") // #58BFA9
        static let accentCoral = Color("AccentCoral") // #FF6F61
        static let backgroundLight = Color("BackgroundLight") // #F5F5F5
        
        // Dark Mode
        static let darkBackground = Color("DarkBackground") // #2E2E2E
        static let accentLime = Color("AccentLime") // #BFFF00
        static let softWhite = Color("SoftWhite") // #F0F0F0
        
        // Current theme - can be switched based on preference
        static let primary = primaryGreen
        static let secondary = secondaryGreen
        static let accent = accentTerracotta
        
        // Dynamic colors that adapt to color scheme
        static var background: Color {
            Color(UIColor { traits in
                traits.userInterfaceStyle == .dark ? UIColor(darkBackground) : UIColor(backgroundCream)
            })
        }
        
        static var text: Color {
            Color(UIColor { traits in
                traits.userInterfaceStyle == .dark ? UIColor(softWhite) : UIColor(Color.black.opacity(0.85))
            })
        }
        
        static var secondaryText: Color {
            Color(UIColor { traits in
                traits.userInterfaceStyle == .dark ? UIColor(softWhite.opacity(0.7)) : UIColor(Color.black.opacity(0.6))
            })
        }
    }
    
    // MARK: - Typography
    struct Typography {
        // Heading fonts
        static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title = Font.system(.title, design: .rounded).weight(.semibold)
        static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
        static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
        
        // Body fonts
        static let body = Font.system(.body, design: .default)
        static let callout = Font.system(.callout, design: .default)
        static let subheadline = Font.system(.subheadline, design: .default)
        static let footnote = Font.system(.footnote, design: .default)
    }
    
    // MARK: - Dimensions
    struct Dimensions {
        static let cornerRadius: CGFloat = 12
        static let largeCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 50
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let spacing: CGFloat = 8
        static let largeSpacing: CGFloat = 16
    }
    
    // MARK: - Animations
    struct Animations {
        static let standard = Animation.easeInOut(duration: 0.3)
        static let quick = Animation.easeOut(duration: 0.2)
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.title3)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Dimensions.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                    .fill(Theme.Colors.accent)
                    .opacity(configuration.isPressed ? 0.8 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(Theme.Animations.quick, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.title3)
            .foregroundColor(Theme.Colors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Dimensions.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                    .stroke(Theme.Colors.primary, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                            .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(Theme.Animations.quick, value: configuration.isPressed)
    }
}

// MARK: - Custom Modifiers
struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(Theme.Dimensions.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Dimensions.largeCornerRadius)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, Theme.Dimensions.horizontalPadding)
            .padding(.vertical, Theme.Dimensions.verticalPadding)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }
} 