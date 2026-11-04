import SwiftUI

// Transitions that reveal or hide a view through an animated mask. Masks
// don't move the content, so they need no Reduce Motion fallback.

// MARK: - Iris

/// A circle that opens from a point to reveal the view, and closes back to
/// it on removal, like a camera iris.
public struct IrisTransition: Transition {
    public var origin: UnitPoint

    public init(origin: UnitPoint = .center) {
        self.origin = origin
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.mask {
            GeometryReader { geometry in
                let size = geometry.size
                let o = CGPoint(x: size.width * origin.x, y: size.height * origin.y)
                // Far enough to cover the corner furthest from the origin.
                let radius = [CGPoint.zero, CGPoint(x: size.width, y: 0), CGPoint(x: 0, y: size.height), CGPoint(x: size.width, y: size.height)]
                    .map { hypot($0.x - o.x, $0.y - o.y) }
                    .max() ?? 0
                Circle()
                    .frame(width: radius * 2, height: radius * 2)
                    .position(o)
                    .scaleEffect(phase.isIdentity ? 1 : 0.001, anchor: origin)
            }
        }
    }
}

public extension Transition where Self == IrisTransition {
    /// Opens the view in a growing circle from its centre.
    ///
    /// ```swift
    /// if showPhoto {
    ///     PhotoView().transition(.iris)
    /// }
    /// ```
    static var iris: IrisTransition { IrisTransition() }

    /// Opens the view in a growing circle from `origin`.
    static func iris(origin: UnitPoint) -> IrisTransition { IrisTransition(origin: origin) }
}

// MARK: - Blinds

/// Horizontal slats that open together, like Venetian blinds.
public struct BlindsTransition: Transition {
    public var slats: Int

    public init(slats: Int = 8) {
        self.slats = max(1, slats)
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.mask {
            VStack(spacing: 0) {
                ForEach(0..<slats, id: \.self) { _ in
                    Rectangle()
                        .scaleEffect(y: phase.isIdentity ? 1 : 0.001, anchor: .top)
                }
            }
        }
    }
}

public extension Transition where Self == BlindsTransition {
    /// Reveals the view through opening blinds.
    ///
    /// ```swift
    /// Banner().transition(.blinds)
    /// ```
    static var blinds: BlindsTransition { BlindsTransition() }

    /// Reveals the view through `slats` opening blinds.
    static func blinds(slats: Int) -> BlindsTransition { BlindsTransition(slats: slats) }
}

// MARK: - Clock wipe

/// A wedge that sweeps clockwise from twelve o'clock, like a clock hand.
public struct ClockWipeTransition: Transition {
    public init() {}

    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.mask {
            ClockWipeShape(progress: phase.isIdentity ? 1 : 0)
        }
    }
}

struct ClockWipeShape: Shape {
    var progress: Double

    nonisolated var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    nonisolated func path(in rect: CGRect) -> Path {
        guard progress < 1 else { return Path(rect) }
        guard progress > 0 else { return Path() }
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        let radius = hypot(rect.width, rect.height)
        var path = Path()
        path.move(to: centre)
        // In SwiftUI's y-down space, clockwise: false sweeps clockwise on screen.
        path.addArc(center: centre, radius: radius, startAngle: .degrees(-90), endAngle: .degrees(-90 + 360 * progress), clockwise: false)
        path.closeSubpath()
        return path
    }
}

public extension Transition where Self == ClockWipeTransition {
    /// Sweeps the view in like the hand of a clock.
    ///
    /// ```swift
    /// Badge().transition(.clockWipe)
    /// ```
    static var clockWipe: ClockWipeTransition { ClockWipeTransition() }
}

// MARK: - Dissolve

/// The view appears and disappears in square pixels, in random order.
public struct DissolveTransition: Transition {
    public var cellSize: CGFloat

    public init(cellSize: CGFloat = 10) {
        self.cellSize = max(2, cellSize)
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.mask {
            DissolveShape(progress: phase.isIdentity ? 1 : 0, cellSize: cellSize)
        }
    }
}

struct DissolveShape: Shape {
    var progress: Double
    var cellSize: CGFloat

    nonisolated var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    nonisolated func path(in rect: CGRect) -> Path {
        guard progress < 1 else { return Path(rect) }
        var path = Path()
        guard progress > 0 else { return path }
        let columns = Int((rect.width / cellSize).rounded(.up))
        let rows = Int((rect.height / cellSize).rounded(.up))
        for row in 0..<rows {
            for column in 0..<columns where Self.threshold(column, row) < progress {
                // A hair larger than the cell so neighbours don't leave seams.
                path.addRect(CGRect(x: rect.minX + CGFloat(column) * cellSize, y: rect.minY + CGFloat(row) * cellSize, width: cellSize, height: cellSize).insetBy(dx: -0.25, dy: -0.25))
            }
        }
        return path
    }

    /// A stable pseudo-random value in 0..<1 for each cell.
    static func threshold(_ column: Int, _ row: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: column &* 73_856_093 ^ row &* 19_349_663)
        x = (x ^ (x >> 33)) &* 0xff51_afd7_ed55_8ccd
        x ^= x >> 33
        return Double(x % 10_000) / 10_000
    }
}

public extension Transition where Self == DissolveTransition {
    /// Dissolves the view in and out in random square pixels.
    ///
    /// ```swift
    /// Avatar().transition(.dissolve)
    /// ```
    static var dissolve: DissolveTransition { DissolveTransition() }

    /// Dissolves the view in and out in random pixels of `cellSize` points.
    static func dissolve(cellSize: CGFloat) -> DissolveTransition { DissolveTransition(cellSize: cellSize) }
}

#Preview {
    struct Demo: View {
        @State private var shown = true
        var body: some View {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        ZStack {
                            if shown {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.gradient)
                                    .transition(index == 0 ? AnyTransition(.iris) : index == 1 ? AnyTransition(.blinds) : index == 2 ? AnyTransition(.clockWipe) : AnyTransition(.dissolve))
                            }
                        }
                        .frame(width: 64, height: 64)
                    }
                }
                Button("Toggle") { withAnimation(.easeInOut(duration: 0.8)) { shown.toggle() } }
            }
        }
    }
    return Demo().padding()
}
