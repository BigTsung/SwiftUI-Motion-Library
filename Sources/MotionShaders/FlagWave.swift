import SwiftUI

/// Waves the view like a flag in the wind, held at its leading edge: ripples
/// run along it, growing towards the free end, and the folds catch light
/// and shadow. Rendered with a Metal `layerEffect`
/// (`Shaders/FlagWave.metal`).
struct FlagWaveModifier: ViewModifier {
    var amplitude: Double
    var wavelength: Double
    var speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            TimelineView(.animation(paused: speed == 0)) { timeline in
                let time = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3600) * speed)
                let amplitude = Float(amplitude), wavelength = Float(max(10, wavelength))
                let reach = CGSize(width: Double(amplitude), height: Double(amplitude) * 1.4)
                content
                    .padding(.vertical, Double(amplitude) * 1.4)
                    .visualEffect { effect, proxy in
                        effect.layerEffect(
                            motionShaders.motionFlagWave(.float2(proxy.size), .float(time), .float(amplitude), .float(wavelength)),
                            maxSampleOffset: reach
                        )
                    }
                    .padding(.vertical, -Double(amplitude) * 1.4)
            }
        }
    }
}

public extension View {
    /// Waves the view like a flag held at its leading edge.
    ///
    /// ```swift
    /// Image("banner")
    ///     .flagWave()
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameters:
    ///   - amplitude: Height of the ripples at the free end, in points.
    ///   - wavelength: Length of one ripple, in points.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    func flagWave(amplitude: Double = 9, wavelength: Double = 120, speed: Double = 1) -> some View {
        modifier(FlagWaveModifier(amplitude: amplitude, wavelength: wavelength, speed: speed))
    }
}

#Preview {
    VStack(spacing: 0) {
        Color.red
        Color.white
        Color.blue
    }
    .frame(width: 240, height: 150)
    .flagWave()
}
