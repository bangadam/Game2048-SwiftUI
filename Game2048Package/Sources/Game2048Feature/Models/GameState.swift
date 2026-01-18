import Foundation

/// The current status of the game
public enum GameStatus: Equatable, Sendable {
    case playing
    case won
    case gameOver
}

/// Encapsulates the full game state for easy undo/redo
public struct GameState: Equatable, Sendable {
    public var board: Board
    public var score: Int
    public var status: GameStatus

    public init(board: Board = Board(), score: Int = 0, status: GameStatus = .playing) {
        self.board = board
        self.score = score
        self.status = status
    }
}
