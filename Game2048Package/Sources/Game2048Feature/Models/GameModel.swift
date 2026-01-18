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

    /// Remaining time for timed mode (nil for other modes)
    public private(set) var remainingTime: Int?

    /// Remaining moves for limited moves mode (nil for other modes)
    public private(set) var remainingMoves: Int?

    /// Total moves made in this game
    public private(set) var moveCount: Int = 0

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

        // Initialize mode-specific properties
        switch configuration.mode {
        case .timed(let seconds):
            self.remainingTime = seconds
        case .limitedMoves(let count):
            self.remainingMoves = count
        default:
            break
        }

        // Start with two tiles
        spawnTileWithDifficulty()
        spawnTileWithDifficulty()
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

        // Update move count
        moveCount += 1

        // Decrement remaining moves if in limited moves mode
        if var moves = remainingMoves {
            moves -= 1
            remainingMoves = moves
        }

        // Update score
        score += result.scoreGained
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "highScore")
        }

        // Spawn a new tile
        spawnTileWithDifficulty()

        // Check game status
        updateGameStatus()
    }

    /// Starts a new game with the same configuration
    public func newGame() {
        board = Board(size: configuration.boardSize)
        score = 0
        status = .playing
        history.removeAll()
        moveCount = 0

        // Reset mode-specific properties
        switch configuration.mode {
        case .timed(let seconds):
            remainingTime = seconds
        case .limitedMoves(let count):
            remainingMoves = count
        default:
            break
        }

        // Start with two tiles
        spawnTileWithDifficulty()
        spawnTileWithDifficulty()
    }

    /// Decrements the timer (called externally by a timer)
    public func decrementTimer() {
        guard case .timed = configuration.mode else { return }
        guard status == .playing else { return }

        if var time = remainingTime {
            time -= 1
            remainingTime = time
            if time <= 0 {
                status = .gameOver
            }
        }
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

    /// Spawns a tile using the configured difficulty's spawn probability
    private func spawnTileWithDifficulty() {
        let probability = configuration.difficulty.twoSpawnProbability
        board.spawnRandomTile(twoSpawnProbability: probability)
    }

    private func updateGameStatus() {
        let targetValue = configuration.targetValue

        // In zen mode, never win or lose
        if case .zen = configuration.mode {
            return
        }

        // Check for limited moves game over
        if let moves = remainingMoves, moves <= 0 {
            if board.maxTileValue < targetValue {
                status = .gameOver
            }
            return
        }

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
