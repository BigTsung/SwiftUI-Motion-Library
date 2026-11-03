import SwiftUI

/// Live-stream style reactions: every time `trigger` changes, an emoji pops
/// up from the bottom of the view, floats upward swaying, and fades out.
struct FloatingReactionsModifier<Trigger: Equatable>: ViewModifier {
    var trigger: Trigger
    var emojis: [String]
    var height: CGFloat

    @State private var reactions: [FloatingReaction] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                ZStack {
                    ForEach(reactions) { reaction in
                        FloatingEmoji(reaction: reaction, height: height)
                    }
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .onChange(of: trigger) {
                // Reduce Motion: no floating emoji.
                guard !reduceMotion, let emoji = emojis.randomElement() else { return }
                let reaction = FloatingReaction(
                    emoji: emoji,
                    sway: .random(in: 8...18) * (Bool.random() ? 1 : -1),
                    drift: .random(in: -20...20)
                )
                reactions.append(reaction)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                    reactions.removeAll { $0.id == reaction.id }
                }
            }
    }
}

/// One emoji on its way up, with its own random sway.
struct FloatingReaction: Identifiable {
    let id = UUID()
    let emoji: String
    let sway: CGFloat
    let drift: CGFloat
}

private struct FloatValues {
    var y: CGFloat = 0
    var x: CGFloat = 0
    var scale: CGFloat = 0.3
    var opacity: Double = 1
}

private struct FloatingEmoji: View {
    let reaction: FloatingReaction
    let height: CGFloat

    /// Flipped on appear to play the keyframes once (the `repeating: false`
    /// variant never plays them at all).
    @State private var launched = false

    var body: some View {
        let sway = reaction.sway
        let drift = reaction.drift
        let height = height
        Text(reaction.emoji)
            .font(.system(size: 28))
            .onAppear { launched = true }
            .keyframeAnimator(initialValue: FloatValues(), trigger: launched) { view, value in
                view
                    .scaleEffect(value.scale)
                    .offset(x: value.x, y: value.y)
                    .opacity(value.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.y) {
                    CubicKeyframe(-height, duration: 2.2)
                }
                KeyframeTrack(\.x) {
                    CubicKeyframe(sway, duration: 0.55)
                    CubicKeyframe(-sway + drift, duration: 0.55)
                    CubicKeyframe(sway + drift, duration: 0.55)
                    CubicKeyframe(drift, duration: 0.55)
                }
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.15, duration: 0.25, spring: .bouncy)
                    CubicKeyframe(1, duration: 0.3)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(1, duration: 1.4)
                    LinearKeyframe(0, duration: 0.8)
                }
            }
    }
}

public extension View {
    /// Floats an emoji up from the bottom of the view every time `trigger`
    /// changes.
    ///
    /// ```swift
    /// LiveVideo()
    ///     .floatingReactions(trigger: reactionCount)
    ///
    /// Button("❤️") { reactionCount += 1 }
    /// ```
    ///
    /// - Parameters:
    ///   - emojis: One is picked at random for each reaction.
    ///   - height: How far each reaction rises, in points.
    func floatingReactions<Trigger: Equatable>(
        trigger: Trigger,
        emojis: [String] = ["❤️", "🔥", "👏", "😂", "😍"],
        height: CGFloat = 160
    ) -> some View {
        modifier(FloatingReactionsModifier(trigger: trigger, emojis: emojis, height: height))
    }
}

#Preview {
    struct Demo: View {
        @State private var count = 0
        var body: some View {
            Button("React") { count += 1 }
                .buttonStyle(.borderedProminent)
                .floatingReactions(trigger: count)
                .padding(.top, 180)
        }
    }
    return Demo().padding()
}
