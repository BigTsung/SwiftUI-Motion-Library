import SwiftUI

/// Turns the view into a kaleidoscope: one wedge is mirrored around the
/// centre, and turning the wedge makes the pattern bloom and fold.
/// Rendered with a Metal `layerEffect` (`Shaders/Kaleidoscope.metal`).
struct KaleidoscopeModifier: ViewModifier {
    var segments: Int
    var rotation: Angle
    var spins: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if spins && !reduceMotion {
            TimelineView(.animation) { timeline in
                let turn = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3600) * 0.25
                content.modifier(KaleidoscopeEffect(segments: segments, rotation: rotation.radians + turn))
            }
        } else {
            content.modifier(KaleidoscopeEffect(segments: segments, rotation: rotation.radians))
        }
    }
}

struct KaleidoscopeEffect: ViewModifier, Animatable {
    var segments: Int
    var rotation: Double

    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }

    func body(content: Content) -> some View {
        let segments = Float(max(2, segments)), rotation = Float(rotation)
        return content.visualEffect { effect, proxy in
            effect.layerEffect(
                motionShaders.motionKaleidoscope(.float2(proxy.size), .float(segments), .float(rotation)),
                maxSampleOffset: proxy.size
            )
        }
    }
}

public extension View {
    /// Mirrors the view into a kaleidoscope with `segments` reflections.
    ///
    /// ```swift
    /// Image("flowers")
    ///     .kaleidoscope(segments: 8)           // turns on its own
    /// Pattern()
    ///     .kaleidoscope(segments: 6, rotation: angle, spins: false)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameters:
    ///   - segments: Number of mirrored wedges.
    ///   - rotation: Which part of the view the wedge samples; animatable.
    ///   - spins: Keep turning the wedge, so the pattern keeps changing.
    func kaleidoscope(segments: Int = 8, rotation: Angle = .zero, spins: Bool = true) -> some View {
        modifier(KaleidoscopeModifier(segments: segments, rotation: rotation, spins: spins))
    }
}

#Preview {
    AngularGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red], center: .topLeading)
        .overlay(Image(systemName: "leaf.fill").font(.system(size: 60)).foregroundStyle(.white).offset(x: 40, y: 20))
        .frame(width: 240, height: 240)
        .kaleidoscope(segments: 8)
}
