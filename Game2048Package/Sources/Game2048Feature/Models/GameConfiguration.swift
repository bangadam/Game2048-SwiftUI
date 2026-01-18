import Foundation

/// Configuration for a game session
public struct GameConfiguration: Sendable, Equatable {
    public let mode: GameMode
    public let boardSize: Int
    public let targetValue: Int
    public let difficulty: Difficulty
    public let theme: Theme

    public init(
        mode: GameMode = .classic,
        boardSize: Int = 4,
        targetValue: Int = 2048,
        difficulty: Difficulty = .normal,
        theme: Theme = .classic
    ) {
        self.mode = mode
        self.boardSize = boardSize
        self.targetValue = targetValue
        self.difficulty = difficulty
        self.theme = theme
    }

    public static let `default` = GameConfiguration()

    /// Available board sizes
    public static let availableBoardSizes = [3, 4, 5, 6]

    /// Available target values
    public static let availableTargets = [512, 2048, 4096, 8192]
}
