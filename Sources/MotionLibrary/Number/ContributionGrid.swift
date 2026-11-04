import SwiftUI

/// A grid of small squares shaded by value, like a contributions calendar.
/// On appear the squares pop in column by column in a diagonal wave, and
/// when the values change the new shades ripple through the same way.
///
/// ```swift
/// ContributionGrid(values: commitsPerDay, color: .green)
/// ```
public struct ContributionGrid: View {
    private let values: [Double]
    private let rows: Int
    private let color: Color
    private let cellSize: CGFloat
    private let spacing: CGFloat

    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - values: One value per day, filled top to bottom, then left to right.
    ///     Shades are relative to the largest value.
    ///   - rows: Squares per column (7 for a week).
    ///   - color: Colour of the busiest squares.
    ///   - cellSize: Side of a square, in points.
    ///   - spacing: Gap between squares.
    public init(values: [Double], rows: Int = 7, color: Color = .green, cellSize: CGFloat = 11, spacing: CGFloat = 3) {
        self.values = values
        self.rows = max(1, rows)
        self.color = color
        self.cellSize = cellSize
        self.spacing = spacing
    }

    public var body: some View {
        let columns = Int(ceil(Double(values.count) / Double(rows)))
        let peak = max(values.max() ?? 0, .leastNonzeroMagnitude)
        HStack(alignment: .top, spacing: spacing) {
            ForEach(0..<columns, id: \.self) { column in
                VStack(spacing: spacing) {
                    ForEach(0..<rows, id: \.self) { row in
                        let index = column * rows + row
                        if index < values.count {
                            let level = shade(values[index] / peak)
                            RoundedRectangle(cornerRadius: cellSize * 0.22, style: .continuous)
                                .fill(level == 0 ? Color.secondary.opacity(0.15) : color.opacity(0.25 + 0.75 * level))
                                .frame(width: cellSize, height: cellSize)
                                .scaleEffect(shown || reduceMotion ? 1 : 0.2)
                                .opacity(shown ? 1 : 0)
                                .animation(wave(column: column, row: row), value: shown)
                                .animation(wave(column: column, row: row), value: level)
                        }
                    }
                }
            }
        }
        .onAppear { shown = true }
        .accessibilityElement()
        .accessibilityLabel("Activity grid")
        .accessibilityValue("\(values.filter { $0 > 0 }.count) of \(values.count) days active")
    }

    /// Rounds a 0…1 share to one of five shades, like a contributions calendar.
    private func shade(_ share: Double) -> Double {
        guard share > 0 else { return 0 }
        return min(1, ceil(share * 4) / 4)
    }

    private func wave(column: Int, row: Int) -> Animation {
        if reduceMotion { return .easeInOut(duration: 0.3) }
        return .spring(duration: 0.4, bounce: 0.45).delay(Double(column) * 0.035 + Double(row) * 0.02)
    }
}

#Preview {
    struct Demo: View {
        @State private var seed = 1
        var body: some View {
            ContributionGrid(values: (0..<(7 * 20)).map { index in
                let x = sin(Double(index * seed) * 12.9898) * 43758.5453
                let r = x - floor(x)
                return r < 0.3 ? 0 : r * 10
            })
            .onTapGesture { seed += 1 }
        }
    }
    return Demo()
}
