import SwiftUI

/// A 3×3 `MeshGradient` whose inner points drift in slow loops, so the
/// colours flow into each other like liquid.
@available(iOS 18, macOS 15, visionOS 2, *)
public struct AnimatedMeshGradient: View {
    private let colors: [Color]
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - colors: Nine colours, row by row from the top left. Fewer are
    ///     repeated; more are ignored.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    public init(
        colors: [Color] = [
            .indigo, .purple, .pink,
            .blue, .purple, .orange,
            .teal, .mint, .yellow,
        ],
        speed: Double = 1
    ) {
        let palette = colors.isEmpty ? [Color.blue] : colors
        self.colors = (0..<9).map { palette[$0 % palette.count] }
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let t = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate * speed
            MeshGradient(width: 3, height: 3, points: Self.points(at: t), colors: colors)
        }
        .accessibilityHidden(true)
    }

    /// Corners stay put; edge midpoints slide along their edge and the
    /// centre wanders, each on its own period.
    static func points(at t: Double) -> [SIMD2<Float>] {
        func wave(_ period: Double, _ amount: Double, _ offset: Double = 0) -> Float {
            Float(sin(t * 2 * .pi / period + offset) * amount)
        }
        return [
            [0, 0], [0.5 + wave(7, 0.2), 0], [1, 0],
            [0, 0.5 + wave(9, 0.2, 1)], [0.5 + wave(6, 0.25, 2), 0.5 + wave(8, 0.25)], [1, 0.5 + wave(10, 0.2, 3)],
            [0, 1], [0.5 + wave(8, 0.2, 4), 1], [1, 1],
        ]
    }
}

#Preview {
    if #available(iOS 18, macOS 15, visionOS 2, *) {
        AnimatedMeshGradient()
            .frame(width: 300, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
