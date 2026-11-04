import SwiftUI

/// A sky that runs through a whole day: deep night with stars, a pink and
/// orange dawn, blue noon, a burning sunset, and back, with the sun and moon
/// arcing across. Loops on its own, or follows a time of day you set.
///
/// ```swift
/// DayNightSky()                 // loops a day every 16 s
/// DayNightSky(time: 0.75)       // fixed at sunset
/// ```
public struct DayNightSky: View {
    private let time: Double?
    private let cycle: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - time: Time of day, 0…1 (0 midnight, 0.25 sunrise, 0.5 noon,
    ///     0.75 sunset). Changes animate. Leave nil to loop.
    ///   - cycle: Seconds per day when looping.
    public init(time: Double? = nil, cycle: Double = 16) {
        self.time = time
        self.cycle = max(1, cycle)
    }

    public var body: some View {
        if let time {
            SkyScene(time: time)
                .animation(.easeInOut(duration: 1.2), value: time)
                .accessibilityHidden(true)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { timeline in
                // Reduce Motion: hold at a calm early evening.
                let t = reduceMotion ? 0.7 : (timeline.date.timeIntervalSinceReferenceDate / cycle).truncatingRemainder(dividingBy: 1)
                SkyScene(time: t)
            }
            .accessibilityHidden(true)
        }
    }
}

/// The sky at one time of day. Animatable, so a fixed `time` animates
/// through the colours in between.
struct SkyScene: View, Animatable {
    var time: Double

    nonisolated var animatableData: Double {
        get { time }
        set { time = newValue }
    }

    private typealias RGB = (Double, Double, Double)

    /// Sky colours (top, horizon) at times of day.
    private static let stops: [(time: Double, top: RGB, horizon: RGB)] = [
        (0.00, (0.02, 0.03, 0.10), (0.06, 0.08, 0.20)),
        (0.20, (0.05, 0.06, 0.20), (0.25, 0.15, 0.35)),
        (0.27, (0.30, 0.35, 0.65), (0.98, 0.60, 0.45)),
        (0.35, (0.30, 0.60, 0.95), (0.70, 0.85, 1.00)),
        (0.50, (0.20, 0.50, 0.95), (0.65, 0.85, 1.00)),
        (0.68, (0.30, 0.50, 0.90), (0.95, 0.80, 0.60)),
        (0.75, (0.35, 0.25, 0.55), (1.00, 0.45, 0.20)),
        (0.82, (0.08, 0.08, 0.25), (0.40, 0.20, 0.35)),
        (1.00, (0.02, 0.03, 0.10), (0.06, 0.08, 0.20)),
    ]

    var body: some View {
        let t = time - floor(time)
        let (top, horizon) = Self.colours(at: t)
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(rect), with: .linearGradient(
                Gradient(colors: [Self.color(top), Self.color(horizon)]),
                startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
            // Stars fade in at night and twinkle with the time.
            let night = max(0, 1 - min(abs(t - 0) , abs(t - 1)) / 0.22) // near midnight
            let starOpacity = max(night, max(0, 1 - abs(t - 0.1) / 0.15), max(0, 1 - abs(t - 0.9) / 0.15))
            if starOpacity > 0.01 {
                for index in 0..<50 {
                    let x = Self.hash(index, 1) * size.width, y = Self.hash(index, 2) * size.height * 0.75
                    let r = 0.5 + Self.hash(index, 3) * 1
                    let twinkle = 0.6 + 0.4 * sin(t * 300 + Double(index))
                    context.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(.white.opacity(starOpacity * twinkle * 0.9)))
                }
            }
            // Sun and moon on opposite sides of a wide arc.
            let horizonY = size.height * 0.92
            func orb(at angle: Double, radius: Double, color: Color, glow: Double) {
                let p = CGPoint(x: size.width / 2 - cos(angle) * size.width * 0.45, y: horizonY - sin(angle) * size.height * 0.75)
                guard p.y < horizonY + radius else { return }
                var halo = context
                halo.addFilter(.blur(radius: radius * 0.9))
                halo.fill(Path(ellipseIn: CGRect(x: p.x - radius * 1.6, y: p.y - radius * 1.6, width: radius * 3.2, height: radius * 3.2)), with: .color(color.opacity(glow)))
                context.fill(Path(ellipseIn: CGRect(x: p.x - radius, y: p.y - radius, width: radius * 2, height: radius * 2)), with: .color(color))
            }
            let sunAngle = (t - 0.25) * 2 * .pi
            orb(at: sunAngle, radius: 14, color: Color(red: 1, green: 0.85 - 0.3 * max(0, 1 - sin(sunAngle) * 3), blue: 0.4), glow: 0.6)
            orb(at: sunAngle + .pi, radius: 10, color: Color(red: 0.95, green: 0.95, blue: 0.85), glow: 0.3)
            // A dark band of hills in front.
            var hills = Path()
            hills.move(to: CGPoint(x: 0, y: size.height))
            for step in 0...40 {
                let x = size.width * Double(step) / 40
                hills.addLine(to: CGPoint(x: x, y: horizonY - 6 - 8 * sin(Double(step) * 0.45) - 5 * sin(Double(step) * 1.3)))
            }
            hills.addLine(to: CGPoint(x: size.width, y: size.height))
            hills.closeSubpath()
            context.fill(hills, with: .color(Self.color((top.0 * 0.35, top.1 * 0.35, top.2 * 0.4))))
        }
    }

    private static func colours(at t: Double) -> (RGB, RGB) {
        let upper = stops.firstIndex { $0.time >= t } ?? stops.count - 1
        let lower = max(0, upper - 1)
        let a = stops[lower], b = stops[upper]
        let span = b.time - a.time
        let f = span > 0 ? (t - a.time) / span : 0
        func mix(_ x: RGB, _ y: RGB) -> RGB { (x.0 + (y.0 - x.0) * f, x.1 + (y.1 - x.1) * f, x.2 + (y.2 - x.2) * f) }
        return (mix(a.top, b.top), mix(a.horizon, b.horizon))
    }

    private static func color(_ rgb: RGB) -> Color { Color(red: rgb.0, green: rgb.1, blue: rgb.2) }

    private static func hash(_ a: Int, _ b: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: a &* 73_856_093 ^ b &* 19_349_663 &+ 0x5C1E)
        x = (x ^ (x >> 33)) &* 0xff51_afd7_ed55_8ccd
        x ^= x >> 33
        return Double(x % 10_000) / 10_000
    }
}

#Preview {
    DayNightSky(cycle: 10)
        .frame(width: 340, height: 220)
}
