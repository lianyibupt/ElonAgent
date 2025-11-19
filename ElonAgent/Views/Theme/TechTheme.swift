import SwiftUI

struct LiquidTheme {
    // Soft, watery colors
    static let backgroundStart = Color(hex: "F0F4F8") // Light Blue-Grey
    static let backgroundEnd = Color(hex: "D9E2EC")   // Slightly darker
    
    static let accent1 = Color(hex: "4FACFE") // Light Blue
    static let accent2 = Color(hex: "00F2FE") // Cyan
    static let accent3 = Color(hex: "A18CD1") // Soft Purple
    static let accent4 = Color(hex: "FBC2EB") // Soft Pink
    
    static let textPrimary = Color(hex: "102A43") // Dark Blue
    static let textSecondary = Color(hex: "486581") // Grey Blue
    
    static let cardBackground = Color.white.opacity(0.7)
    
    static let gradientPrimary = LinearGradient(
        gradient: Gradient(colors: [accent1, accent2]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct LiquidBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [LiquidTheme.backgroundStart, LiquidTheme.backgroundEnd]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated Blobs
            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(LiquidTheme.accent1.opacity(0.4))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: animate ? -100 : 100, y: animate ? -100 : 50)
                    
                    Circle()
                        .fill(LiquidTheme.accent3.opacity(0.3))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: animate ? 150 : -50, y: animate ? 100 : -100)
                    
                    Circle()
                        .fill(LiquidTheme.accent2.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .blur(radius: 40)
                        .offset(x: animate ? -50 : 150, y: animate ? 200 : 0)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

struct LiquidCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Material.ultraThinMaterial)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
}

extension View {
    func liquidCardStyle() -> some View {
        self.modifier(LiquidCardModifier())
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
