import SwiftUI

/// Defines visual themes for the game
public enum Theme: String, Sendable, CaseIterable {
    case classic
    case dark
    case ocean
    case forest

    public var displayName: String {
        switch self {
        case .classic:
            return "Classic"
        case .dark:
            return "Dark"
        case .ocean:
            return "Ocean"
        case .forest:
            return "Forest"
        }
    }

    public var backgroundColor: Color {
        switch self {
        case .classic:
            return Color(hex: "FAF8EF")
        case .dark:
            return Color(hex: "1A1A2E")
        case .ocean:
            return Color(hex: "E3F2FD")
        case .forest:
            return Color(hex: "E8F5E9")
        }
    }

    public var boardColor: Color {
        switch self {
        case .classic:
            return Color(hex: "BBADA0")
        case .dark:
            return Color(hex: "16213E")
        case .ocean:
            return Color(hex: "1976D2")
        case .forest:
            return Color(hex: "388E3C")
        }
    }

    public var emptyTileColor: Color {
        switch self {
        case .classic:
            return Color(hex: "CDC1B4")
        case .dark:
            return Color(hex: "0F3460")
        case .ocean:
            return Color(hex: "64B5F6")
        case .forest:
            return Color(hex: "81C784")
        }
    }

    public var textColor: Color {
        switch self {
        case .classic:
            return Color(hex: "776E65")
        case .dark:
            return Color.white
        case .ocean:
            return Color(hex: "0D47A1")
        case .forest:
            return Color(hex: "1B5E20")
        }
    }
}
