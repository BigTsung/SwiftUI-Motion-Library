import SwiftUI

/// Redraws the view as round printing dots on paper, like newsprint or a
/// comic: darker areas get bigger dots, each in the colour underneath.
/// `dotSize` is animatable. Rendered with a Metal `layerEffect`
/// (`Shaders/Halftone.metal`).
struct HalftoneModifier: ViewModifier, Animatable {
    var dotSize: Double
    var angle: Angle
    var paper: Color

    nonisolated var animatableData: Double {
        get { dotSize }
        set { dotSize = newValue }
    }

    func body(content: Content) -> some View {
        let size = max(1, dotSize)
        content.layerEffect(
            motionShaders.motionHalftone(.float(size), .float(angle.radians), .color(paper)),
            maxSampleOffset: CGSize(width: size, height: size),
            isEnabled: dotSize >= 1.5
        )
    }
}

public extension View {
    /// Prints the view in halftone dots. Animate `dotSize` from 1 (off) up
    /// to bring the dots in.
    ///
    /// ```swift
    /// Image("portrait")
    ///     .halftone(dotSize: 8)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameters:
    ///   - dotSize: Spacing of the dot grid, in points. Below 1.5 the effect is off.
    ///   - angle: Rotation of the dot grid (print screens use 45°).
    ///   - paper: Colour between the dots.
    func halftone(dotSize: Double = 8, angle: Angle = .degrees(45), paper: Color = .white) -> some View {
        modifier(HalftoneModifier(dotSize: dotSize, angle: angle, paper: paper))
    }
}

#Preview {
    LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        .overlay(Image(systemName: "star.fill").font(.system(size: 80)).foregroundStyle(.yellow))
        .frame(width: 260, height: 180)
        .halftone(dotSize: 7)
}
