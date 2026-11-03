import SwiftUI

/// Meteors streak diagonally across a starry sky, each with a glowing head
/// and a fading tail, at random intervals.
public struct Meteors: View {
    private let count: Int
    private let angle: Angle
    private let color: Color
    private let showsStars: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - count: Number of meteors in flight over a cycle.
    ///   - angle: Direction of travel (0° = right, 90° = down).
    ///   - color: Colour of heads and tails.
    ///   - showsStars: Scatter faint static stars behind the meteors.
    public init(count: Int = 10, angle: Angle = .degrees(135), color: Color = .white, showsStars: Bool = true) {
        self.count = max(1, count)
        self.angle = angle
        self.color = color
        self.showsStars = showsStars
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                if showsStars {
                    for index in 0..<60 {
                        let x = Self.hash(index, 1) * size.width, y = Self.hash(index, 2) * size.height
                        let r = 0.4 + Self.hash(index, 3) * 0.8
                        context.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(color.opacity(0.25 + 0.4 * Self.hash(index, 4))))
                    }
                }
                // Reduce Motion: stars only.
                guard !reduceMotion else { return }
                let direction = CGPoint(x: cos(angle.radians), y: sin(angle.radians))
                let travel = (size.width + size.height) * 1.2
                for index in 0..<count {
                    let duration = 1.6 + Self.hash(index, 5) * 2.2
                    let cycle = duration + 0.5 + Self.hash(index, 6) * 2.5 // flight + pause
                    let local = (time + Self.hash(index, 7) * 10).truncatingRemainder(dividingBy: cycle)
                    guard local < duration else { continue }
                    let progress = local / duration
                    // Start points spread along the top and the side the meteors come from.
                    let spread = Self.hash(index, 8) * (size.width + size.height)
                    let start = direction.x >= 0
                        ? (spread < size.width ? CGPoint(x: spread - size.width * 0.3, y: -20) : CGPoint(x: -20, y: spread - size.width))
                        : (spread < size.width ? CGPoint(x: spread + size.width * 0.3, y: -20) : CGPoint(x: size.width + 20, y: spread - size.width))
                    let head = CGPoint(x: start.x + direction.x * travel * progress, y: start.y + direction.y * travel * progress)
                    let tailLength = 50 + Self.hash(index, 9) * 60
                    let tail = CGPoint(x: head.x - direction.x * tailLength, y: head.y - direction.y * tailLength)
                    var line = Path()
                    line.move(to: tail)
                    line.addLine(to: head)
                    context.stroke(line, with: .linearGradient(Gradient(colors: [color.opacity(0), color.opacity(0.9)]), startPoint: tail, endPoint: head), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    var glow = context
                    glow.addFilter(.blur(radius: 2))
                    glow.fill(Path(ellipseIn: CGRect(x: head.x - 2.5, y: head.y - 2.5, width: 5, height: 5)), with: .color(color))
                }
            }
        }
        .accessibilityHidden(true)
    }

    static func hash(_ a: Int, _ b: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: a &* 73_856_093 ^ b &* 19_349_663 &+ 0x9E37)
        x = (x ^ (x >> 33)) &* 0xff51_afd7_ed55_8ccd
        x ^= x >> 33
        return Double(x % 10_000) / 10_000
    }
}

#Preview {
    Meteors()
        .frame(width: 320, height: 220)
        .background(Color(red: 0.03, green: 0.04, blue: 0.12))
}
