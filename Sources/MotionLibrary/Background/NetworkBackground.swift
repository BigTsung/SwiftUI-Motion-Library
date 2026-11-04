import SwiftUI

/// Drifting points that link up with thin lines whenever two come close, like
/// a constellation or a network map. Points near the pointer or finger are
/// pulled towards it, so the web gathers where you touch.
///
/// ```swift
/// NetworkBackground(color: .cyan)
///     .background(.black)
///     .ignoresSafeArea()
/// ```
public struct NetworkBackground: View {
    private let count: Int
    private let linkDistance: CGFloat
    private let color: Color
    private let interactive: Bool

    @State private var pointer: CGPoint?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - count: Number of points.
    ///   - linkDistance: Points closer than this are joined, in points.
    ///   - color: Colour of points and lines.
    ///   - interactive: Pull points towards the pointer or a drag.
    public init(count: Int = 46, linkDistance: CGFloat = 70, color: Color = .white, interactive: Bool = true) {
        self.count = max(2, count)
        self.linkDistance = linkDistance
        self.color = color
        self.interactive = interactive
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let points = (0..<count).map { position(of: $0, time: time, size: size) }
                for i in points.indices {
                    for j in (i + 1)..<points.count {
                        let distance = hypot(points[i].x - points[j].x, points[i].y - points[j].y)
                        guard distance < linkDistance else { continue }
                        var line = Path()
                        line.move(to: points[i])
                        line.addLine(to: points[j])
                        let strength = 1 - distance / linkDistance
                        context.stroke(line, with: .color(color.opacity(0.55 * strength)), lineWidth: 0.6 + strength * 0.6)
                    }
                }
                for point in points {
                    context.fill(Path(ellipseIn: CGRect(x: point.x - 1.8, y: point.y - 1.8, width: 3.6, height: 3.6)), with: .color(color.opacity(0.9)))
                }
            }
        }
        .contentShape(Rectangle())
        .onContinuousHover { phase in
            guard interactive else { return }
            if case let .active(location) = phase { pointer = location } else { pointer = nil }
        }
        .gesture(interactive ? DragGesture(minimumDistance: 0)
            .onChanged { pointer = $0.location }
            .onEnded { _ in pointer = nil } : nil)
        .accessibilityHidden(true)
    }

    private func position(of index: Int, time: Double, size: CGSize) -> CGPoint {
        let speed = 6 + Self.hash(index, 3) * 14 // points per second
        let heading = Self.hash(index, 4) * 2 * .pi
        let x = wrap(Self.hash(index, 1) * size.width + cos(heading) * speed * time, size.width)
        let y = wrap(Self.hash(index, 2) * size.height + sin(heading) * speed * time, size.height)
        var point = CGPoint(x: x, y: y)
        if let pointer {
            let dx = pointer.x - point.x, dy = pointer.y - point.y
            let distance = hypot(dx, dy)
            let reach: CGFloat = 110
            if distance < reach, distance > 0.1 {
                let pull = (1 - distance / reach) * 0.45
                point.x += dx * pull
                point.y += dy * pull
            }
        }
        return point
    }

    /// Wraps into -20…length+20, so points leave one edge and enter the other.
    private func wrap(_ value: Double, _ length: CGFloat) -> CGFloat {
        let span = Double(length) + 40
        let r = (value + 20).truncatingRemainder(dividingBy: span)
        return CGFloat((r < 0 ? r + span : r) - 20)
    }

    private static func hash(_ a: Int, _ b: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: a &* 73_856_093 ^ b &* 19_349_663 &+ 0x51ED)
        x = (x ^ (x >> 33)) &* 0xff51_afd7_ed55_8ccd
        x ^= x >> 33
        return Double(x % 10_000) / 10_000
    }
}

#Preview {
    NetworkBackground(color: .cyan)
        .frame(width: 340, height: 240)
        .background(Color(red: 0.03, green: 0.05, blue: 0.12))
}
