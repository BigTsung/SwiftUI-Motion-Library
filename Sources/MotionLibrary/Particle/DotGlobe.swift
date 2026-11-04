import SwiftUI

/// A globe made of evenly spread dots, spinning slowly on a tilted axis.
/// Dots on the far side are smaller and fainter, which sells the depth,
/// and a few "cities" pulse.
public struct DotGlobe: View {
    private let dots: Int
    private let color: Color
    private let accent: Color
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - dots: Number of dots on the sphere.
    ///   - color: Dot colour.
    ///   - accent: Colour of the pulsing cities.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    public init(dots: Int = 700, color: Color = .cyan, accent: Color = .pink, speed: Double = 1) {
        self.dots = max(10, dots)
        self.color = color
        self.accent = accent
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate * speed
            Canvas { context, size in
                let radius = min(size.width, size.height) * 0.45
                let centre = CGPoint(x: size.width / 2, y: size.height / 2)
                let spin = time * 0.6
                let tilt = 0.35
                let golden = Double.pi * (3 - sqrt(5))
                for index in 0..<dots {
                    // Fibonacci sphere: evenly spread points.
                    let y = 1 - 2 * (Double(index) + 0.5) / Double(dots)
                    let ring = sqrt(1 - y * y)
                    let theta = golden * Double(index) + spin
                    var x = cos(theta) * ring, z = sin(theta) * ring
                    // Tilt the axis towards the viewer.
                    let ty = y * cos(tilt) - z * sin(tilt)
                    z = y * sin(tilt) + z * cos(tilt)
                    x *= 1
                    let depth = (z + 1) / 2 // 0 = back, 1 = front
                    let isCity = index % 61 == 0
                    let pulse = isCity ? 0.5 + 0.5 * sin(time * 3 + Double(index)) : 0
                    let r = (0.6 + 1.2 * depth) * (isCity ? 1.8 + pulse : 1)
                    let p = CGPoint(x: centre.x + CGFloat(x) * radius, y: centre.y - CGFloat(ty) * radius)
                    let tint = isCity && depth > 0.5 ? accent : color
                    context.fill(
                        Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                        with: .color(tint.opacity(0.12 + 0.88 * depth * depth))
                    )
                }
                // A faint rim light.
                context.stroke(
                    Path(ellipseIn: CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2)),
                    with: .color(color.opacity(0.15)), lineWidth: 1
                )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

#Preview {
    DotGlobe()
        .frame(width: 260, height: 260)
        .background(Color(red: 0.03, green: 0.05, blue: 0.12))
}
