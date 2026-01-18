import Foundation

/// Represents a single tile in the 2048 game
/// Each tile has a value (2, 4, 8, etc.) and position on the board
public struct Tile: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var value: Int
    public var row: Int
    public var col: Int

    /// Animation state flags
    public var isNew: Bool
    public var wasMerged: Bool

    public init(
        id: UUID = UUID(),
        value: Int,
        row: Int,
        col: Int,
        isNew: Bool = true,
        wasMerged: Bool = false
    ) {
        self.id = id
        self.value = value
        self.row = row
        self.col = col
        self.isNew = isNew
        self.wasMerged = wasMerged
    }

    /// Creates a copy of the tile at a new position
    public func moved(to row: Int, col: Int) -> Tile {
        var newTile = self
        newTile.row = row
        newTile.col = col
        newTile.isNew = false
        newTile.wasMerged = false
        return newTile
    }

    /// Creates a merged tile with doubled value
    public func merged() -> Tile {
        var newTile = self
        newTile.value *= 2
        newTile.wasMerged = true
        newTile.isNew = false
        return newTile
    }

    /// Moves the tile to a new position in-place (preserves UUID for animation)
    public mutating func moveTo(row: Int, col: Int) {
        self.row = row
        self.col = col
        self.isNew = false
        self.wasMerged = false
    }
}
