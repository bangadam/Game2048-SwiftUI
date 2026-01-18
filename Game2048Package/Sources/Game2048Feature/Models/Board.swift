import Foundation

/// The result of a move operation
public struct MoveResult: Sendable {
    public let didMove: Bool
    public let scoreGained: Int
    public let mergedTileIds: Set<UUID>

    public init(didMove: Bool, scoreGained: Int, mergedTileIds: Set<UUID> = []) {
        self.didMove = didMove
        self.scoreGained = scoreGained
        self.mergedTileIds = mergedTileIds
    }
}

/// Represents the game board with configurable size
public struct Board: Equatable, Sendable {
    public let size: Int

    public private(set) var tiles: [Tile]

    public init(size: Int = 4, tiles: [Tile] = []) {
        self.size = size
        self.tiles = tiles
    }

    // MARK: - Tile Access

    /// Returns the tile at the given position, if any
    public func tile(at row: Int, col: Int) -> Tile? {
        tiles.first { $0.row == row && $0.col == col }
    }

    /// Returns all empty positions on the board
    public var emptyPositions: [(row: Int, col: Int)] {
        var empty: [(Int, Int)] = []
        for row in 0..<size {
            for col in 0..<size {
                if tile(at: row, col: col) == nil {
                    empty.append((row, col))
                }
            }
        }
        return empty
    }

    /// Whether the board is completely full
    public var isFull: Bool {
        emptyPositions.isEmpty
    }

    /// The highest tile value on the board
    public var maxTileValue: Int {
        tiles.map(\.value).max() ?? 0
    }

    // MARK: - Mutations

    /// Adds a new tile at a random empty position
    /// - Parameter twoSpawnProbability: Probability of spawning a 2 (vs a 4). Defaults to 0.9.
    /// - Returns: The spawned tile, or nil if the board is full
    @discardableResult
    public mutating func spawnRandomTile(twoSpawnProbability: Double = 0.9) -> Tile? {
        let empty = emptyPositions
        guard !empty.isEmpty else { return nil }

        let position = empty.randomElement()!
        let value = Double.random(in: 0..<1) < twoSpawnProbability ? 2 : 4
        let newTile = Tile(value: value, row: position.row, col: position.col)
        tiles.append(newTile)
        return newTile
    }

    /// Clears the animation flags on all tiles
    public mutating func clearAnimationFlags() {
        for i in tiles.indices {
            tiles[i].isNew = false
            tiles[i].wasMerged = false
        }
    }

    // MARK: - Move Logic

    /// Performs a move in the given direction
    /// Returns the result including score gained and whether tiles moved
    public mutating func move(_ direction: Direction) -> MoveResult {
        var totalScore = 0
        var didMove = false
        var mergedIds: Set<UUID> = []

        // Process each row or column depending on direction
        for lineIndex in 0..<size {
            let line = extractLine(at: lineIndex, direction: direction)
            let values = line.map { $0?.value ?? 0 }

            // TODO(human): Implement the mergeRow function below
            let (merged, score) = mergeRow(values)

            // Check if anything changed
            if merged != values {
                didMove = true
            }
            totalScore += score

            // Apply the merged result back to the board
            let newMergedIds = applyLine(merged, at: lineIndex, direction: direction, originalLine: line)
            mergedIds.formUnion(newMergedIds)
        }

        return MoveResult(didMove: didMove, scoreGained: totalScore, mergedTileIds: mergedIds)
    }

    /// Extracts a row or column of tiles based on direction
    private func extractLine(at index: Int, direction: Direction) -> [Tile?] {
        switch direction {
        case .left:
            return (0..<size).map { tile(at: index, col: $0) }
        case .right:
            return (0..<size).reversed().map { tile(at: index, col: $0) }
        case .up:
            return (0..<size).map { tile(at: $0, col: index) }
        case .down:
            return (0..<size).reversed().map { tile(at: $0, col: index) }
        }
    }

