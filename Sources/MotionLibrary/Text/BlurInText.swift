import SwiftUI

/// Text that comes into focus one word (or one letter) at a time: each piece
/// fades in, rises a few points and un-blurs, staggered from first to last.
/// Replays whenever the string changes.
public struct BlurInText: View {
    /// How the string is split into animated pieces.
    public enum Unit: Sendable {
        case word
        case character
    }

    private let text: String
    private let unit: Unit
    private let stagger: Double
    private let duration: Double

    @State private var revealed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - text: The string to show.
    ///   - unit: Animate word by word or character by character.
    ///   - stagger: Delay between consecutive pieces, in seconds.
    ///   - duration: How long each piece takes to come into focus.
    public init(_ text: String, by unit: Unit = .word, stagger: Double = 0.08, duration: Double = 0.6) {
        self.text = text
        self.unit = unit
        self.stagger = stagger
        self.duration = duration
    }

    public var body: some View {
        FlowLayout(spacing: unit == .word ? 0.28 : 0) {
            ForEach(Array(pieces.enumerated()), id: \.offset) { index, piece in
                Text(piece)
                    .opacity(revealed ? 1 : 0)
                    .blur(radius: revealed || reduceMotion ? 0 : 8)
                    .offset(y: revealed || reduceMotion ? 0 : 8)
                    .animation(
                        .easeOut(duration: duration).delay(Double(index) * stagger),
                        value: revealed
                    )
            }
        }
        .id(text)
        .onAppear(perform: reveal)
        .onChange(of: text) { reveal() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }

    private var pieces: [String] {
        switch unit {
        case .word:
            text.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        case .character:
            text.map(String.init)
        }
    }

    private func reveal() {
        revealed = false
        DispatchQueue.main.async { revealed = true }
    }
}

/// Lays children out left to right, wrapping onto new lines. `spacing` is a
/// fraction of the line height, so word gaps scale with the font.
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews: subviews, maxWidth: proposal.width ?? .infinity)
        let width = rows.map(\.width).max() ?? 0
        let height = rows.reduce(0) { $0 + $1.height }
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(subviews: subviews, maxWidth: bounds.width)
        var y = bounds.minY
        for row in rows {
            // Centre each row, like multi-line centred text.
            var x = bounds.minX + (bounds.width - row.width) / 2
            for item in row.items {
                subviews[item.index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                x += item.size.width + item.gap
            }
            y += row.height
        }
    }

    private struct Row {
        var items: [(index: Int, size: CGSize, gap: CGFloat)] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var row = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let gapBefore = row.items.last?.gap ?? 0
            let width = row.items.isEmpty ? size.width : row.width + gapBefore + size.width
            if width > maxWidth, !row.items.isEmpty {
                rows.append(row)
                row = Row()
                row.width = size.width
            } else {
                row.width = width
            }
            row.items.append((index, size, size.height * spacing))
            row.height = max(row.height, size.height)
        }
        rows.append(row)
        return rows
    }
}

#Preview {
    BlurInText("Design is not just what it looks like. Design is how it works.")
        .font(.title2.weight(.semibold))
        .padding()
}
