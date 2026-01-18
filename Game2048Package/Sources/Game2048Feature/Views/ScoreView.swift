import SwiftUI

/// Score display component
public struct ScoreView: View {
    let title: String
    let score: Int

    public init(title: String, score: Int) {
        self.title = title
        self.score = score
    }

    public var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "E8E0F0"))
                .padding(.bottom, 2)

            Text("\(score)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(minWidth: 60)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: "DED0E8"))
        .cornerRadius(6)
    }
}