    /// Applies merged values back to the board while preserving tile UUIDs for animation
    private mutating func applyLine(_ values: [Int], at index: Int, direction: Direction, originalLine: [Tile?]) -> Set<UUID> {
        var mergedIds: Set<UUID> = []

        // Step 1: Get compacted tiles (non-nil, in order they appear in the line)
        let compactedTiles = originalLine.compactMap { $0 }

        // Step 2: Process tiles - track survivors and consumed tiles
        var tilesToRemove: Set<UUID> = []
        var survivingTileInfo: [(id: UUID, newValue: Int, isMerged: Bool)] = []

        var i = 0
        while i < compactedTiles.count {
            let currentTile = compactedTiles[i]

            if i + 1 < compactedTiles.count && compactedTiles[i].value == compactedTiles[i + 1].value {
                // Merge: first tile survives with doubled value, second tile is consumed
                let mergedValue = currentTile.value * 2
                survivingTileInfo.append((id: currentTile.id, newValue: mergedValue, isMerged: true))
                tilesToRemove.insert(compactedTiles[i + 1].id)
                i += 2
            } else {
                // No merge: tile survives with same value
                survivingTileInfo.append((id: currentTile.id, newValue: currentTile.value, isMerged: false))
                i += 1
            }
        }

        // Step 3: Remove consumed tiles
        tiles.removeAll { tilesToRemove.contains($0.id) }

        // Step 4: Update surviving tiles in-place (preserves UUID for animation!)
        for (position, info) in survivingTileInfo.enumerated() {
            let (targetRow, targetCol) = targetPosition(lineIndex: index, position: position, direction: direction)

            // Find the tile in our tiles array and update it
            if let tileIndex = tiles.firstIndex(where: { $0.id == info.id }) {
                // Move the tile to new position (preserves UUID)
                tiles[tileIndex].moveTo(row: targetRow, col: targetCol)

                if info.isMerged {
                    // Update value and mark as merged for pop animation
                    tiles[tileIndex].value = info.newValue
                    tiles[tileIndex].wasMerged = true
                    mergedIds.insert(info.id)
                }
            }
        }

        return mergedIds
    }

    /// Converts line position back to board coordinates
    private func targetPosition(lineIndex: Int, position: Int, direction: Direction) -> (row: Int, col: Int) {
        switch direction {
        case .left:
            return (lineIndex, position)
        case .right:
            return (lineIndex, size - 1 - position)
        case .up:
            return (position, lineIndex)
        case .down:
            return (size - 1 - position, lineIndex)
        }
    }

    // MARK: - Core Algorithm

    /// Merges a row of values according to 2048 rules
    /// Input:  [2, 0, 2, 4] (values from a row/column)
    /// Output: ([4, 4, 0, 0], 4) - merged values and score gained
    public func mergeRow(_ row: [Int]) -> (merged: [Int], score: Int) {
        // Step 1: Remove zeros (compress to front)
        let compressed = row.filter { $0 != 0 }

        var score = 0
        var merged: [Int] = []

        // Step 2: Merge adjacent equal values
        var i = 0
        while i < compressed.count {
            if i + 1 < compressed.count && compressed[i] == compressed[i + 1] {
                // Merge: double the value
                let newValue = compressed[i] * 2
                merged.append(newValue)
                score += newValue
                i += 2  // Skip both tiles
            } else {
                merged.append(compressed[i])
                i += 1
            }
        }

        // Step 3: Pad with zeros to maintain size
        while merged.count < size {
            merged.append(0)
        }

        return (merged, score)
    }

    // MARK: - Game State Checks

    /// Checks if any moves are possible
    public func canMove() -> Bool {
        // If there are empty spaces, we can move
        if !isFull { return true }

        // Check for adjacent equal tiles
        for row in 0..<size {
            for col in 0..<size {
                guard let current = tile(at: row, col: col) else { continue }

                // Check right neighbor
                if col < size - 1,
                   let right = tile(at: row, col: col + 1),
                   current.value == right.value {
                    return true
                }

                // Check bottom neighbor
                if row < size - 1,
                   let bottom = tile(at: row + 1, col: col),
                   current.value == bottom.value {
                    return true
                }
            }
        }

        return false
    }
}
