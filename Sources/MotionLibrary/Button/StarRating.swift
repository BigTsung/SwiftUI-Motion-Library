import SwiftUI

/// A star rating control. Tapping a star fills the stars up to it one after
/// another, each with a springy pop, and the tapped star bursts a ring of
/// sparks.
public struct StarRating: View {
    @Binding private var rating: Int
    private let maximum: Int
    private let color: Color
    private let size: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - rating: The number of filled stars, 0…maximum.
    ///   - maximum: How many stars to show.
    ///   - color: Colour of filled stars and sparks.
    ///   - size: Point size of each star.
    public init(rating: Binding<Int>, maximum: Int = 5, color: Color = .yellow, size: CGFloat = 28) {
        _rating = rating
        self.maximum = max(1, maximum)
        self.color = color
        self.size = size
    }

    public var body: some View {
        HStack(spacing: size * 0.25) {
            ForEach(1...maximum, id: \.self) { index in
                star(index)
            }
        }
        .haptic(.lightImpact, trigger: rating)
        .accessibilityElement()
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) of \(maximum)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: rating = min(maximum, rating + 1)
            case .decrement: rating = max(0, rating - 1)
            @unknown default: break
            }
        }
    }

    private func star(_ index: Int) -> some View {
        let filled = index <= rating
        // Keyframes must have a positive duration, so the first star waits a hair.
        let delay = max(0.001, Double(index - 1) * 0.06)
        let animate = filled && !reduceMotion
        return Image(systemName: filled ? "star.fill" : "star")
            .font(.system(size: size))
            .foregroundStyle(filled ? color : Color.secondary.opacity(0.5))
            .keyframeAnimator(initialValue: 1.0, trigger: rating) { view, scale in
                view.scaleEffect(animate ? scale : 1)
            } keyframes: { _ in
                LinearKeyframe(1, duration: delay)
                SpringKeyframe(1.4, duration: 0.15, spring: .snappy)
                SpringKeyframe(1, duration: 0.4, spring: .bouncy)
            }
            .background {
                if index == rating && !reduceMotion {
                    StarSparks(color: color, size: size, trigger: rating, delay: delay)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { rating = index }
    }
}

/// Eight short dots that shoot out from the star and fade.
private struct StarSparks: View {
    let color: Color
    let size: CGFloat
    let trigger: Int
    let delay: Double

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { spark in
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .keyframeAnimator(initialValue: SparkValues(), trigger: trigger) { view, value in
                        view
                            .offset(y: -value.distance)
                            .rotationEffect(.degrees(Double(spark) * 45))
                            .opacity(value.opacity)
                    } keyframes: { _ in
                        KeyframeTrack(\.distance) {
                            LinearKeyframe(size * 0.3, duration: delay)
                            CubicKeyframe(size * 0.95, duration: 0.45)
                        }
                        KeyframeTrack(\.opacity) {
                            LinearKeyframe(0, duration: delay)
                            LinearKeyframe(1, duration: 0.05)
                            LinearKeyframe(0, duration: 0.4)
                        }
                    }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct SparkValues {
    var distance: CGFloat = 0
    var opacity: Double = 0
}

#Preview {
    struct Demo: View {
        @State private var rating = 3
        var body: some View {
            StarRating(rating: $rating).padding()
        }
    }
    return Demo()
}
