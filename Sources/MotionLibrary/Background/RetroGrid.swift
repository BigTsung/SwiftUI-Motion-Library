import SwiftUI

/// A synthwave floor: a perspective grid that scrolls toward the viewer and
/// fades into the horizon.
public struct RetroGrid: View {
    private let color: Color
    private let spacing: CGFloat
    private let speed: Double
    private let horizon: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - color: Line colour.
    ///   - spacing: Distance between lines at the bottom edge, in points.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    ///   - horizon: Height of the horizon, as a fraction of the view (0 = top).
    public init(color: Color = .pink, spacing: CGFloat = 40, speed: Double = 1, horizon: CGFloat = 0.35) {
        self.color = color
        self.spacing = spacing
        self.speed = speed * 0.8
        self.horizon = horizon
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion || speed == 0)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                draw(in: &context, size: size, time: time)
            }
        }
        .mask {
            LinearGradient(
                stops: [.init(color: .clear, location: horizon), .init(color: .black, location: min(1, horizon + 0.45))],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .accessibilityHidden(true)
    }

    private func draw(in context: inout GraphicsContext, size: CGSize, time: Double) {
        let top = size.height * horizon
        let depth = size.height - top
        guard depth > 0, spacing > 0 else { return }
        let centre = size.width / 2
        var path = Path()

        // Horizontal lines at depths z = 1, 2, 3…; y = top + depth / z puts
        // z = 1 at the bottom edge and z → ∞ at the horizon. Shifting z by the
        // fractional time moves every row toward the viewer.
        let shift = time * speed
        let scroll = shift - shift.rounded(.down)
        for row in 0..<40 {
            let z = CGFloat(Double(row) + 1 - scroll)
            guard z > 0.05 else { continue }
            let y = top + depth / z
            guard y <= size.height + 1 else { continue }
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
        }

        // Lines running into the distance all meet at the vanishing point.
        let columns = Int(size.width / spacing) + 4
        for column in -columns...columns {
            let x = centre + CGFloat(column) * spacing
            path.move(to: CGPoint(x: centre, y: top))
            path.addLine(to: CGPoint(x: x, y: size.height))
        }

        context.stroke(path, with: .color(color.opacity(0.35)), lineWidth: 3)
        context.stroke(path, with: .color(color), lineWidth: 1)
    }
}

#Preview {
    RetroGrid()
        .background(Color(red: 0.08, green: 0.02, blue: 0.15))
        .frame(width: 320, height: 200)
}
