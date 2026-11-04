import SwiftUI

/// Planets circle a glowing star on tilted orbits, passing behind it and in
/// front of it, getting smaller and dimmer on the far side, like a little
/// solar system or an atom.
///
/// ```swift
/// Orbits(colors: [.orange, .cyan, .pink])
///     .frame(width: 240, height: 160)
/// ```
public struct Orbits: View {
    private let colors: [Color]
    private let tilt: Double
    private let centerColor: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - colors: One planet per colour, from the innermost orbit out.
    ///   - tilt: How flat the orbits look: 0 is seen edge-on, 1 from above.
    ///   - centerColor: Colour of the central star.
    public init(colors: [Color] = [.orange, .cyan, .pink, .mint], tilt: Double = 0.38, centerColor: Color = .yellow) {
        self.colors = colors
        self.tilt = min(1, max(0.05, tilt))
        self.centerColor = centerColor
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let centre = CGPoint(x: size.width / 2, y: size.height / 2)
                let maxRadius = min(size.width / 2, size.height / 2 / tilt) * 0.92
                let planets = colors.enumerated().map { index, color in
                    let radius = maxRadius * (0.38 + 0.62 * Double(index + 1) / Double(colors.count))
                    // Inner planets go round faster (roughly Kepler's third law).
                    let period = 2.4 * pow(radius / maxRadius * 2, 1.5)
                    let angle = time / period * 2 * .pi + Double(index) * 2.1
                    let depth = sin(angle) // > 0: in front of the star
                    let point = CGPoint(x: centre.x + cos(angle) * radius, y: centre.y + sin(angle) * radius * tilt)
                    return (radius: radius, point: point, depth: depth, color: color, size: 5 + Double(index % 3) * 2)
                }
                // Orbit rings.
                for planet in planets {
                    let r = planet.radius
                    context.stroke(Path(ellipseIn: CGRect(x: centre.x - r, y: centre.y - r * tilt, width: r * 2, height: r * 2 * tilt)), with: .color(.white.opacity(0.14)), lineWidth: 1)
                }
                func draw(_ planet: (radius: Double, point: CGPoint, depth: Double, color: Color, size: Double)) {
                    let scale = 0.75 + 0.25 * (planet.depth + 1) / 2
                    let s = planet.size * scale
                    context.fill(Path(ellipseIn: CGRect(x: planet.point.x - s, y: planet.point.y - s, width: s * 2, height: s * 2)),
                                 with: .color(planet.color.opacity(0.55 + 0.45 * (planet.depth + 1) / 2)))
                }
                for planet in planets where planet.depth < 0 { draw(planet) }
                // The star, with a soft glow.
                var glow = context
                glow.addFilter(.blur(radius: 10))
                glow.fill(Path(ellipseIn: CGRect(x: centre.x - 16, y: centre.y - 16, width: 32, height: 32)), with: .color(centerColor.opacity(0.7)))
                context.fill(Path(ellipseIn: CGRect(x: centre.x - 10, y: centre.y - 10, width: 20, height: 20)), with: .color(centerColor))
                for planet in planets where planet.depth >= 0 { draw(planet) }
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    Orbits()
        .frame(width: 320, height: 200)
        .background(Color(red: 0.04, green: 0.05, blue: 0.12))
}
