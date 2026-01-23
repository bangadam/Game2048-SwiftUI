import Foundation

/// Defines the different game modes available
public enum GameMode: Sendable, Equatable, CaseIterable {
    /// Classic 2048 - play until you can't move
    case classic

    public var displayName: String {
        switch self {
        case .classic:
            return "Classic"
        }
    }

    public var description: String {
        switch self {
        case .classic:
            return "Play until you reach 2048 or can't move"
        }
    }
}
