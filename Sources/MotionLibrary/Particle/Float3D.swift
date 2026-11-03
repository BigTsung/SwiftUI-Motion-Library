import SwiftUI

/// Makes a view hover in space: it bobs up and down and slowly sways in 3D,
/// while its shadow shrinks and grows underneath. For hero images, product
/// shots, badges and empty-state illustrations.
struct Float3DModifier: ViewModifier {
    var height: CGFloat
    var angle: Double
    var period: Double
    var shadow: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let t = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate * 2 * .pi / period
            // Bob: 0 at rest height, 1 at the top.
            let lift = 0.5 + 0.5 * sin(t)
            content
                .rotation3DEffect(.degrees(sin(t * 0.5) * angle), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                .rotation3DEffect(.degrees(cos(t * 0.7) * angle * 0.5), axis: (x: 1, y: 0, z: 0), perspective: 0.5)
                .offset(y: -height * lift)
                .background(alignment: .bottom) {
                    if shadow {
                        Ellipse()
                            .fill(.black.opacity(0.25 - 0.1 * lift))
                            .frame(height: 12)
                            .scaleEffect(x: 0.75 - 0.15 * lift, y: 1)
                            .blur(radius: 6 + 4 * lift)
                            .offset(y: 18)
                    }
                }
        }
    }
}

public extension View {
    /// Floats the view in 3D: a gentle bob, a slow sway and a breathing shadow.
    ///
    /// ```swift
    /// Image("product")
    ///     .resizable()
    ///     .scaledToFit()
    ///     .frame(width: 180)
    ///     .float3D()
    /// ```
    ///
    /// - Parameters:
    ///   - height: How high the view rises, in points.
    ///   - angle: Maximum sway angle, in degrees.
    ///   - period: Seconds for one bob up and down.
    ///   - shadow: Draws a soft ground shadow under the view.
    func float3D(height: CGFloat = 10, angle: Double = 12, period: Double = 3, shadow: Bool = true) -> some View {
        modifier(Float3DModifier(height: height, angle: angle, period: period, shadow: shadow))
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
        .frame(width: 140, height: 140)
        .overlay(Image(systemName: "cube.fill").font(.system(size: 56)).foregroundStyle(.white))
        .float3D()
        .padding(60)
}
