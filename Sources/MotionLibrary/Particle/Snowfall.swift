import SwiftUI

/// Falling weather: snowflakes that drift and sway, or slanted streaks of rain.
public struct Snowfall: View {
    /// What falls.
    public enum Style: Sendable {
        /// Soft round flakes that sway side to side.
        case snow
        /// Fast, thin, slanted streaks.
        case rain
    }

    private let style: Style
    private let color: Color
    private let speed: Double
    private let seeds: [FallSeed]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - style: `.snow` or `.rain`.
    ///   - count: Number of flakes or drops.
    ///   - color: Flake or drop colour.
    ///   - speed: 1 = default pace.
    public init(_ style: Style = .snow, count: Int = 80, color: Color = .white, speed: Double = 1) {
        self.style = style
        self.color = color
        self.speed = speed
        var generator = SplitMix64(seed: style == .snow ? 11 : 23)
        seeds = (0..<max(0, count)).map { _ in FallSeed(using: &generator) }
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate * speed
            Canvas { context, size in
                for seed in seeds {
                    switch style {
                    case .snow: drawFlake(seed, time: time, in: &context, size: size)
                    case .rain: drawDrop(seed, time: time, in: &context, size: size)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func drawFlake(_ seed: FallSeed, time: Double, in context: inout GraphicsContext, size: CGSize) {
        // Small flakes are "far away": slower and fainter, for depth.
        let fallSpeed = 18 + 30 * seed.depth
        let travel = size.height + 20
        let y = (seed.start.y * travel + CGFloat(time * fallSpeed)).wrapped(to: travel) - 10
        let sway = CGFloat(sin(time * (0.8 + seed.depth) + seed.phase)) * (6 + 10 * seed.depth)
        let x = (seed.start.x * size.width + sway + CGFloat(time * 4)).wrapped(to: size.width)
        let r = 1 + 2.4 * seed.depth
        context.fill(
            Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
            with: .color(color.opacity(0.35 + 0.6 * seed.depth))
        )
    }

    private func drawDrop(_ seed: FallSeed, time: Double, in context: inout GraphicsContext, size: CGSize) {
        let fallSpeed = 380 + 320 * seed.depth
        let length = 8 + 14 * seed.depth
        let slant: CGFloat = 0.25
        let travel = size.height + length + 20
        let y = (seed.start.y * travel + CGFloat(time * fallSpeed)).wrapped(to: travel) - length
        let x = (seed.start.x * (size.width + 40) + y * slant).wrapped(to: size.width + 40) - 20
        var path = Path()
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: x + length * slant, y: y + length))
        context.stroke(path, with: .color(color.opacity(0.25 + 0.5 * seed.depth)), style: StrokeStyle(lineWidth: 0.8 + 0.8 * seed.depth, lineCap: .round))
    }
}

/// Fixed random traits of one flake or drop.
private struct FallSeed {
    var start: CGPoint
    var depth: CGFloat
    var phase: Double

    init(using generator: inout SplitMix64) {
        start = CGPoint(x: generator.unit(), y: generator.unit())
        depth = CGFloat(generator.unit())
        phase = generator.unit() * 2 * .pi
    }
}

#Preview {
    HStack(spacing: 0) {
        Snowfall().background(Color(red: 0.1, green: 0.15, blue: 0.3))
        Snowfall(.rain, count: 120).background(Color(white: 0.15))
    }
    .frame(width: 320, height: 200)
}
