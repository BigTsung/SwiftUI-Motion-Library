import SwiftUI

/// False-colour "heat vision": brightness becomes temperature, from cold
/// black and indigo through magenta and red to hot yellow and white.
/// `intensity` is animatable, so the view can switch into heat vision.
/// Rendered with a Metal `colorEffect` (`Shaders/Thermal.metal`).
struct ThermalModifier: ViewModifier, Animatable {
    var intensity: Double

    nonisolated var animatableData: Double {
        get { intensity }
        set { intensity = newValue }
    }

    func body(content: Content) -> some View {
        content.colorEffect(motionShaders.motionThermal(.float(intensity)), isEnabled: intensity > 0)
    }
}

public extension View {
    /// Shows the view through a heat camera. Animate `intensity` between 0
    /// and 1 to switch it on and off.
    ///
    /// ```swift
    /// Image("street")
    ///     .thermal(isScanning ? 1 : 0)
    ///     .animation(.easeInOut(duration: 0.6), value: isScanning)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameter intensity: 0 shows the original colours, 1 the full heat palette.
    func thermal(_ intensity: Double = 1) -> some View {
        modifier(ThermalModifier(intensity: intensity))
    }
}

#Preview {
    RadialGradient(colors: [.white, .gray, .black], center: .center, startRadius: 10, endRadius: 140)
        .frame(width: 260, height: 180)
        .thermal()
}
