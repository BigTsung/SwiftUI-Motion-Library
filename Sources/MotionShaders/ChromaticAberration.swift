import SwiftUI

/// Splits the red and blue channels sideways like a cheap lens or a glitchy
/// screen. The amount is animatable, so it can pulse on a beat or spike on
/// an event. Rendered with a Metal `layerEffect`
/// (`Shaders/ChromaticAberration.metal`).
struct ChromaticAberrationModifier: ViewModifier, Animatable {
    var amount: Double

    var animatableData: Double {
        get { amount }
        set { amount = newValue }
    }

    func body(content: Content) -> some View {
        content.layerEffect(
            motionShaders.motionChromatic(.float(amount)),
            maxSampleOffset: CGSize(width: abs(amount), height: 0),
            isEnabled: abs(amount) > 0.01
        )
    }
}

public extension View {
    /// Shifts the red channel right and the blue channel left by `amount`
    /// points. Animate it for a pulsing RGB split.
    ///
    /// ```swift
    /// Text("BASS DROP")
    ///     .chromaticAberration(isPlaying ? 6 : 0)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    func chromaticAberration(_ amount: Double = 4) -> some View {
        modifier(ChromaticAberrationModifier(amount: amount))
    }
}

#Preview {
    Text("RGB SPLIT")
        .font(.system(size: 44, weight: .black))
        .chromaticAberration(5)
        .padding()
}
