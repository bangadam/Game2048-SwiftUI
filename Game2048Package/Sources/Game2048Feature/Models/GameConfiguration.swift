import Foundation

/// Configuration for a game session
public struct GameConfiguration: Sendable, Equatable {
    public let targetValue: Int
    public let boardSize: Int

    public init(
        targetValue: Int = 2048,
        boardSize: Int = 4
    ) {
        self.targetValue = targetValue
        self.boardSize = boardSize
    }

    public static let `default` = GameConfiguration()
}
