import SwiftUI

/// Root view that manages navigation between onboarding, mode selection and gameplay
public struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentConfiguration: GameConfiguration?

    public init() {}

    public var body: some View {
        if !hasSeenOnboarding {
            OnboardingView {
                withAnimation(.easeInOut(duration: 0.3)) {
                    hasSeenOnboarding = true
                }
            }
            .transition(.opacity)
        } else if let configuration = currentConfiguration {
            GameView(configuration: configuration) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentConfiguration = nil
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .trailing)
            ))
        } else {
            ModeSelectionView { configuration in
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentConfiguration = configuration
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .leading)
            ))
        }
    }
}

#Preview {
    RootView()
}
