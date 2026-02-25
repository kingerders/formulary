import SwiftUI

/// Splash screen with animated logo, gradient background, and floating math symbols
struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoScale = 0.6
    @State private var logoOpacity = 0.0
    @State private var textOpacity = 0.0
    @State private var symbolsOpacity = 0.0
    @State private var pulseScale = 1.0

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // Deep gradient background
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.10, green: 0.11, blue: 0.28), location: 0),
                        .init(color: Color(red: 0.13, green: 0.20, blue: 0.40), location: 0.45),
                        .init(color: Color(red: 0.10, green: 0.32, blue: 0.38), location: 1),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Subtle grid pattern
                PatternOverlay()
                    .opacity(0.4)
                    .ignoresSafeArea()

                // Floating math symbols
                SplashSymbolsOverlay()
                    .opacity(symbolsOpacity)

                // Center content
                VStack(spacing: 0) {
                    Spacer()

                    // Logo icon
                    ZStack {
                        // Glow ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.appPrimary.opacity(0.5), Color.appSecondary.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 130, height: 130)
                            .scaleEffect(pulseScale)

                        // App icon from bundle
                        if let uiImage = UIImage(named: "AppLogo") ?? loadAppIcon() {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 110, height: 110)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: Color.appPrimary.opacity(0.4), radius: 20, x: 0, y: 8)
                        } else {
                            // Fallback logo design
                            ZStack {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appPrimary, Color.appSecondary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 110, height: 110)
                                    .shadow(color: Color.appPrimary.opacity(0.4), radius: 20, x: 0, y: 8)

                                VStack(spacing: 2) {
                                    Text("𝑓")
                                        .font(.system(size: 46, weight: .light, design: .serif))
                                        .foregroundStyle(.white)
                                    Text("(x)")
                                        .font(.system(size: 16, weight: .light, design: .serif))
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                        }
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                    // App name
                    Text("Formulary")
                        .font(.custom("Quicksand-Bold", size: 38))
                        .foregroundStyle(.white)
                        .padding(.top, 20)
                        .opacity(textOpacity)

                    // Slogan
                    Text("Your Science & Engineering Companion")
                        .font(.custom("Quicksand-Medium", size: 15))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                        .opacity(textOpacity)

                    Spacer()

                    // Bottom indicator
                    ProgressView()
                        .tint(.white.opacity(0.4))
                        .padding(.bottom, 50)
                        .opacity(textOpacity)
                }
            }
            .onAppear {
                // Staggered animations
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                    textOpacity = 1.0
                }
                withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                    symbolsOpacity = 1.0
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseScale = 1.08
                }

                // Transition after 2.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        self.isActive = true
                    }
                }
            }
        }
    }

    /// Try to load the app icon from the asset catalog
    private func loadAppIcon() -> UIImage? {
        // iOS 16+ method to read app icon from asset catalog
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last,
           let uiImage = UIImage(named: lastIcon) {
            return uiImage
        }
        return nil
    }
}

// MARK: - Floating Symbols for Splash

struct SplashSymbolsOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Text("∫").font(.system(size: 36, design: .serif))
                    .foregroundStyle(.white.opacity(0.06))
                    .position(x: w * 0.15, y: h * 0.18)
                Text("Σ").font(.system(size: 28, design: .serif))
                    .foregroundStyle(.white.opacity(0.05))
                    .position(x: w * 0.82, y: h * 0.22)
                Text("∂").font(.system(size: 24, design: .serif))
                    .foregroundStyle(.white.opacity(0.05))
                    .position(x: w * 0.25, y: h * 0.78)
                Text("π").font(.system(size: 32, design: .serif))
                    .foregroundStyle(.white.opacity(0.04))
                    .position(x: w * 0.72, y: h * 0.75)
                Text("∇").font(.system(size: 22, design: .serif))
                    .foregroundStyle(.white.opacity(0.05))
                    .position(x: w * 0.55, y: h * 0.15)
                Text("λ").font(.system(size: 26, design: .serif))
                    .foregroundStyle(.white.opacity(0.04))
                    .position(x: w * 0.10, y: h * 0.50)
                Text("∞").font(.system(size: 30, design: .serif))
                    .foregroundStyle(.white.opacity(0.04))
                    .position(x: w * 0.88, y: h * 0.52)
                Text("Δ").font(.system(size: 24, design: .serif))
                    .foregroundStyle(.white.opacity(0.04))
                    .position(x: w * 0.40, y: h * 0.88)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
