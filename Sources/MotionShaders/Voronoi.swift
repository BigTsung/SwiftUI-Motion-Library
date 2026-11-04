import SwiftUI

/// A background of slowly drifting Voronoi cells, like stained glass or
/// living tissue: every point takes the colour of its nearest moving seed,
/// with soft dark seams between cells. Rendered with a Metal `colorEffect`
/// (`Shaders/Voronoi.metal`).
public struct VoronoiCells: View {
    private let colors: [Color]
    private let cellSize: Double
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - colors: Colours the cells are picked from.
    ///   - cellSize: Typical size of a cell, in points.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    public init(colors: [Color] = [.indigo, .purple, .pink, .orange, .teal], cellSize: Double = 60, speed: Double = 1) {
        self.colors = colors.isEmpty ? [.gray] : colors
        self.cellSize = max(8, cellSize)
        self.speed = speed * 0.6
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion || speed == 0)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3600) * speed
            Rectangle()
                .fill(.white)
                .colorEffect(motionShaders.motionVoronoi(.float(time), .float(cellSize), .colorArray(colors)))
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    VoronoiCells()
        .frame(width: 320, height: 220)
}
