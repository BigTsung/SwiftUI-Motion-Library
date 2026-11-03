import SwiftUI

/// A removal transition that breaks the view into triangular shards that fly
/// outward, spin, fall and fade, like breaking glass. On insertion the view
/// simply scales up from 90 % and fades in.
public struct ShatterTransition: Transition {
    public var columns: Int
    public var rows: Int
    public var distance: CGFloat

    /// - Parameters:
    ///   - columns: Grid columns; each cell becomes two shards.
    ///   - rows: Grid rows.
    ///   - distance: How far shards fly, in points.
    public init(columns: Int = 4, rows: Int = 3, distance: CGFloat = 110) {
        self.columns = max(1, columns)
        self.rows = max(1, rows)
        self.distance = distance
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        ShatterBody(content: content, phase: phase, columns: columns, rows: rows, distance: distance)
    }
}

private struct ShatterBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase
    let columns: Int
    let rows: Int
    let distance: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        content
            .modifier(ShatterEffect(
                progress: phase == .didDisappear ? 1 : 0,
                columns: columns,
                rows: rows,
                // Reduce Motion: shards fade in place.
                distance: reduceMotion ? 0 : distance,
                spin: reduceMotion ? 0 : 220
            ))
            .scaleEffect(phase == .willAppear ? 0.9 : 1)
            .opacity(phase == .willAppear ? 0 : 1)
    }
}

/// Draws the plain view at rest and the shards only while breaking, so an
/// intact view isn't rendered once per shard.
struct ShatterEffect: ViewModifier, Animatable {
    var progress: Double
    var columns: Int
    var rows: Int
    var distance: CGFloat
    var spin: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        if progress <= 0.001 {
            content
        } else {
            let shards = ShatterGrid.shards(columns: columns, rows: rows)
            let p = CGFloat(progress)
            ZStack {
                ForEach(shards.indices, id: \.self) { index in
                    let centre = shards[index].centroid
                    let dx = centre.x - 0.5, dy = centre.y - 0.5
                    let length = max(0.05, hypot(dx, dy))
                    let random = ShatterGrid.random(index)
                    content
                        .mask(ShardShape(points: shards[index].points))
                        .rotationEffect(.degrees((random - 0.5) * spin * progress), anchor: UnitPoint(x: centre.x, y: centre.y))
                        // Out along the crack direction, then falling (gravity grows with p²).
                        .offset(
                            x: dx / length * distance * (0.6 + random * 0.6) * p,
                            y: dy / length * distance * 0.6 * p + distance * 0.9 * p * p
                        )
                        .opacity(1 - progress * progress)
                }
            }
            .allowsHitTesting(false)
        }
    }
}

/// A triangle in unit coordinates (0…1 across the view).
struct Shard {
    var points: [CGPoint]
    var centroid: CGPoint {
        CGPoint(x: points.map(\.x).reduce(0, +) / 3, y: points.map(\.y).reduce(0, +) / 3)
    }
}

enum ShatterGrid {
    /// Splits a jittered grid into triangles, two per cell.
    static func shards(columns: Int, rows: Int) -> [Shard] {
        func point(_ c: Int, _ r: Int) -> CGPoint {
            var x = CGFloat(c) / CGFloat(columns), y = CGFloat(r) / CGFloat(rows)
            // Jitter interior points so the cracks look natural.
            if c > 0 && c < columns { x += (random(c * 31 + r * 7) - 0.5) * 0.6 / CGFloat(columns) }
            if r > 0 && r < rows { y += (random(c * 13 + r * 29 + 5) - 0.5) * 0.6 / CGFloat(rows) }
            return CGPoint(x: x, y: y)
        }
        var shards: [Shard] = []
        for r in 0..<rows {
            for c in 0..<columns {
                let a = point(c, r), b = point(c + 1, r), d = point(c, r + 1), e = point(c + 1, r + 1)
                if (c + r).isMultiple(of: 2) {
                    shards.append(Shard(points: [a, b, e]))
                    shards.append(Shard(points: [a, e, d]))
                } else {
                    shards.append(Shard(points: [a, b, d]))
                    shards.append(Shard(points: [b, e, d]))
                }
            }
        }
        return shards
    }

    static func random(_ n: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: n &* 2_654_435_761 &+ 12_345)
        x = (x ^ (x >> 31)) &* 0x9E37_79B9_7F4A_7C15
        x ^= x >> 29
        return Double(x % 10_000) / 10_000
    }
}

struct ShardShape: Shape {
    var points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let mapped = points.map { CGPoint(x: rect.minX + $0.x * rect.width, y: rect.minY + $0.y * rect.height) }
        path.addLines(mapped)
        path.closeSubpath()
        // Bleed a hair so shards don't show seams before they separate.
        return path.strokedPath(StrokeStyle(lineWidth: 0.8, lineJoin: .round)).union(path)
    }
}

public extension Transition where Self == ShatterTransition {
    /// Breaks the view into flying shards when it's removed.
    ///
    /// ```swift
    /// if !isBroken {
    ///     GlassPane().transition(.shatter)
    /// }
    /// ```
    static var shatter: ShatterTransition { ShatterTransition() }

    /// Breaks the view into `columns` × `rows` × 2 shards.
    static func shatter(columns: Int, rows: Int, distance: CGFloat = 110) -> ShatterTransition {
        ShatterTransition(columns: columns, rows: rows, distance: distance)
    }
}

#Preview {
    struct Demo: View {
        @State private var shown = true
        var body: some View {
            ZStack {
                if shown {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cyan.gradient)
                        .frame(width: 180, height: 130)
                        .transition(.shatter)
                }
            }
            .frame(width: 300, height: 300)
            .onTapGesture { withAnimation(.easeOut(duration: 0.8)) { shown.toggle() } }
        }
    }
    return Demo()
}
