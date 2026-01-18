import Foundation

/// Defines the different game modes available
public enum GameMode: Sendable, Equatable {
    /// Classic 2048 - play until you can't move
    case classic
    /// Timed mode - reach the target before time runs out
    case timed(seconds: Int)
    /// Limited moves - reach the target within a set number of moves
    case limitedMoves(count: Int)
    /// Zen mode - no win/lose conditions, just play
    case zen

    public var displayName: String {
        switch self {
        case .classic:
            return "Classic"
        case .timed:
            return "Timed"
        case .limitedMoves:
            return "Limited Moves"
        case .zen:
            return "Zen"
        }
    }

    public var description: String {
        switch self {
        case .classic:
            return "Play until you reach 2048 or can't move"
        case .timed(let seconds):
            return "Reach the target in \(seconds) seconds"
        case .limitedMoves(let count):
            return "Reach the target in \(count) moves"
        case .zen:
            return "Relax and play without limits"
        }
    }
}
