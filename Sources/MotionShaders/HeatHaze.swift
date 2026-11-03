import SwiftUI

/// Makes the view shimmer like air over hot asphalt or a desert road:
/// layered noise wobbles pixels sideways, rising over time, stronger towards
/// the bottom. Rendered with a Metal `distortionEffect`
/// (`Shaders/HeatHaze.metal`).
struct HeatHazeModifier: ViewModifier {
    var strength: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        // Reduce Motion: no shimmer.
        let strength = reduceMotion ? 0 : strength
        return TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1000)
            content.visualEffect { effect, proxy in
                effect.distortionEffect(
                    motionShaders.motionHeatHaze(.float2(proxy.size), .float(time), .float(strength)),
                    maxSampleOffset: CGSize(width: strength, height: strength),
                    isEnabled: strength > 0
                )
            }
        }
    }
}

public extension View {
    /// Makes the view shimmer like hot air.
    ///
    /// ```swift
    /// Image("desert-road")
    ///     .heatHaze()
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameter strength: How far pixels wobble, in points.
    func heatHaze(strength: Double = 6) -> some View {
        modifier(HeatHazeModifier(strength: strength))
    }
}

#Preview {
    LinearGradient(colors: [.orange, .yellow, .brown], startPoint: .top, endPoint: .bottom)
        .overlay(Image(systemName: "sun.max.fill").font(.system(size: 70)).foregroundStyle(.white))
        .frame(width: 280, height: 200)
        .heatHaze(strength: 8)
        .clipShape(RoundedRectangle(cornerRadius: 20))
}
