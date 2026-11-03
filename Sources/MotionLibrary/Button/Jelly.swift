import SwiftUI

private struct JellyScale {
    var x: CGFloat = 1
    var y: CGFloat = 1
}

/// A rubbery squash-and-stretch wobble that plays every time `trigger`
/// changes: wide and flat, then tall and thin, settling back with a spring.
struct JellyModifier<Trigger: Equatable>: ViewModifier {
    var trigger: Trigger
    var amount: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        // Reduce Motion: stay still.
        let a = reduceMotion ? 0 : amount
        return content.keyframeAnimator(initialValue: JellyScale(), trigger: trigger) { view, scale in
            view.scaleEffect(x: scale.x, y: scale.y)
        } keyframes: { _ in
            KeyframeTrack(\.x) {
                CubicKeyframe(1 + a, duration: 0.1)
                CubicKeyframe(1 - a * 0.8, duration: 0.12)
                CubicKeyframe(1 + a * 0.5, duration: 0.12)
                SpringKeyframe(1, duration: 0.4, spring: .bouncy)
            }
            KeyframeTrack(\.y) {
                CubicKeyframe(1 - a, duration: 0.1)
                CubicKeyframe(1 + a * 0.8, duration: 0.12)
                CubicKeyframe(1 - a * 0.5, duration: 0.12)
                SpringKeyframe(1, duration: 0.4, spring: .bouncy)
            }
        }
    }
}

public extension View {
    /// Wobbles the view like jelly every time `trigger` changes.
    ///
    /// ```swift
    /// Button("Boing") { taps += 1 }
    ///     .buttonStyle(.borderedProminent)
    ///     .jelly(trigger: taps)
    /// ```
    ///
    /// - Parameter amount: How far it squashes (0.25 = 25 %).
    func jelly<Trigger: Equatable>(trigger: Trigger, amount: CGFloat = 0.25) -> some View {
        modifier(JellyModifier(trigger: trigger, amount: amount))
    }
}

#Preview {
    struct Demo: View {
        @State private var taps = 0
        var body: some View {
            Button("Boing") { taps += 1 }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .jelly(trigger: taps)
        }
    }
    return Demo().padding(40)
}
