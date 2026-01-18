import Foundation

/// Defines difficulty levels that affect tile spawn probabilities
public enum Difficulty: String, Sendable, CaseIterable {
    case easy
    case normal
    case hard

    /// Probability of spawning a 2 (vs a 4)
    public var twoSpawnProbability: Double {
        switch self {
        case .easy:
            return 0.95
        case .normal:
            return 0.90
        case .hard:
            return 0.80
        }
    }

    public var displayName: String {
        switch self {
        case .easy:
            return "Easy"
        case .normal:
            return "Normal"
        case .hard:
            return "Hard"
        }
    }

    public var description: String {
        switch self {
        case .easy:
            return "95% chance for 2s"
        case .normal:
            return "90% chance for 2s"
        case .hard:
            return "80% chance for 2s"
        }
    }
}
