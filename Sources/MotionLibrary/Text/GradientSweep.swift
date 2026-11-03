import SwiftUI

/// Fills the view's own pixels with a multi-colour gradient that keeps
/// flowing sideways. Made for headlines, but works on symbols and shapes too.
struct GradientSweepModifier: ViewModifier {
    var colors: [Color]
    var duration: Double

    @State private var flowing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let width = max(1, geometry.size.width)
                    // Two copies of the palette side by side, twice as wide as
                    // the view. Sliding left by one view width shows the second
                    // copy, which looks exactly like the first, so it loops.
                    let palette = colors.isEmpty ? [Color.primary] : colors
                    LinearGradient(
                        colors: palette + palette + [palette[0]],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: width * 2, height: geometry.size.height)
                    .offset(x: flowing ? -width : 0)
                }
                .mask { content }
                .allowsHitTesting(false)
            }
            .onAppear {
                guard !reduceMotion else { return }
                flowing = false
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    flowing = true
                }
            }
    }
}

public extension View {
    /// Paints the view with a gradient that flows sideways forever.
    ///
    /// ```swift
    /// Text("Motion Library")
    ///     .font(.largeTitle.bold())
    ///     .gradientSweep()
    /// ```
    func gradientSweep(
        colors: [Color] = [.pink, .orange, .yellow, .mint, .cyan, .purple],
        duration: Double = 3
    ) -> some View {
        modifier(GradientSweepModifier(colors: colors, duration: duration))
    }
}

#Preview {
    Text("Motion Library")
        .font(.largeTitle.weight(.heavy))
        .gradientSweep()
        .padding()
}
