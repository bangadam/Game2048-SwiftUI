import SwiftUI
import UIKit

/// Main game view that contains the board, score, and controls
public struct GameView: View {
    @State private var game: GameModel
    @State private var previousScore: Int = 0
    let onBack: (() -> Void)?

    public init(configuration: GameConfiguration = .default, onBack: (() -> Void)? = nil) {
        self._game = State(initialValue: GameModel(configuration: configuration))
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            Color(hex: "F5F0FF").ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("2048")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "6B5B7A"))

                        Text("Join the numbers!")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(hex: "6B5B7A"))
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        ScoreView(title: "SCORE", score: game.score)
                        ScoreView(title: "BEST", score: game.highScore)
                    }
                }
                .padding(.horizontal, 24)

                // Controls
                HStack {
                    if let onBack = onBack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "6B5B7A"))
                        }
                    }

                    Spacer()

                    ActionButton(icon: "arrow.counterclockwise", title: "New Game") {
                        withAnimation {
                            game.newGame()
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Board
                BoardView(tiles: game.board.tiles, boardSize: game.boardSize) { direction in
                    // Wrap move in animation explicitly
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        game.move(direction)
                    }
                }

                Spacer()
            }
            .padding(.top, 20)

            // Overlays
            if game.hasWon {
                OverlayView(
                    title: "You Win!",
                    message: "2048 achieved!",
                    buttonTitle: "Keep Playing",
                    action: { game.continueAfterWin() }
                )
            } else if game.isGameOver {
                OverlayView(
                    title: "Game Over",
                    message: "Try again?",
                    buttonTitle: "New Game",
                    action: {
                        withAnimation {
                            game.newGame()
                        }
                    }
                )
            }
        }
        // Trigger haptics on board change
        .onChange(of: game.board) { _, _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            AudioManager.shared.playSound(.tileMove)
        }
        // Play merge sound when score increases
        .onChange(of: game.score) { oldScore, newScore in
            if newScore > oldScore {
                AudioManager.shared.playSound(.tileMerge)
            }
            previousScore = newScore
        }
        // Play win/game over sounds on status change
        .onChange(of: game.status) { oldStatus, newStatus in
            switch newStatus {
            case .won:
                AudioManager.shared.playSound(.win)
            case .gameOver:
                AudioManager.shared.playSound(.gameOver)
            default:
                break
            }
        }
        // Start background music when view appears
        .onAppear {
            AudioManager.shared.playBackgroundMusic()
        }
        // Stop background music when view disappears
        .onDisappear {
            AudioManager.shared.stopBackgroundMusic()
        }
        // Keyboard control for iPad and Simulator
        .focusable()
        .onKeyPress(.leftArrow) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                game.move(.left)
            }
            return .handled
        }
        .onKeyPress(.rightArrow) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                game.move(.right)
            }
            return .handled
        }
        .onKeyPress(.upArrow) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                game.move(.up)
            }
            return .handled
        }
        .onKeyPress(.downArrow) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                game.move(.down)
            }
            return .handled
        }
    }
}

// Helper components
struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(hex: "B088C0"))
            .cornerRadius(8)
        }
    }
}

struct OverlayView: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "FF85A2").opacity(0.5)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)

                Text(message)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white)

                Button(action: action) {
                    Text(buttonTitle)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "6B5B7A"))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
            }
            .padding()
            .transition(.scale.combined(with: .opacity))
        }
    }
}

#Preview {
    GameView()
}
