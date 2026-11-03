import SwiftUI

/// While scrolling, each card sticks at the top of the scroll view, then
/// shrinks and dims as the next card slides over it, so the cards pile up
/// like a deck (Apple Wallet style). Uses `visualEffect`, so it costs no
/// layout passes.
struct StackingCardModifier: ViewModifier {
    var top: CGFloat
    var scale: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let top = top, scale = scale, reduceMotion = reduceMotion
        return content.visualEffect { effect, proxy in
            let frame = proxy.frame(in: .scrollView)
            let height = max(1, frame.height)
            // How far the card has scrolled past its pin line.
            let overshoot = max(0, top - frame.minY)
            let covered = min(1, overshoot / height)
            // Once fully covered, fade it so the pile stays tidy.
            let gone = min(1, max(0, overshoot / height - 1))
            return effect
                .offset(y: overshoot)
                .scaleEffect(reduceMotion ? 1 : 1 - (1 - scale) * covered, anchor: .top)
                .brightness(-0.25 * covered)
                .opacity(1 - gone)
        }
    }
}

public extension View {
    /// Pins the card at the top of its scroll view and shrinks it as the
    /// next card slides over it. Apply to every card in a `VStack` inside a
    /// vertical `ScrollView`.
    ///
    /// ```swift
    /// ScrollView {
    ///     VStack(spacing: 16) {
    ///         ForEach(cards) { card in
    ///             CardView(card).stackingCard()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - top: Distance from the top of the scroll view where cards stick.
    ///   - scale: How small a fully covered card gets.
    func stackingCard(top: CGFloat = 16, scale: CGFloat = 0.88) -> some View {
        modifier(StackingCardModifier(top: top, scale: scale))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach([Color.pink, .orange, .teal, .indigo, .mint, .purple], id: \.self) { color in
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.gradient)
                    .frame(height: 180)
                    .stackingCard()
            }
        }
        .padding()
        .padding(.bottom, 300)
    }
}
