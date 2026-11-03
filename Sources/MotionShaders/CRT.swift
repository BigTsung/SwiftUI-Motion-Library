import SwiftUI

/// Makes the view look like it's on an old CRT monitor: curved glass,
/// scanlines, a slow rolling band, slight colour fringing, a vignette and a
/// faint flicker. Rendered with a Metal `layerEffect` (`Shaders/CRT.metal`).
struct CRTModifier: ViewModifier {
    var curvature: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let curvature = curvature
        // Reduce Motion: the screen stays, the band and flicker stop.
        return TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1000)
            content.visualEffect { effect, proxy in
                effect.layerEffect(
                    motionShaders.motionCRT(.float2(proxy.size), .float(time), .float(curvature)),
                    maxSampleOffset: CGSize(width: proxy.size.width * curvature, height: proxy.size.height * curvature)
                )
            }
        }
    }
}

public extension View {
    /// Shows the view on a retro CRT screen.
    ///
    /// ```swift
    /// GameView()
    ///     .crtScreen()
    ///     .clipShape(RoundedRectangle(cornerRadius: 24))
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameter curvature: How much the glass bulges (0 = flat).
    func crtScreen(curvature: Double = 0.06) -> some View {
        modifier(CRTModifier(curvature: curvature))
    }
}

#Preview {
    VStack(spacing: 8) {
        Text("READY.").font(.system(size: 28, weight: .bold, design: .monospaced))
        Text("LOAD \"*\",8,1").font(.system(size: 18, design: .monospaced))
    }
    .foregroundStyle(.green)
    .frame(width: 300, height: 200)
    .background(Color(red: 0.02, green: 0.08, blue: 0.04))
    .crtScreen()
    .clipShape(RoundedRectangle(cornerRadius: 20))
}
