import SwiftUI

/// Emoji that fall in with gravity, bounce off the floor, walls and each
/// other, roll a little, and pile up. Each change of `trigger` drops a
/// new handful; the oldest are removed once there are too many.
public struct PhysicsEmoji<Trigger: Equatable>: View {
    private let trigger: Trigger
    private let emojis: [String]
    private let batch: Int
    private let size: CGFloat

    @State private var world = EmojiWorld()
    /// The clock only runs while something is moving; once the pile has
    /// settled the view stops redrawing until the next drop.
    @State private var isAwake = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - trigger: Drops a batch whenever it changes.
    ///   - emojis: Picked at random for each body.
    ///   - batch: How many drop per trigger.
    ///   - size: Emoji size in points (also the collision diameter).
    public init(trigger: Trigger, emojis: [String] = ["🎉", "⭐️", "❤️", "🍀", "🔥", "😍"], batch: Int = 6, size: CGFloat = 30) {
        self.trigger = trigger
        self.emojis = emojis.isEmpty ? ["⭐️"] : emojis
        self.batch = max(1, batch)
        self.size = size
    }

    public var body: some View {
        TimelineView(.animation(paused: !isAwake)) { timeline in
            Canvas { context, canvasSize in
                world.step(to: timeline.date, size: canvasSize)
                var resolved: [String: GraphicsContext.ResolvedText] = [:]
                for body in world.bodies {
                    let text = resolved[body.emoji] ?? context.resolve(Text(body.emoji).font(.system(size: size * 0.86)))
                    resolved[body.emoji] = text
                    var copy = context
                    copy.opacity = body.opacity
                    copy.translateBy(x: body.position.x, y: body.position.y)
                    copy.rotate(by: .radians(body.angle))
                    copy.draw(text, at: .zero)
                }
            }
            .onChange(of: timeline.date) {
                if world.isAtRest { isAwake = false }
            }
        }
        .background {
            // A new size moves the walls and floor, so let the pile resettle.
            GeometryReader { proxy in
                Color.clear.onChange(of: proxy.size) { isAwake = true }
            }
        }
        .onChange(of: trigger) {
            world.drop(count: batch, emojis: emojis, radius: size / 2, settled: reduceMotion)
            isAwake = true
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// A tiny physics world, stepped once per frame. Not observed: the
/// `TimelineView` redraws every frame anyway.
final class EmojiWorld {
    struct Body {
        var emoji: String
        var position: CGPoint
        var velocity: CGVector
        var angle: Double
        var spin: Double
        var radius: CGFloat
        var opacity: Double = 1
    }

    private(set) var bodies: [Body] = []
    private var size: CGSize = .zero
    private var last: Date?
    private let maximum = 36
    /// Where every body was when the pile last moved, and how long ago.
    /// Stacked bodies jitter by a fraction of a point each frame, so rest is
    /// judged by how far they get, not by their speed.
    private var anchor: [Body] = []
    private var stillFor: Double = 0

    /// True once no emoji has moved or turned more than a point in half a
    /// second.
    var isAtRest: Bool { bodies.isEmpty || stillFor >= 0.5 }

    func drop(count: Int, emojis: [String], radius: CGFloat, settled: Bool) {
        let width = max(size.width, radius * 4)
        for index in 0..<count {
            let x = CGFloat.random(in: radius...(width - radius))
            // Reduce Motion: they appear already resting on the floor.
            let y = settled ? size.height - radius - CGFloat(index / 6) * radius * 2 : -radius * CGFloat(2 + index * 2)
            bodies.append(Body(
                emoji: emojis.randomElement()!,
                position: CGPoint(x: x, y: y),
                velocity: settled ? .zero : CGVector(dx: .random(in: -60...60), dy: .random(in: 0...120)),
                angle: .random(in: -0.5...0.5),
                spin: settled ? 0 : .random(in: -4...4),
                radius: radius
            ))
        }
        if bodies.count > maximum { bodies.removeFirst(bodies.count - maximum) }
        anchor = []
        stillFor = 0
    }

    func step(to date: Date, size: CGSize) {
        self.size = size
        let dt = min(1.0 / 30, date.timeIntervalSince(last ?? date))
        last = date
        guard dt > 0, !bodies.isEmpty else { return }
        let before = bodies
        let gravity: CGFloat = 1400
        let restitution: CGFloat = 0.45
        // Two substeps keep stacks stable.
        for _ in 0..<2 {
            let h = CGFloat(dt / 2)
            for i in bodies.indices {
                bodies[i].velocity.dy += gravity * h
                bodies[i].position.x += bodies[i].velocity.dx * h
                bodies[i].position.y += bodies[i].velocity.dy * h
                bodies[i].angle += bodies[i].spin * Double(h)
                let r = bodies[i].radius
                if bodies[i].position.y > size.height - r {
                    bodies[i].position.y = size.height - r
                    bodies[i].velocity.dy = -abs(bodies[i].velocity.dy) * restitution
                    bodies[i].velocity.dx *= 0.9
                    if abs(bodies[i].velocity.dy) < 30 { bodies[i].velocity.dy = 0 }
                }
                if bodies[i].position.x < r {
                    bodies[i].position.x = r
                    bodies[i].velocity.dx = abs(bodies[i].velocity.dx) * restitution
                } else if bodies[i].position.x > size.width - r {
                    bodies[i].position.x = size.width - r
                    bodies[i].velocity.dx = -abs(bodies[i].velocity.dx) * restitution
                }
            }
            // Circle-circle collisions: separate, then bounce along the normal.
            for i in bodies.indices {
                for j in (i + 1)..<bodies.count {
                    let dx = bodies[j].position.x - bodies[i].position.x
                    let dy = bodies[j].position.y - bodies[i].position.y
                    let minDistance = bodies[i].radius + bodies[j].radius
                    let distanceSquared = dx * dx + dy * dy
                    guard distanceSquared < minDistance * minDistance, distanceSquared > 0.0001 else { continue }
                    let distance = sqrt(distanceSquared)
                    let nx = dx / distance, ny = dy / distance
                    let overlap = (minDistance - distance) / 2
                    bodies[i].position.x -= nx * overlap
                    bodies[i].position.y -= ny * overlap
                    bodies[j].position.x += nx * overlap
                    bodies[j].position.y += ny * overlap
                    let relative = (bodies[j].velocity.dx - bodies[i].velocity.dx) * nx + (bodies[j].velocity.dy - bodies[i].velocity.dy) * ny
                    guard relative < 0 else { continue }
                    let impulse = -(1 + restitution) * relative / 2
                    bodies[i].velocity.dx -= impulse * nx
                    bodies[i].velocity.dy -= impulse * ny
                    bodies[j].velocity.dx += impulse * nx
                    bodies[j].velocity.dy += impulse * ny
                }
            }
        }
        // Spin decays so resting emoji stop turning.
        for i in bodies.indices { bodies[i].spin *= 0.97 }
        // Rolling: on the floor, turn by the distance actually rolled. An
        // emoji wedged against a wall or a neighbour keeps some sideways
        // velocity but can't move, and shouldn't spin in place.
        for i in bodies.indices where bodies[i].position.y >= size.height - bodies[i].radius - 0.5 {
            bodies[i].spin = Double((bodies[i].position.x - before[i].position.x) / bodies[i].radius) / dt
        }
        let drift = anchor.count == bodies.count ? zip(anchor, bodies).reduce(0.0) { drift, pair in
            let moved = hypot(pair.1.position.x - pair.0.position.x, pair.1.position.y - pair.0.position.y)
            return max(drift, Double(moved), abs(pair.1.angle - pair.0.angle) * Double(pair.1.radius))
        } : .infinity
        if drift > 1 {
            anchor = bodies
            stillFor = 0
        } else {
            stillFor += dt
        }
    }
}

#Preview {
    struct Demo: View {
        @State private var drops = 0
        var body: some View {
            PhysicsEmoji(trigger: drops)
                .frame(width: 300, height: 260)
                .background(Color.secondary.opacity(0.08))
                .onTapGesture { drops += 1 }
        }
    }
    return Demo()
}
