import SwiftUI

/// Onboarding view shown to first-time users with game instructions
public struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void

    private let totalPages = 4

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            Color(hex: "F5F0FF").ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < totalPages - 1 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "6B5B7A"))
                        .padding()
                    }
                }

                // Page content
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)

                    HowToPlayPage()
                        .tag(1)

                    GoalPage()
                        .tag(2)

                    GameModesPage(onGetStarted: completeOnboarding)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color(hex: "B088C0") : Color(hex: "EDE5F5"))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)

                // Navigation buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button {
                            withAnimation {
                                currentPage -= 1
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "6B5B7A"))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "FFD6E0"))
                            .cornerRadius(8)
                        }
                    }

                    Spacer()

                    if currentPage < totalPages - 1 {
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "B088C0"))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        onComplete()
    }
}

// MARK: - Onboarding Pages

private struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("2048")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "6B5B7A"))

            Text("Welcome!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "6B5B7A"))

            Text("A simple but addictive puzzle game.\nSlide tiles and combine them to reach 2048!")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(Color(hex: "6B5B7A"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

private struct HowToPlayPage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("How to Play")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "6B5B7A"))

            Text("Swipe in any direction to move all tiles")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(Color(hex: "6B5B7A"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Swipe animation demo
            SwipeAnimationDemo()
                .frame(height: 200)

            Text("When two tiles with the same number touch,\nthey merge into one!")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(hex: "6B5B7A"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Merge demo
            MergeAnimationDemo()
                .frame(height: 100)

            Spacer()
        }
    }
}

private struct GoalPage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Goal")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "6B5B7A"))

            // Target tile visualization
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "FF85A2"))
                    .frame(width: 100, height: 100)
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)

                Text("2048")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Text("Reach the 2048 tile to win!")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(Color(hex: "6B5B7A"))
                .multilineTextAlignment(.center)

            Text("But don't stop there—keep going\nto beat your high score!")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(hex: "6B5B7A").opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

private struct GameModesPage: View {
    let onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Game Modes")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "6B5B7A"))

            VStack(alignment: .leading, spacing: 16) {
                ModeRow(icon: "infinity", title: "Classic", description: "No time limit, play at your pace")
                ModeRow(icon: "timer", title: "Timed", description: "Race against the clock")
                ModeRow(icon: "arrow.up.arrow.down", title: "Limited Moves", description: "Strategic play with limited moves")
                ModeRow(icon: "leaf.fill", title: "Zen", description: "Relaxed mode, no win or lose")
            }
            .padding(.horizontal, 40)

            Spacer()

            Button(action: onGetStarted) {
                Text("Get Started")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "B088C0"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)

            Spacer()
        }
    }
}

private struct ModeRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "B088C0"))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "6B5B7A"))

                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "6B5B7A").opacity(0.7))
            }
        }
    }
}

// MARK: - Animation Demos

private struct SwipeAnimationDemo: View {
    @State private var offset: CGFloat = 0
    @State private var showArrow = false

    var body: some View {
        ZStack {
            // Grid background
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "E8E0F0"))
                .frame(width: 160, height: 160)

            // Animated tile
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "FFD6E0"))
                    .frame(width: 70, height: 70)

                Text("2")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "6B5B7A"))
            }
            .offset(x: offset)

            // Arrow indicator
            if showArrow {
                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "B088C0"))
                    .offset(x: 90)
                    .transition(.opacity)
            }
        }
        .onAppear {
            animateSwipe()
        }
    }

    private func animateSwipe() {
        // Repeat animation
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeOut(duration: 0.3)) {
                    showArrow = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                Task { @MainActor in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        offset = 40
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { @MainActor in
                    withAnimation(.easeOut(duration: 0.2)) {
                        showArrow = false
                    }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        offset = 0
                    }
                }
            }
        }
    }
}

private struct MergeAnimationDemo: View {
    @State private var showMerged = false
    @State private var tileScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 16) {
            // Left tile
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "FFD6E0"))
                    .frame(width: 60, height: 60)
                    .opacity(showMerged ? 0 : 1)

                Text("2")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "6B5B7A"))
                    .opacity(showMerged ? 0 : 1)
            }

            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "6B5B7A"))
                .opacity(showMerged ? 0 : 1)

            // Right tile / Merged tile
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(showMerged ? Color(hex: "FFE4CC") : Color(hex: "FFD6E0"))
                    .frame(width: 60, height: 60)
                    .scaleEffect(tileScale)

                Text(showMerged ? "4" : "2")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "6B5B7A"))
                    .scaleEffect(tileScale)
            }

            Image(systemName: "equal")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "6B5B7A"))
                .opacity(showMerged ? 0 : 1)

            // Result
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "FFE4CC"))
                    .frame(width: 60, height: 60)
                    .opacity(showMerged ? 0 : 1)

                Text("4")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "6B5B7A"))
                    .opacity(showMerged ? 0 : 1)
            }
        }
        .onAppear {
            animateMerge()
        }
    }

    private func animateMerge() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showMerged = true
                    tileScale = 1.15
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                Task { @MainActor in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        tileScale = 1.0
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                Task { @MainActor in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showMerged = false
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
