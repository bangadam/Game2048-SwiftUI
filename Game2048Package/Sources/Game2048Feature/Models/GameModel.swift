import Foundation
import SwiftUI

/// Observable game model that manages the 2048 game state
/// This is the single source of truth for the entire game
@Observable
@MainActor
public final class GameModel: Sendable {
    // MARK: - Published State

    public private(set) var board: Board
    public private(set) var score: Int
    public private(set) var highScore: Int
    public private(set) var status: GameStatus
    public let configuration: GameConfiguration

    /// History of game states for undo functionality
    private var history: [GameState] = []

    /// Maximum history size to prevent memory issues
    private let maxHistorySize = 50

    // MARK: - Computed Properties

    public var canUndo: Bool {
        !history.isEmpty
    }

    public var isGameOver: Bool {
        status == .gameOver
    }

    public var hasWon: Bool {
        status == .won
    }

    public var boardSize: Int {
        configuration.boardSize
    }

    // MARK: - Initialization

    public init(configuration: GameConfiguration = .default) {
        self.configuration = configuration
        self.board = Board(size: configuration.boardSize)
        self.score = 0
        self.highScore = UserDefaults.standard.integer(forKey: "highScore")
        self.status = .playing

        // Start with two tiles
        spawnTile()
        spawnTile()
    }

    // MARK: - Game Actions

    /// Performs a move in the given direction
    public func move(_ direction: Direction) {
        guard status == .playing else { return }

        // Save state for undo before making the move
        saveStateForUndo()

        // Clear animation flags from previous move
        board.clearAnimationFlags()

        // Perform the move
        let result = board.move(direction)

        // If nothing moved, remove the saved state (no undo needed)
        guard result.didMove else {
            history.removeLast()
            return
        }

        // Update score
        score += result.scoreGained
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "highScore")
        }

        // Spawn a new tile
        spawnTile()

        // Check game status
        updateGameStatus()
    }

    /// Starts a new game with the same configuration
    public func newGame() {
        board = Board(size: configuration.boardSize)
        score = 0
        status = .playing
        history.removeAll()

        // Start with two tiles
        spawnTile()
        spawnTile()
    }

    /// Undoes the last move
    public func undo() {
        guard let previousState = history.popLast() else { return }

        board = previousState.board
        score = previousState.score
        status = previousState.status
    }

    /// Allows continuing to play after winning
    public func continueAfterWin() {
        if status == .won {
            status = .playing
        }
    }

    // MARK: - Private Helpers

    private func saveStateForUndo() {
        let currentState = GameState(board: board, score: score, status: status)
        history.append(currentState)

        // Limit history size
        if history.count > maxHistorySize {
            history.removeFirst()
        }
    }

    /// Spawns a tile with standard probability (90% chance for 2, 10% for 4)
    private func spawnTile() {
        board.spawnRandomTile(twoSpawnProbability: 0.9)
    }

    private func updateGameStatus() {
        let targetValue = configuration.targetValue

        // Check for win (only if not already won and continued)
        if board.maxTileValue >= targetValue && status != .playing {
            // Already won and continued playing
        } else if board.maxTileValue >= targetValue && status == .playing && !history.contains(where: { $0.board.maxTileValue >= targetValue }) {
            status = .won
            return
        }

        // Check for game over
        if !board.canMove() {
            status = .gameOver
        }
    }
}
