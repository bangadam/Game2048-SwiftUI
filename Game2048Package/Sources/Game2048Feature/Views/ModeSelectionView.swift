import SwiftUI

/// Pre-game configuration screen for selecting game mode, board size, and difficulty
public struct ModeSelectionView: View {
    @State private var selectedMode: GameMode = .classic
    @State private var selectedBoardSize: Int = 4
    @State private var selectedDifficulty: Difficulty = .normal
    @State private var selectedTargetValue: Int = 2048

    let onStartGame: (GameConfiguration) -> Void

    public init(onStartGame: @escaping (GameConfiguration) -> Void) {
        self.onStartGame = onStartGame
    }

    public var body: some View {
        ZStack {
            Color(hex: "FAF8EF").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("2048")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "776E65"))

                        Text("Choose your challenge")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "776E65").opacity(0.7))
                    }
                    .padding(.top, 40)

                    // Board Size Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("BOARD SIZE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "776E65").opacity(0.6))

                        BoardSizePicker(selectedSize: $selectedBoardSize)
                    }
                    .padding(.horizontal, 24)

                    // Game Mode Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GAME MODE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "776E65").opacity(0.6))

                        ModePicker(selectedMode: $selectedMode)
                    }
                    .padding(.horizontal, 24)

                    // Difficulty Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DIFFICULTY")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "776E65").opacity(0.6))

                        DifficultyPicker(selectedDifficulty: $selectedDifficulty)
                    }
                    .padding(.horizontal, 24)

                    // Target Value Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TARGET")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "776E65").opacity(0.6))

                        TargetPicker(selectedTarget: $selectedTargetValue)
                    }
                    .padding(.horizontal, 24)

                    // Start Button
                    Button(action: startGame) {
                        Text("Start Game")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "8F7A66"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func startGame() {
        let configuration = GameConfiguration(
            mode: selectedMode,
            boardSize: selectedBoardSize,
            targetValue: selectedTargetValue,
            difficulty: selectedDifficulty,
            theme: .classic
        )
        onStartGame(configuration)
    }
}

// MARK: - Difficulty Picker

struct DifficultyPicker: View {
    @Binding var selectedDifficulty: Difficulty

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                DifficultyCard(
                    difficulty: difficulty,
                    isSelected: selectedDifficulty == difficulty
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedDifficulty = difficulty
                    }
                }
            }
        }
    }
}

struct DifficultyCard: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void

    private var title: String {
        difficulty.rawValue.capitalized
    }

    private var description: String {
        switch difficulty {
        case .easy: return "95% 2s"
        case .normal: return "90% 2s"
        case .hard: return "80% 2s"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Text(description)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .opacity(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "EDC22E") : Color(hex: "CDC1B4"))
            .foregroundColor(isSelected ? .white : Color(hex: "776E65"))
            .cornerRadius(8)
        }
    }
}

// MARK: - Target Picker

struct TargetPicker: View {
    @Binding var selectedTarget: Int

    private let targets = [512, 2048, 4096, 8192]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(targets, id: \.self) { target in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTarget = target
                    }
                } label: {
                    Text("\(target)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTarget == target ? Color(hex: "EDC22E") : Color(hex: "CDC1B4"))
                        .foregroundColor(selectedTarget == target ? .white : Color(hex: "776E65"))
                        .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    ModeSelectionView { _ in }
}
