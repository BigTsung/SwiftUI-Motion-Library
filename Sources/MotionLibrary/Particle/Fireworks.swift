import SwiftUI

/// Rockets climb from the bottom of the view and burst into rings of falling,
/// fading sparks, one after another.
public struct Fireworks: View {
    private let colors: [Color]
    private let interval: Double
    private let sparks: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - colors: Burst colours, picked per rocket.
    ///   - interval: Seconds between launches.
    ///   - sparks: Sparks per burst.
    public init(
        colors: [Color] = [.pink, .orange, .yellow, .mint, .cyan, .purple],
        interval: Double = 0.9,
        sparks: Int = 36
    ) {
        self.colors = colors.isEmpty ? [.white] : colors
        self.interval = max(0.2, interval)
        self.sparks = max(1, sparks)
    }

    /// Seconds from launch to burst, and from burst to fully faded.
    private static let climb = 0.8
    private static let fade = 1.5

    public var body: some View {
        // Reduce Motion: a still frame with a burst in full bloom.
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 1.3 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let lifetime = Self.climb + Self.fade
                let newest = Int((time / interval).rounded(.down))
                let oldest = newest - Int((lifetime / interval).rounded(.up))
                for rocket in max(0, oldest)...max(0, newest) {
                    let age = time - Double(rocket) * interval
                    guard age >= 0, age < lifetime else { continue }
                    draw(rocket: rocket, age: age, in: &context, size: size)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func draw(rocket: Int, age: Double, in context: inout GraphicsContext, size: CGSize) {
        var random = SplitMix64(seed: UInt64(truncatingIfNeeded: rocket) &* 2_654_435_761)
        let x = size.width * CGFloat(0.15 + 0.7 * random.unit())
        let peak = size.height * CGFloat(0.15 + 0.3 * random.unit())
        let color = colors[Int(random.unit() * Double(colors.count)) % colors.count]
        let reach = min(size.width, size.height) * CGFloat(0.22 + 0.12 * random.unit())

        if age < Self.climb {
            // Climbing: ease out toward the peak, with a short trail.
            let t = age / Self.climb
            let eased = 1 - pow(1 - t, 2)
            let y = size.height - (size.height - peak) * CGFloat(eased)
            var trail = Path()
            trail.move(to: CGPoint(x: x, y: y + 14))
            trail.addLine(to: CGPoint(x: x, y: y))
            context.stroke(trail, with: .color(color.opacity(0.8)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            return
        }

        // Burst: sparks fly out, slow down, fall under gravity and fade.
        let t = (age - Self.climb) / Self.fade
        let spread = CGFloat(1 - pow(1 - min(1, t * 1.6), 3))
        let fall = CGFloat(t * t) * reach * 0.6
        let opacity = max(0, 1 - t)
        for spark in 0..<sparks {
            let angle = Double(spark) / Double(sparks) * 2 * .pi + random.unit() * 0.1
            let distance = reach * spread * CGFloat(0.75 + 0.25 * random.unit())
            let point = CGPoint(x: x + CGFloat(cos(angle)) * distance, y: peak + CGFloat(sin(angle)) * distance + fall)
            let r = CGFloat(1.8 * (1 - t * 0.6))
            context.fill(
                Path(ellipseIn: CGRect(x: point.x - r, y: point.y - r, width: r * 2, height: r * 2)),
                with: .color(color.opacity(opacity))
            )
        }
        // A flash at the moment of the burst.
        if t < 0.15 {
            let r = reach * 0.35 * CGFloat(t / 0.15)
            context.fill(
                Path(ellipseIn: CGRect(x: x - r, y: peak - r, width: r * 2, height: r * 2)),
                with: .color(.white.opacity(0.5 * (1 - t / 0.15)))
            )
        }
    }
}

#Preview {
    Fireworks()
        .background(Color(red: 0.03, green: 0.03, blue: 0.1))
        .frame(width: 320, height: 220)
}
