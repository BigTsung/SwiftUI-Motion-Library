import SwiftUI

/// Contour lines of a slowly shifting landscape, like a topographic map
/// coming alive: hills swell and sink and the lines flow around them, with
/// every fifth line drawn heavier.
///
/// ```swift
/// TopographicLines(color: .green)
///     .background(Color(white: 0.06))
/// ```
public struct TopographicLines: View {
    private let levels: Int
    private let scale: Double
    private let color: Color
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - levels: Number of contour lines between the lowest and highest ground.
    ///   - scale: Size of the hills, in points.
    ///   - color: Colour of the lines.
    ///   - speed: How fast the landscape shifts.
    public init(levels: Int = 14, scale: Double = 90, color: Color = .primary, speed: Double = 0.12) {
        self.levels = max(1, levels)
        self.scale = max(10, scale)
        self.color = color
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 10_000) * speed
            Canvas { context, size in
                let cell: CGFloat = 8
                let columns = Int(size.width / cell) + 2, rows = Int(size.height / cell) + 2
                // Height field on the grid corners.
                var field = [Double](repeating: 0, count: columns * rows)
                for row in 0..<rows {
                    for column in 0..<columns {
                        let x = Double(column) * cell / scale, y = Double(row) * cell / scale
                        field[row * columns + column] = Self.noise(x + time, y - time * 0.6) * 0.65 + Self.noise(x * 2.1 - time * 0.8, y * 2.1 + 7) * 0.35
                    }
                }
                for level in 1...levels {
                    let threshold = 0.18 + 0.64 * Double(level) / Double(levels + 1)
                    var path = Path()
                    for row in 0..<(rows - 1) {
                        for column in 0..<(columns - 1) {
                            Self.contour(in: &path, field: field, columns: columns, column: column, row: row, cell: cell, threshold: threshold)
                        }
                    }
                    let major = level % 5 == 0
                    context.stroke(path, with: .color(color.opacity(major ? 0.85 : 0.45)), lineWidth: major ? 1.4 : 0.7)
                }
            }
        }
        .accessibilityHidden(true)
    }

    /// Marching squares: the segment(s) where the field crosses `threshold`
    /// inside one grid cell.
    private static func contour(in path: inout Path, field: [Double], columns: Int, column: Int, row: Int, cell: CGFloat, threshold t: Double) {
        let a = field[row * columns + column], b = field[row * columns + column + 1]
        let c = field[(row + 1) * columns + column + 1], d = field[(row + 1) * columns + column]
        let index = (a > t ? 8 : 0) | (b > t ? 4 : 0) | (c > t ? 2 : 0) | (d > t ? 1 : 0)
        guard index != 0, index != 15 else { return }
        let x = CGFloat(column) * cell, y = CGFloat(row) * cell
        func lerp(_ v1: Double, _ v2: Double) -> CGFloat { CGFloat((t - v1) / (v2 - v1)) }
        let top = CGPoint(x: x + cell * lerp(a, b), y: y)
        let right = CGPoint(x: x + cell, y: y + cell * lerp(b, c))
        let bottom = CGPoint(x: x + cell * lerp(d, c), y: y + cell)
        let left = CGPoint(x: x, y: y + cell * lerp(a, d))
        func segment(_ p: CGPoint, _ q: CGPoint) { path.move(to: p); path.addLine(to: q) }
        switch index {
        case 1, 14: segment(left, bottom)
        case 2, 13: segment(bottom, right)
        case 3, 12: segment(left, right)
        case 4, 11: segment(top, right)
        case 5: segment(left, top); segment(bottom, right)
        case 6, 9: segment(top, bottom)
        case 7, 8: segment(left, top)
        case 10: segment(top, right); segment(left, bottom)
        default: break
        }
    }

    /// Smooth value noise in 0…1.
    private static func noise(_ x: Double, _ y: Double) -> Double {
        let ix = floor(x), iy = floor(y)
        let fx = x - ix, fy = y - iy
        let ux = fx * fx * (3 - 2 * fx), uy = fy * fy * (3 - 2 * fy)
        let a = hash(ix, iy), b = hash(ix + 1, iy), c = hash(ix, iy + 1), d = hash(ix + 1, iy + 1)
        return (a + (b - a) * ux) + ((c + (d - c) * ux) - (a + (b - a) * ux)) * uy
    }

    private static func hash(_ x: Double, _ y: Double) -> Double {
        var h = UInt64(bitPattern: Int64(x) &* 374_761_393 &+ Int64(y) &* 668_265_263)
        h = (h ^ (h >> 13)) &* 1_274_126_177
        h ^= h >> 16
        return Double(h % 10_000) / 10_000
    }
}

#Preview {
    TopographicLines(color: .mint)
        .frame(width: 340, height: 240)
        .background(Color(white: 0.06))
}
