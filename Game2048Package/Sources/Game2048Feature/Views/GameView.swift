import SwiftUI
import UIKit

/// Main game view that contains the board, score, and controls
public struct GameView: View {
    @State private var game: GameModel
    let onBack: (() -> Void)?

    public init(configuration: GameConfiguration = .default, onBack: (() -> Void)? = nil) {
        self._game = State(initialValue: GameModel(configuration: configuration))
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            Color(hex: "FAF8EF").ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("2048")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "776E65"))

                        Text("Join the numbers!")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(hex: "776E65"))
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        ScoreView(title: "SCORE", score: game.score)
                        ScoreView(title: "BEST", score: game.highScore)
                    }
                }
                .padding(.horizontal, 24)

                // Mode-specific indicators (Timer / Move Counter)
                if let remainingTime = game.remainingTime {
                    TimerView(seconds: remainingTime)
                } else if let remainingMoves = game.remainingMoves {
                    MoveCounterView(moves: remainingMoves)
                }

                // Controls
                HStack {
                    if let onBack = onBack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "776E65"))
                        }
                    }

                    if game.moveCount > 0 {
                        Text("Moves: \(game.moveCount)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "776E65"))
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
        // Timer for timed mode
        .task(id: game.status) {
            guard case .timed = game.configuration.mode else { return }
            guard game.status == .playing else { return }

            while !Task.isCancelled && game.status == .playing {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled && game.status == .playing {
                    game.decrementTimer()
                }
            }
        }
        // Trigger haptics on board change
        .onChange(of: game.board) { _, _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
            .background(Color(hex: "8F7A66"))
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
            Color(hex: "EDC22E").opacity(0.5)
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
                        .foregroundColor(Color(hex: "776E65"))
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

struct TimerView: View {
    let seconds: Int

    private var timeString: String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private var urgencyColor: Color {
        if seconds <= 10 {
            return .red
        } else if seconds <= 30 {
            return .orange
        }
        return Color(hex: "776E65")
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.system(size: 18, weight: .bold))
            Text(timeString)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
        }
        .foregroundColor(urgencyColor)
        .padding(.horizontal, 24)
        .animation(.easeInOut(duration: 0.3), value: seconds <= 10)
    }
}

struct MoveCounterView: View {
    let moves: Int

    private var urgencyColor: Color {
        if moves <= 3 {
            return .red
        } else if moves <= 10 {
            return .orange
        }
        return Color(hex: "776E65")
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 18, weight: .bold))
            Text("\(moves) moves left")
                .font(.system(size: 18, weight: .bold, design: .rounded))
        }
        .foregroundColor(urgencyColor)
        .padding(.horizontal, 24)
        .animation(.easeInOut(duration: 0.3), value: moves <= 3)
    }
}

#Preview {
    GameView()
}
