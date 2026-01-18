import SwiftUI

/// Game mode selection cards
struct ModePicker: View {
    @Binding var selectedMode: GameMode

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ModeCard(
                    icon: "flag.checkered",
                    title: "Classic",
                    description: "Reach the target",
                    isSelected: selectedMode == .classic
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = .classic
                    }
                }

                ModeCard(
                    icon: "timer",
                    title: "Timed",
                    description: "Beat the clock",
                    isSelected: isTimedMode
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = .timed(seconds: 120)
                    }
                }
            }

            HStack(spacing: 12) {
                ModeCard(
                    icon: "arrow.up.arrow.down",
                    title: "Limited",
                    description: "Limited moves",
                    isSelected: isLimitedMode
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = .limitedMoves(count: 50)
                    }
                }

                ModeCard(
                    icon: "leaf",
                    title: "Zen",
                    description: "No limits",
                    isSelected: selectedMode == .zen
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = .zen
                    }
                }
            }
        }
    }

    private var isTimedMode: Bool {
        if case .timed = selectedMode { return true }
        return false
    }

    private var isLimitedMode: Bool {
        if case .limitedMoves = selectedMode { return true }
        return false
    }
}

struct ModeCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))

                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text(description)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .opacity(0.7)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color(hex: "FF85A2") : Color(hex: "EDE5F5"))
            .foregroundColor(isSelected ? .white : Color(hex: "6B5B7A"))
            .cornerRadius(12)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
    }
}

#Preview {
    ModePicker(selectedMode: .constant(.classic))
        .padding()
        .background(Color(hex: "F5F0FF"))
}
