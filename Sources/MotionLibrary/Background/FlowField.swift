import SwiftUI

/// Generative art: short curves follow a slowly shifting vector field, like
/// wind or water, with dashes travelling along them to show the flow.
public struct FlowField: View {
    private let lines: Int
    private let colors: [Color]
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - lines: Number of curves.
    ///   - colors: Curves are tinted along this list, left to right.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    public init(lines: Int = 140, colors: [Color] = [.cyan, .blue, .purple, .pink], speed: Double = 1) {
        self.lines = max(1, lines)
        self.colors = colors.isEmpty ? [.primary] : colors
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 3 : timeline.date.timeIntervalSinceReferenceDate * speed
            Canvas { context, size in
                let scale = 220 / max(1, min(size.width, size.height))
                for index in 0..<lines {
                    var p = CGPoint(x: Self.hash(index, 1) * size.width, y: Self.hash(index, 2) * size.height)
                    var path = Path()
                    path.move(to: p)
                    for _ in 0..<22 {
                        let angle = Self.field(Double(p.x) * scale, Double(p.y) * scale, time * 0.25)
                        p.x += CGFloat(cos(angle)) * 3.2
                        p.y += CGFloat(sin(angle)) * 3.2
                        path.addLine(to: p)
                    }
                    let tint = colors[min(colors.count - 1, Int(Self.hash(index, 1) * Double(colors.count)))]
                    context.stroke(path, with: .color(tint.opacity(0.18)), lineWidth: 1)
                    // Travelling dashes show the direction of flow. The phase is
                    // wrapped to one dash period: Core Graphics walks the pattern
                    // up to the phase, so a raw clock value would hang it.
                    let phase = (time * 30 + Self.hash(index, 3) * 45).truncatingRemainder(dividingBy: 45)
                    context.stroke(path, with: .color(tint.opacity(0.85)), style: StrokeStyle(lineWidth: 1.4, lineCap: .round, dash: [5, 40], dashPhase: -CGFloat(phase)))
                }
            }
        }
        .accessibilityHidden(true)
    }

    /// Flow direction, in radians, at a point: layered sines that drift over time.
    static func field(_ x: Double, _ y: Double, _ t: Double) -> Double {
        let a = sin(x * 0.012 + t) * cos(y * 0.014 - t * 0.7)
        let b = sin((x + y) * 0.007 + t * 0.5)
        return (a + b) * .pi
    }

    static func hash(_ a: Int, _ b: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: a &* 2_246_822_519 &+ b &* 3_266_489_917)
        x = (x ^ (x >> 15)) &* 0x2c1b_3c6d
        x ^= x >> 12
        return Double(x % 10_000) / 10_000
    }
}

#Preview {
    FlowField()
        .frame(width: 320, height: 220)
        .background(Color(white: 0.06))
}
