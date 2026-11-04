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
    ///   - speed: How fast the seeds drift.
    public init(colors: [Color] = [.indigo, .purple, .pink, .orange, .teal], cellSize: Double = 60, speed: Double = 0.6) {
        self.colors = colors.isEmpty ? [.gray] : colors
        self.cellSize = max(8, cellSize)
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
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
