import SwiftUI

/// Particles drifting slowly through the view, joined by faint lines when they
/// come close, like a constellation. A calm, techy background.
public struct ParticleField: View {
    private let count: Int
    private let color: Color
    private let speed: Double
    private let linkDistance: CGFloat
    private let seeds: [ParticleSeed]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - count: Number of particles.
    ///   - color: Particle and line colour.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    ///   - linkDistance: Particles closer than this are joined by a line (0 turns lines off).
    public init(count: Int = 50, color: Color = .white, speed: Double = 1, linkDistance: CGFloat = 70) {
        self.count = count
        self.color = color
        self.speed = speed * 14
        self.linkDistance = linkDistance
        var generator = SplitMix64(seed: 42)
        seeds = (0..<max(0, count)).map { _ in ParticleSeed(using: &generator) }
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let positions = seeds.map { $0.position(at: time, speed: speed, in: size) }
                if linkDistance > 0 {
                    for i in positions.indices {
                        for j in positions.indices where j > i {
                            let distance = hypot(positions[i].x - positions[j].x, positions[i].y - positions[j].y)
                            guard distance < linkDistance else { continue }
                            var line = Path()
                            line.move(to: positions[i])
                            line.addLine(to: positions[j])
                            context.stroke(line, with: .color(color.opacity(0.35 * (1 - distance / linkDistance))), lineWidth: 0.8)
                        }
                    }
                }
                for (seed, point) in zip(seeds, positions) {
                    let r = seed.radius
                    context.fill(
                        Path(ellipseIn: CGRect(x: point.x - r, y: point.y - r, width: r * 2, height: r * 2)),
                        with: .color(color.opacity(seed.opacity))
                    )
                }
            }
        }
        .accessibilityHidden(true)
    }
}

/// Fixed random traits of one particle. Its position is a pure function of
/// time, so the field needs no state and never drifts out of the view.
struct ParticleSeed {
    var start: CGPoint      // 0…1 in both axes
    var direction: Double   // radians
    var speedFactor: Double
    var radius: CGFloat
    var opacity: Double

    init(using generator: inout SplitMix64) {
        start = CGPoint(x: generator.unit(), y: generator.unit())
        direction = generator.unit() * 2 * .pi
        speedFactor = 0.4 + generator.unit() * 0.8
        radius = 1 + generator.unit() * 1.8
        opacity = 0.4 + generator.unit() * 0.6
    }

    func position(at time: Double, speed: Double, in size: CGSize) -> CGPoint {
        guard size.width > 0, size.height > 0 else { return .zero }
        let travel = time * speed * speedFactor
        let x = (start.x * size.width + CGFloat(cos(direction) * travel)).wrapped(to: size.width)
        let y = (start.y * size.height + CGFloat(sin(direction) * travel)).wrapped(to: size.height)
        return CGPoint(x: x, y: y)
    }
}

#Preview {
    ParticleField()
        .background(Color(red: 0.05, green: 0.07, blue: 0.15))
        .frame(width: 320, height: 220)
}
