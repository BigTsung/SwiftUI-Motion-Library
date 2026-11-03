import SwiftUI

private struct LikePop {
    var heart: CGFloat = 1
    var ring: CGFloat = 0
    var dots: CGFloat = 0
}

/// A Twitter-style like button: on like, a ring bursts open, the heart pops
/// in with an overshoot and a circle of coloured dots flies out. Unliking
/// just shrinks the heart back.
public struct LikeButton: View {
    @Binding private var isLiked: Bool
    private let size: CGFloat
    private let color: Color
    private let dotColors: [Color]

    @State private var likes = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - isLiked: Whether the item is liked; tapping toggles it.
    ///   - size: Point size of the heart.
    ///   - color: Colour of the filled heart and the ring.
    ///   - dotColors: Colours cycled through by the burst dots.
    public init(
        isLiked: Binding<Bool>,
        size: CGFloat = 28,
        color: Color = .pink,
        dotColors: [Color] = [.pink, .orange, .yellow, .mint, .cyan, .purple]
    ) {
        _isLiked = isLiked
        self.size = size
        self.color = color
        self.dotColors = dotColors
    }

    public var body: some View {
        let showBurst = !reduceMotion
        let size = size, color = color, dotColors = dotColors
        return Button {
            isLiked.toggle()
            if isLiked { likes += 1 }
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: size))
                .foregroundStyle(isLiked ? color : Color.secondary)
                .frame(width: size * 1.6, height: size * 1.6)
                .contentShape(Rectangle())
                .keyframeAnimator(initialValue: LikePop(), trigger: likes) { heart, pop in
                    heart
                        .scaleEffect(pop.heart)
                        .background {
                            if showBurst { LikeBurst(pop: pop, size: size, color: color, dotColors: dotColors) }
                        }
                } keyframes: { _ in
                    KeyframeTrack(\.heart) {
                        CubicKeyframe(0.2, duration: 0.05)
                        CubicKeyframe(0.2, duration: 0.15)
                        SpringKeyframe(1, duration: 0.5, spring: .bouncy(duration: 0.4, extraBounce: 0.25))
                    }
                    KeyframeTrack(\.ring) {
                        LinearKeyframe(0.01, duration: 0.01)
                        CubicKeyframe(1, duration: 0.3)
                        LinearKeyframe(0, duration: 0.01)
                    }
                    KeyframeTrack(\.dots) {
                        LinearKeyframe(0, duration: 0.15)
                        CubicKeyframe(1, duration: 0.55)
                        LinearKeyframe(0, duration: 0.01)
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLiked)
        .haptic(.lightImpact, trigger: likes)
        .accessibilityLabel(isLiked ? "Unlike" : "Like")
    }
}

/// The ring and the dots behind the heart.
private struct LikeBurst: View {
    let pop: LikePop
    let size: CGFloat
    let color: Color
    let dotColors: [Color]

    var body: some View {
        ZStack {
            // The ring grows and its stroke thins out to nothing.
            if pop.ring > 0 {
                Circle()
                    .strokeBorder(color, lineWidth: max(0.1, size * 0.5 * (1 - pop.ring)))
                    .frame(width: size * 1.5 * pop.ring, height: size * 1.5 * pop.ring)
            }
            // Seven pairs of dots fly outward and shrink.
            if pop.dots > 0 {
                ForEach(0..<14, id: \.self) { index in
                    dot(index)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func dot(_ index: Int) -> some View {
        let pair = index % 2
        let base = Double(index / 2) / 7 * 2 * .pi - .pi / 2
        let angle = base + (pair == 0 ? -0.18 : 0.18)
        let reach: CGFloat = 0.6 + 0.55 * pop.dots
        let distance: CGFloat = size * reach * (pair == 0 ? 1 : 0.85)
        let fill: Color = dotColors.isEmpty ? color : dotColors[index % dotColors.count]
        return Circle()
            .fill(fill)
            .frame(width: size * 0.16, height: size * 0.16)
            .scaleEffect(1 - pop.dots * 0.9)
            .offset(x: CGFloat(cos(angle)) * distance, y: CGFloat(sin(angle)) * distance)
    }
}

#Preview {
    struct Demo: View {
        @State private var liked = false
        var body: some View {
            LikeButton(isLiked: $liked, size: 40)
        }
    }
    return Demo().padding(60)
}
