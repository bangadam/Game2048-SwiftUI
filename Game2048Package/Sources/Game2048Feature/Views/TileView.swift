import SwiftUI

/// Individual tile view with modern minimalist design and playful animations
public struct TileView: View {
    let tile: Tile
    let size: CGFloat

    public init(tile: Tile, size: CGFloat = 70) {
        self.tile = tile
        self.size = size
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)

                // Number
                if tile.value > 0 {
                    Text("\(tile.value)")
                        .font(.system(size: fontSize(for: geometry.size), weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .frame(width: size, height: size)
        // Animation Logic - Bold merge effect
        .scaleEffect(scaleValue)
        .rotationEffect(rotationValue)
        // Bouncier spring for more pronounced "pop" on merge
        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: tile.wasMerged)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: tile.isNew)
    }

    // MARK: - Computed Properties

    private var scaleValue: CGFloat {
        if tile.isNew {
            return 1.0 // It starts at 0 implicitly via transition, but here we keep it 1.
                       // Actually, simpler: Board handles position.
                       // We want "pop" on merge.
            // If isNew, we might want to scale up from 0 manually if transition doesn't catch it.
            // But let's rely on wasMerged for the big pop.
        }
        return tile.wasMerged ? 1.25 : 1.0
    }

    private var rotationValue: Angle {
        // Slight wiggle effect on merge for extra visual punch
        tile.wasMerged ? .degrees(3) : .zero
    }

    private func fontSize(for size: CGSize) -> CGFloat {
        let base = size.width * 0.45
        switch tile.value {
        case 0..<100: return base
        case 100..<1000: return base * 0.8
        default: return base * 0.6
        }
    }

    private var textColor: Color {
        tile.value >= 2048 ? .white : Color(hex: "6B5B7A")
    }

    private var backgroundColor: Color {
        switch tile.value {
        case 2: return Color(hex: "FFD6E0")    // Soft Pink
        case 4: return Color(hex: "FFE4CC")    // Peachy
        case 8: return Color(hex: "FFF3B8")    // Butter Yellow
        case 16: return Color(hex: "C8F7DC")   // Mint Green
        case 32: return Color(hex: "B8F0F0")   // Aqua
        case 64: return Color(hex: "B8E0FF")   // Sky Blue
        case 128: return Color(hex: "C5C8FF")  // Periwinkle
        case 256: return Color(hex: "E0C8FF")  // Lavender
        case 512: return Color(hex: "F0B8E8")  // Orchid
        case 1024: return Color(hex: "FFB8C8") // Coral
        case 2048: return Color(hex: "FF85A2") // Hot Pink
        default: return Color(hex: "8B6B99")   // Deep Purple
        }
    }
}
