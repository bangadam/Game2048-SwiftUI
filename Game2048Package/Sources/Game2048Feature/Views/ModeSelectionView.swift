import SwiftUI

/// Simple start screen for the game
public struct ModeSelectionView: View {
    let onStartGame: (GameConfiguration) -> Void

    public init(onStartGame: @escaping (GameConfiguration) -> Void) {
        self.onStartGame = onStartGame
    }

    public var body: some View {
        ZStack {
            Color(hex: "F5F0FF").ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Header
                VStack(spacing: 16) {
                    Text("2048")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "6B5B7A"))

                    Text("Join the numbers and reach 2048!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "6B5B7A").opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Start Button
                Button(action: startGame) {
                    Text("Start Game")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(hex: "B088C0"))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }

    private func startGame() {
        onStartGame(GameConfiguration())
    }
}

#Preview {
    ModeSelectionView { _ in }
}
