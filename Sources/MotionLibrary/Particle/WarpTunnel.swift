import SwiftUI

/// Flying through a tunnel: rings rush out of the vanishing point toward the
/// viewer, growing, brightening and turning as they pass.
public struct WarpTunnel: View {
    private let rings: Int
    private let colors: [Color]
    private let speed: Double
    private let sides: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - rings: Number of rings in the tunnel.
    ///   - colors: Ring colours, cycled from the back of the tunnel.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    ///   - sides: 0 for circles, 3 or more for polygons (6 = hexagons).
    public init(
        rings: Int = 18,
        colors: [Color] = [.cyan, .blue, .purple, .pink],
        speed: Double = 1,
        sides: Int = 0
    ) {
        self.rings = max(2, rings)
        self.colors = colors.isEmpty ? [.white] : colors
        self.speed = speed * 1.2
        self.sides = sides
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate * speed
            Canvas { context, size in
                let centre = CGPoint(x: size.width / 2, y: size.height / 2)
                let reach = hypot(size.width, size.height) / 2
                let offset = time - time.rounded(.down)
                for ring in 0..<rings {
                    // Depth 1 is the far end, near 0 the viewer.
                    let depth = 1 - (Double(ring) + offset) / Double(rings)
                    guard depth > 0.02 else { continue }
                    let radius = reach * CGFloat(0.06 / depth)
                    guard radius < reach * 1.5 else { continue }
                    let closeness = 1 - depth
                    let index = (Int(time.rounded(.down)) + ring) % colors.count
                    let path = ringPath(centre: centre, radius: radius, rotation: Double(ring) * 0.12 + time * 0.1)
                    context.stroke(
                        path,
                        with: .color(colors[index].opacity(closeness * closeness)),
                        lineWidth: 0.5 + 3 * CGFloat(closeness)
                    )
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func ringPath(centre: CGPoint, radius: CGFloat, rotation: Double) -> Path {
        guard sides >= 3 else {
            return Path(ellipseIn: CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2))
        }
        var path = Path()
        for corner in 0...sides {
            let angle = Double(corner) / Double(sides) * 2 * .pi + rotation
            let point = CGPoint(x: centre.x + CGFloat(cos(angle)) * radius, y: centre.y + CGFloat(sin(angle)) * radius)
            corner == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    WarpTunnel(sides: 6)
        .background(.black)
        .frame(width: 320, height: 220)
}
