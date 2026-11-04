import SwiftUI

/// Layered sine waves rolling across the bottom of the view, each layer a
/// little slower and paler than the one in front, like an ocean horizon.
public struct WaveBackground: View {
    private let colors: [Color]
    private let amplitude: CGFloat
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - colors: One colour per layer, back to front.
    ///   - amplitude: Wave height, in points.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    public init(
        colors: [Color] = [.cyan.opacity(0.35), .blue.opacity(0.45), .indigo.opacity(0.7)],
        amplitude: CGFloat = 12,
        speed: Double = 1
    ) {
        self.colors = colors
        self.amplitude = amplitude
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate * speed
            Canvas { context, size in
                for (layer, color) in colors.enumerated() {
                    let depth = CGFloat(layer) / CGFloat(max(1, colors.count - 1))
                    // Back layers sit higher, move slower and have longer waves.
                    let baseline = size.height * (0.45 + 0.2 * depth)
                    let wavelength = size.width * (0.9 - 0.3 * depth)
                    let phase = time * (0.6 + 0.5 * depth) * (layer.isMultiple(of: 2) ? 1 : -1)
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: size.height))
                    for x in stride(from: 0, through: size.width, by: 4) {
                        let angle = Double(x / wavelength) * 2 * .pi + phase + Double(layer)
                        let y = baseline + CGFloat(sin(angle)) * amplitude * (0.7 + 0.3 * depth)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.closeSubpath()
                    context.fill(path, with: .color(color))
                }
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    WaveBackground()
        .frame(width: 320, height: 200)
        .background(Color.cyan.opacity(0.08))
}
