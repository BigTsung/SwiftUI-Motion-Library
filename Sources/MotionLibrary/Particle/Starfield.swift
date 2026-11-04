import SwiftUI

/// Flying through space: stars stream out from the centre and stretch into
/// streaks as they pass the camera. Raise `speed` for a warp jump.
public struct Starfield: View {
    private let speed: Double
    private let color: Color
    private let stars: [Star]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - count: Number of stars.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    ///   - color: Star colour.
    public init(count: Int = 200, speed: Double = 1, color: Color = .white) {
        self.speed = speed * 0.35
        self.color = color
        var generator = SplitMix64(seed: 7)
        stars = (0..<max(0, count)).map { _ in
            Star(
                x: generator.unit() * 2 - 1,
                y: generator.unit() * 2 - 1,
                depth: generator.unit()
            )
        }
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let centre = CGPoint(x: size.width / 2, y: size.height / 2)
                let scale = max(size.width, size.height) * 0.5
                // Streak length: where the star was a moment ago.
                let trail = min(0.08, speed * 0.05)
                for star in stars {
                    // Depth runs 1 (far) → 0.05 (at the camera), then wraps.
                    let z = 0.05 + 0.95 * (star.depth - time * speed).wrappedUnit
                    let zBehind = min(1, z + trail)
                    let head = CGPoint(x: centre.x + star.x / z * scale * 0.15, y: centre.y + star.y / z * scale * 0.15)
                    let tail = CGPoint(x: centre.x + star.x / zBehind * scale * 0.15, y: centre.y + star.y / zBehind * scale * 0.15)
                    let brightness = min(1, (1 - z) * 1.4)
                    var streak = Path()
                    streak.move(to: tail)
                    streak.addLine(to: head)
                    context.stroke(
                        streak,
                        with: .color(color.opacity(brightness)),
                        style: StrokeStyle(lineWidth: max(0.6, (1 - z) * 2.4), lineCap: .round)
                    )
                }
            }
        }
        .accessibilityHidden(true)
    }

    private struct Star {
        var x: Double
        var y: Double
        var depth: Double
    }
}

private extension Double {
    /// Wraps the value into 0..<1.
    var wrappedUnit: Double {
        let r = truncatingRemainder(dividingBy: 1)
        return r < 0 ? r + 1 : r
    }
}

#Preview {
    Starfield()
        .background(.black)
        .frame(width: 320, height: 220)
}
