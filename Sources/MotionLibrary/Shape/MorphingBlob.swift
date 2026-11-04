import SwiftUI

/// An organic blob whose outline keeps morphing, like a lava lamp. Use it as
/// an avatar backdrop, a "listening" indicator or a hero decoration.
public struct MorphingBlob<Fill: ShapeStyle>: View {
    private let fill: Fill
    private let points: Int
    private let wobble: CGFloat
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - fill: Any shape style: a colour, gradient or material.
    ///   - points: Number of lobes around the outline (4…10 looks organic).
    ///   - wobble: How far the outline moves in and out, as a fraction of the radius.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    public init(fill: Fill, points: Int = 6, wobble: CGFloat = 0.18, speed: Double = 1) {
        self.fill = fill
        self.points = points
        self.wobble = wobble
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion || speed == 0)) { timeline in
            BlobShape(
                time: reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate * speed,
                points: points,
                wobble: wobble
            )
            .fill(fill)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

public extension MorphingBlob where Fill == LinearGradient {
    /// A blob filled with a diagonal gradient.
    init(colors: [Color] = [.purple, .pink, .orange], points: Int = 6, wobble: CGFloat = 0.18, speed: Double = 1) {
        self.init(
            fill: LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
            points: points,
            wobble: wobble,
            speed: speed
        )
    }
}

/// A closed, smooth outline through `points` control points whose distance
/// from the centre is a sum of slow sine waves.
struct BlobShape: Shape {
    var time: Double
    var points: Int
    var wobble: CGFloat

    nonisolated func path(in rect: CGRect) -> Path {
        let count = max(3, points)
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2 * (1 - wobble)
        let vertices: [CGPoint] = (0..<count).map { index in
            let angle = Double(index) / Double(count) * 2 * .pi
            let i = Double(index)
            // Two waves with unrelated frequencies so the motion never visibly repeats.
            let offset = sin(time * 1.1 + i * 1.7) * 0.6 + sin(time * 0.7 + i * 2.9) * 0.4
            let radius = baseRadius * (1 + wobble * CGFloat(offset))
            return CGPoint(x: centre.x + CGFloat(cos(angle)) * radius, y: centre.y + CGFloat(sin(angle)) * radius)
        }
        return smoothClosedPath(through: vertices)
    }

    /// Catmull-Rom spline through the points, as cubic Béziers.
    private func smoothClosedPath(through p: [CGPoint]) -> Path {
        var path = Path()
        let n = p.count
        path.move(to: p[0])
        for i in 0..<n {
            let p0 = p[(i - 1 + n) % n], p1 = p[i], p2 = p[(i + 1) % n], p3 = p[(i + 2) % n]
            let c1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
            let c2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
            path.addCurve(to: p2, control1: c1, control2: c2)
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    MorphingBlob()
        .frame(width: 200, height: 200)
        .padding()
}
