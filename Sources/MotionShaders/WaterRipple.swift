import SwiftUI

/// A water ripple that spreads from a point across the view's pixels: a
/// ring wave pushes them in and out and brightens the crests, ringing a
/// few times before it fades. Rendered with a Metal `layerEffect`
/// (`Shaders/WaterRipple.metal`).
struct WaterRippleModifier<Trigger: Equatable>: ViewModifier {
    var origin: CGPoint
    var trigger: Trigger
    var amplitude: Double
    var duration: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let origin = origin, amplitude = amplitude, duration = duration
        let enabled = !reduceMotion
        return content.keyframeAnimator(initialValue: 0.0, trigger: trigger) { view, elapsed in
            view.visualEffect { effect, _ in
                effect.layerEffect(
                    motionShaders.motionRipple(
                        .float2(origin),
                        .float(elapsed),
                        .float(amplitude),
                        .float(15), // frequency
                        .float(8), // decay
                        .float(1200) // speed, points per second
                    ),
                    maxSampleOffset: CGSize(width: amplitude, height: amplitude),
                    isEnabled: enabled && elapsed > 0 && elapsed < duration
                )
            }
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }
}

/// Starts a ripple wherever the view is tapped.
struct WaterRippleOnTapModifier: ViewModifier {
    var amplitude: Double

    @State private var origin: CGPoint = .zero
    @State private var taps = 0

    func body(content: Content) -> some View {
        content
            .modifier(WaterRippleModifier(origin: origin, trigger: taps, amplitude: amplitude, duration: 3))
            .simultaneousGesture(
                SpatialTapGesture().onEnded { value in
                    origin = value.location
                    taps += 1
                }
            )
    }
}

public extension View {
    /// Sends a water ripple across the view from `origin` every time
    /// `trigger` changes.
    ///
    /// ```swift
    /// Image("photo")
    ///     .waterRipple(at: tapLocation, trigger: tapCount)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameters:
    ///   - origin: Where the ripple starts, in the view's coordinates.
    ///   - trigger: Starts a new ripple whenever it changes.
    ///   - amplitude: How far pixels are pushed, in points.
    ///   - duration: How long the ripple lasts, in seconds.
    func waterRipple<Trigger: Equatable>(at origin: CGPoint, trigger: Trigger, amplitude: Double = 12, duration: Double = 3) -> some View {
        modifier(WaterRippleModifier(origin: origin, trigger: trigger, amplitude: amplitude, duration: duration))
    }

    /// Sends a water ripple out from wherever the view is tapped.
    ///
    /// ```swift
    /// Image("pond")
    ///     .waterRippleOnTap()
    /// ```
    func waterRippleOnTap(amplitude: Double = 12) -> some View {
        modifier(WaterRippleOnTapModifier(amplitude: amplitude))
    }
}

#Preview {
    LinearGradient(colors: [.cyan, .blue, .indigo], startPoint: .top, endPoint: .bottom)
        .overlay(Image(systemName: "fish.fill").font(.system(size: 60)).foregroundStyle(.white))
        .frame(width: 280, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .waterRippleOnTap()
}
