import SwiftUI

/// The pointer or finger leaves a soft trail of ink, like smoke from a
/// sparkler: puffs swell, drift upwards and fade.
struct InkTrailModifier: ViewModifier {
    var color: Color
    var lifetime: Double
    var size: CGFloat

    struct Puff {
        var point: CGPoint
        var time: Date
        var seed: Double
    }

    @State private var puffs: [Puff] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                TimelineView(.animation(paused: reduceMotion || puffs.isEmpty)) { timeline in
                    Canvas { context, _ in
                        context.addFilter(.blur(radius: size * 0.35))
                        for puff in puffs {
                            let age = timeline.date.timeIntervalSince(puff.time) / lifetime
                            guard age >= 0, age < 1 else { continue }
                            let radius = size * (0.35 + age * 0.9)
                            // Drift up and sideways, a little differently per puff.
                            let x = puff.point.x + CGFloat(sin(puff.seed * 9 + age * 3) * 14 * age)
                            let y = puff.point.y - CGFloat(age * 34)
                            let opacity = (1 - age) * (1 - age) * 0.85
                            context.fill(Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)), with: .color(color.opacity(opacity)))
                        }
                    }
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .onContinuousHover { phase in
                if case let .active(location) = phase { add(location) }
            }
            .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { add($0.location) })
    }

    private func add(_ point: CGPoint) {
        guard !reduceMotion else { return }
        let now = Date()
        // Space puffs out so a slow drag doesn't stack hundreds in one spot.
        if let last = puffs.last, hypot(last.point.x - point.x, last.point.y - point.y) < size * 0.18, now.timeIntervalSince(last.time) < 0.05 { return }
        puffs.removeAll { now.timeIntervalSince($0.time) > lifetime }
        puffs.append(Puff(point: point, time: now, seed: Double.random(in: 0...1)))
    }
}

public extension View {
    /// Leaves a fading trail of ink or smoke wherever the pointer moves or a
    /// finger drags over the view.
    ///
    /// ```swift
    /// Color.black
    ///     .inkTrail(color: .purple)
    /// ```
    ///
    /// - Parameters:
    ///   - color: Colour of the ink.
    ///   - lifetime: Seconds before a puff fades away.
    ///   - size: Diameter of a fresh puff, in points.
    func inkTrail(color: Color = .purple, lifetime: Double = 1.2, size: CGFloat = 26) -> some View {
        modifier(InkTrailModifier(color: color, lifetime: lifetime, size: size))
    }
}

#Preview {
    Color(red: 0.06, green: 0.05, blue: 0.1)
        .frame(width: 340, height: 240)
        .inkTrail(color: .pink)
}
