import SwiftUI

/// Visual picker for selecting board size (3x3 to 6x6)
struct BoardSizePicker: View {
    @Binding var selectedSize: Int

    private let sizes = [3, 4, 5, 6]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(sizes, id: \.self) { size in
                BoardSizeCard(
                    size: size,
                    isSelected: selectedSize == size
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedSize = size
                    }
                }
            }
        }
    }
}

struct BoardSizeCard: View {
    let size: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Mini grid preview
                MiniGridPreview(size: size, isSelected: isSelected)
                    .frame(width: 40, height: 40)

                Text("\(size)x\(size)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "EDC22E") : Color(hex: "CDC1B4"))
            .foregroundColor(isSelected ? .white : Color(hex: "776E65"))
            .cornerRadius(12)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
}

struct MiniGridPreview: View {
    let size: Int
    let isSelected: Bool

    private var cellSize: CGFloat {
        (40 - CGFloat(size + 1) * 2) / CGFloat(size)
    }

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<size, id: \.self) { _ in
                HStack(spacing: 2) {
                    ForEach(0..<size, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(isSelected ? Color.white.opacity(0.5) : Color(hex: "BBADA0"))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
}

#Preview {
    BoardSizePicker(selectedSize: .constant(4))
        .padding()
        .background(Color(hex: "FAF8EF"))
}
