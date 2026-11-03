import SwiftUI

/// A grid of dots that scatter away from your finger or pointer and ease
/// back when you let go. At rest a faint wave ripples through the dot sizes.
public struct InteractiveDotGrid: View {
    private let spacing: CGFloat
    private let color: Color
    private let highlight: Color
    private let radius: CGFloat

    @State private var pointer: CGPoint?
    @State private var model = DotGridModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - spacing: Distance between dots, in points.
    ///   - color: Dot colour at rest.
    ///   - highlight: Dot colour near the pointer.
    ///   - radius: How far the pointer's push reaches, in points.
    public init(spacing: CGFloat = 18, color: Color = .secondary.opacity(0.45), highlight: Color = .accentColor, radius: CGFloat = 70) {
        self.spacing = max(4, spacing)
        self.color = color
        self.highlight = highlight
        self.radius = radius
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let state = model.step(towards: pointer)
                let columns = Int(size.width / spacing) + 1
                let rows = Int(size.height / spacing) + 1
                let originX = (size.width - CGFloat(columns - 1) * spacing) / 2
                let originY = (size.height - CGFloat(rows - 1) * spacing) / 2
                for row in 0..<rows {
                    for column in 0..<columns {
                        var p = CGPoint(x: originX + CGFloat(column) * spacing, y: originY + CGFloat(row) * spacing)
                        var near: CGFloat = 0
                        if state.strength > 0.001 {
                            let dx = p.x - state.point.x, dy = p.y - state.point.y
                            let distance = max(0.001, hypot(dx, dy))
                            if distance < radius {
                                near = pow(1 - distance / radius, 2) * state.strength
                                let push = reduceMotion ? 0 : near * spacing * 1.6
                                p.x += dx / distance * push
                                p.y += dy / distance * push
                            }
                        }
                        let wave = reduceMotion ? 0 : 0.5 + 0.5 * sin(Double(column + row) * 0.45 - time * 2)
                        let r = 1.2 + 0.5 * CGFloat(wave) + 2 * near
                        let shading: GraphicsContext.Shading = near > 0.15 ? .color(highlight.opacity(0.4 + 0.6 * Double(near))) : .color(color)
                        context.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)), with: shading)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { pointer = $0.location }
                .onEnded { _ in pointer = nil }
        )
        .onContinuousHover { phase in
            switch phase {
            case .active(let location): pointer = location
            case .ended: pointer = nil
            }
        }
        .accessibilityHidden(true)
    }
}

/// Smooths the pointer and the push strength from frame to frame, so dots
/// glide out and back instead of snapping. Not observed: it's only read and
/// written while drawing.
final class DotGridModel {
    private var point: CGPoint = .zero
    private var strength: CGFloat = 0
    private var last = Date()

    func step(towards target: CGPoint?) -> (point: CGPoint, strength: CGFloat) {
        let now = Date()
        let dt = min(0.05, now.timeIntervalSince(last))
        last = now
        let k = CGFloat(1 - exp(-dt * 14))
        if let target {
            if strength < 0.01 { point = target }
            point.x += (target.x - point.x) * k
            point.y += (target.y - point.y) * k
            strength += (1 - strength) * k
        } else {
            strength += (0 - strength) * CGFloat(1 - exp(-dt * 6))
        }
        return (point, strength)
    }
}

#Preview {
    InteractiveDotGrid()
        .frame(width: 300, height: 220)
}
