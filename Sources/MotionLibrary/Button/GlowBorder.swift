import SwiftUI

/// A gradient border that keeps rotating around the view, with a soft glow
/// behind it. Draws attention to a primary action or a highlighted card.
struct GlowBorderModifier: ViewModifier {
    var colors: [Color]
    var cornerRadius: CGFloat
    var lineWidth: CGFloat
    var glowRadius: CGFloat
    var duration: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                TimelineView(.animation(paused: reduceMotion)) { timeline in
                    let turns = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate / duration
                    let gradient = AngularGradient(
                        colors: colors + [colors.first ?? .clear],
                        center: .center,
                        angle: .degrees(turns.truncatingRemainder(dividingBy: 1) * 360)
                    )
                    let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    ZStack {
                        shape.stroke(gradient, lineWidth: lineWidth * 2)
                            .blur(radius: glowRadius)
                            .opacity(0.8)
                        shape.stroke(gradient, lineWidth: lineWidth)
                    }
                }
                .allowsHitTesting(false)
            }
    }
}

public extension View {
    /// Adds a rotating gradient border with a glow.
    ///
    /// ```swift
    /// Text("Upgrade to Pro")
    ///     .padding()
    ///     .background(.black, in: RoundedRectangle(cornerRadius: 14))
    ///     .glowBorder(cornerRadius: 14)
    /// ```
    func glowBorder(
        colors: [Color] = [.pink, .purple, .blue, .cyan, .mint],
        cornerRadius: CGFloat = 14,
        lineWidth: CGFloat = 2,
        glowRadius: CGFloat = 8,
        duration: Double = 3
    ) -> some View {
        modifier(GlowBorderModifier(
            colors: colors,
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            glowRadius: glowRadius,
            duration: duration
        ))
    }
}

#Preview {
    Text("Upgrade to Pro")
        .font(.headline)
        .foregroundStyle(.white)
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(.black, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .glowBorder()
        .padding(40)
}
