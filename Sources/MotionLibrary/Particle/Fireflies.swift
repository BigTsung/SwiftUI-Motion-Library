import SwiftUI

/// Fireflies drift lazily on looping paths, each glowing and dimming on its
/// own rhythm. Lovely over dark, quiet backgrounds.
public struct Fireflies: View {
    private let count: Int
    private let color: Color
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - count: Number of fireflies.
    ///   - color: Glow colour.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    public init(count: Int = 24, color: Color = Color(red: 1, green: 0.9, blue: 0.45), speed: Double = 1) {
        self.count = max(1, count)
        self.color = color
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            let real = timeline.date.timeIntervalSinceReferenceDate
            // Reduce Motion: they stay put but keep glowing softly.
            let time = reduceMotion ? 0 : real * speed
            Canvas { context, size in
                var glow = context
                glow.addFilter(.blur(radius: 6))
                for index in 0..<count {
                    let a = Self.hash(index, 1), b = Self.hash(index, 2), c = Self.hash(index, 3)
                    // Two layered sines per axis give slow, wandering loops.
                    let x = size.width * (0.5 + 0.38 * sin(time * (0.13 + a * 0.12) + a * 20) + 0.1 * sin(time * (0.5 + b * 0.3) + b * 9))
                    let y = size.height * (0.5 + 0.36 * sin(time * (0.11 + b * 0.1) + b * 17) + 0.1 * cos(time * (0.45 + c * 0.3) + c * 5))
                    let blink = pow(0.5 + 0.5 * sin(real * (0.8 + c * 1.6) + a * 30), 3)
                    let r = 1.6 + 1.2 * c
                    glow.opacity = 0.25 + 0.75 * blink
                    glow.fill(Path(ellipseIn: CGRect(x: x - r * 4, y: y - r * 4, width: r * 8, height: r * 8)), with: .color(color.opacity(0.7)))
                    var core = context
                    core.opacity = 0.35 + 0.65 * blink
                    core.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(.white))
                }
            }
        }
        .accessibilityHidden(true)
    }

    static func hash(_ a: Int, _ b: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: a &* 9_301 &+ b &* 49_297 &+ 233_280)
        x = (x ^ (x >> 15)) &* 0x2c1b_3c6d
        x ^= x >> 12
        return Double(x % 10_000) / 10_000
    }
}

#Preview {
    Fireflies()
        .frame(width: 320, height: 220)
        .background(Color(red: 0.02, green: 0.06, blue: 0.05))
}
