import SwiftUI

/// A flock of little arrows that swim together like birds or fish: each one
/// steers to keep its distance, match its neighbours' heading and stay with
/// the group (boids). Drag or hover and the flock chases the pointer.
///
/// ```swift
/// Flock(count: 60, color: .white)
///     .background(.indigo.gradient)
/// ```
public struct Flock: View {
    private let count: Int
    private let color: Color
    private let speed: Double

    @State private var model = FlockModel()
    @State private var target: CGPoint?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - count: Number of boids.
    ///   - color: Colour of the boids.
    ///   - speed: Cruising speed, in points per second.
    public init(count: Int = 50, color: Color = .white, speed: Double = 90) {
        self.count = max(1, count)
        self.color = color
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            Canvas { context, size in
                model.step(to: timeline.date, size: size, count: count, speed: speed, target: target, frozen: reduceMotion)
                for boid in model.boids {
                    let angle = atan2(boid.velocity.dy, boid.velocity.dx)
                    var arrow = Path()
                    arrow.move(to: CGPoint(x: 7, y: 0))
                    arrow.addLine(to: CGPoint(x: -5, y: 4))
                    arrow.addLine(to: CGPoint(x: -2.5, y: 0))
                    arrow.addLine(to: CGPoint(x: -5, y: -4))
                    arrow.closeSubpath()
                    let transform = CGAffineTransform(translationX: boid.position.x, y: boid.position.y).rotated(by: angle)
                    context.fill(arrow.applying(transform), with: .color(color))
                }
            }
        }
        .contentShape(Rectangle())
        .onContinuousHover { phase in
            if case let .active(location) = phase { target = location } else { target = nil }
        }
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { target = $0.location }
            .onEnded { _ in target = nil })
        .accessibilityHidden(true)
    }
}

/// The simulation. A class so the canvas can advance it every frame without
/// invalidating the view.
final class FlockModel {
    struct Boid {
        var position: CGPoint
        var velocity: CGVector
    }

    private(set) var boids: [Boid] = []
    private var last: Date?

    func step(to date: Date, size: CGSize, count: Int, speed: Double, target: CGPoint?, frozen: Bool) {
        if boids.count != count { seed(count: count, size: size, speed: speed) }
        let dt = min(1.0 / 20, last.map { date.timeIntervalSince($0) } ?? 0)
        last = date
        guard !frozen, dt > 0 else { return }

        let neighbourhood: CGFloat = 46, personalSpace: CGFloat = 16
        var next = boids
        for i in boids.indices {
            var separation = CGVector.zero, alignment = CGVector.zero, centre = CGVector.zero
            var neighbours: CGFloat = 0
            for j in boids.indices where j != i {
                let dx = boids[j].position.x - boids[i].position.x
                let dy = boids[j].position.y - boids[i].position.y
                let distance = hypot(dx, dy)
                guard distance < neighbourhood else { continue }
                neighbours += 1
                alignment.dx += boids[j].velocity.dx; alignment.dy += boids[j].velocity.dy
                centre.dx += dx; centre.dy += dy
                if distance < personalSpace, distance > 0.01 {
                    separation.dx -= dx / distance * (personalSpace - distance)
                    separation.dy -= dy / distance * (personalSpace - distance)
                }
            }
            var v = boids[i].velocity
            if neighbours > 0 {
                v.dx += (alignment.dx / neighbours - v.dx) * 0.05 + centre.dx / neighbours * 0.012 + separation.dx * 0.14
                v.dy += (alignment.dy / neighbours - v.dy) * 0.05 + centre.dy / neighbours * 0.012 + separation.dy * 0.14
            }
            let p = boids[i].position
            if let target {
                v.dx += (target.x - p.x) * 0.02
                v.dy += (target.y - p.y) * 0.02
            }
            // Turn back from the edges.
            let margin: CGFloat = 24, turn: CGFloat = 9
            if p.x < margin { v.dx += turn }
            if p.x > size.width - margin { v.dx -= turn }
            if p.y < margin { v.dy += turn }
            if p.y > size.height - margin { v.dy -= turn }
            // Hold the cruising speed (a little faster when chasing).
            let cruise = CGFloat(speed) * (target == nil ? 1 : 1.5)
            let length = max(0.01, hypot(v.dx, v.dy))
            let clamped = min(max(length, cruise * 0.6), cruise * 1.3)
            v = CGVector(dx: v.dx / length * clamped, dy: v.dy / length * clamped)
            next[i].velocity = v
            next[i].position = CGPoint(x: p.x + v.dx * dt, y: p.y + v.dy * dt)
        }
        boids = next
    }

    private func seed(count: Int, size: CGSize, speed: Double) {
        var generator = SystemRandomNumberGenerator()
        boids = (0..<count).map { _ in
            let angle = Double.random(in: 0..<(2 * .pi), using: &generator)
            return Boid(
                position: CGPoint(x: .random(in: 0...max(1, size.width), using: &generator), y: .random(in: 0...max(1, size.height), using: &generator)),
                velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
            )
        }
    }
}

#Preview {
    Flock()
        .frame(width: 340, height: 240)
        .background(Color.indigo.gradient)
}
