import SwiftUI

/// The game board view with fluid animations and dynamic sizing
public struct BoardView: View {
    let tiles: [Tile]
    let boardSize: Int
    let onSwipe: (Direction) -> Void

    private let spacing: CGFloat = 10
    private let totalWidth: CGFloat = 320

    public init(tiles: [Tile], boardSize: Int = 4, onSwipe: @escaping (Direction) -> Void) {
        self.tiles = tiles
        self.boardSize = boardSize
        self.onSwipe = onSwipe
    }

    private var tileSize: CGFloat {
        let availableSpace = totalWidth - CGFloat(boardSize + 1) * spacing
        return availableSpace / CGFloat(boardSize)
    }

    private var totalSize: CGFloat {
        CGFloat(boardSize) * tileSize + CGFloat(boardSize + 1) * spacing
    }

    public var body: some View {
        ZStack {
            // Background grid container
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "BBADA0"))
                .frame(width: totalSize, height: totalSize)

            // Empty cell placeholders
            VStack(spacing: spacing) {
                ForEach(0..<boardSize, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<boardSize, id: \.self) { col in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "CDC1B4"))
                                .frame(width: tileSize, height: tileSize)
                        }
                    }
                }
            }
            .padding(spacing)

            // Actual tiles layer
            ForEach(tiles) { tile in
                TileView(tile: tile, size: tileSize)
                    .position(positionFor(row: tile.row, col: tile.col))
                    // Enhanced shadow during movement for depth effect
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 3)
                    // Smoother, more dramatic spring for tile movement
                    .animation(.spring(response: 0.4, dampingFraction: 0.65), value: tile.row)
                    .animation(.spring(response: 0.4, dampingFraction: 0.65), value: tile.col)
                    // Pop-in transition for new tiles
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.5).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .frame(width: totalSize, height: totalSize)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { gesture in
                    let direction = detectDirection(from: gesture)
                    if let direction = direction {
                        onSwipe(direction)
                    }
                }
        )
    }

    private func positionFor(row: Int, col: Int) -> CGPoint {
        // Calculate center point of the tile
        let x = spacing + tileSize / 2 + CGFloat(col) * (tileSize + spacing)
        let y = spacing + tileSize / 2 + CGFloat(row) * (tileSize + spacing)
        return CGPoint(x: x, y: y)
    }

    private func detectDirection(from gesture: DragGesture.Value) -> Direction? {
        let horizontal = gesture.translation.width
        let vertical = gesture.translation.height

        if abs(horizontal) > abs(vertical) {
            return horizontal > 0 ? .right : .left
        } else {
            return vertical > 0 ? .down : .up
        }
    }
}
