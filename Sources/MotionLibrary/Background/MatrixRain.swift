import SwiftUI

/// Falling columns of glyphs, like the digital rain from the films: each
/// column has a bright head and a fading trail, and characters flicker as
/// they fall.
public struct MatrixRain: View {
    private let color: Color
    private let fontSize: CGFloat
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let glyphs = Array("ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜ0123456789").map(String.init)

    /// - Parameters:
    ///   - color: Colour of the trails. Heads are drawn white.
    ///   - fontSize: Glyph size; also sets the column width.
    ///   - speed: Multiplier on the falling speed.
    public init(color: Color = .green, fontSize: CGFloat = 14, speed: Double = 1) {
        self.color = color
        self.fontSize = fontSize
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 7 : timeline.date.timeIntervalSinceReferenceDate * speed
            Canvas { context, size in
                let glyphs = Self.glyphs
                let font = Font.system(size: fontSize, weight: .medium, design: .monospaced)
                // Resolve every glyph once per frame, then stamp them.
                let trail = glyphs.map { context.resolve(Text($0).font(font).foregroundStyle(color)) }
                let head = glyphs.map { context.resolve(Text($0).font(font).foregroundStyle(.white)) }
                let columnWidth = fontSize * 0.9
                let rowHeight = fontSize * 1.1
                let columns = Int(size.width / columnWidth) + 1
                let rows = Int(size.height / rowHeight) + 1
                for column in 0..<columns {
                    let seed = Self.hash(column, 0)
                    let length = 8 + Int(seed * 14)
                    let velocity = 6 + seed * 10 // rows per second
                    let cycle = Double(rows + length)
                    let headRow = Int((time * velocity + seed * 97).truncatingRemainder(dividingBy: cycle))
                    for offset in 0..<length {
                        let row = headRow - offset
                        guard row >= 0 && row < rows else { continue }
                        // Characters change a few times a second.
                        let flicker = Int(time * (2 + seed * 4))
                        let pick = Int(Self.hash(column * 131 + row, flicker) * Double(glyphs.count)) % glyphs.count
                        var copy = context
                        copy.opacity = offset == 0 ? 1 : 0.85 * (1 - Double(offset) / Double(length))
                        copy.draw(offset == 0 ? head[pick] : trail[pick], at: CGPoint(x: CGFloat(column) * columnWidth + columnWidth / 2, y: CGFloat(row) * rowHeight + rowHeight / 2))
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }

    /// A stable pseudo-random value in 0..<1.
    static func hash(_ a: Int, _ b: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: a &* 374_761_393 &+ b &* 668_265_263)
        x = (x ^ (x >> 13)) &* 1_274_126_177
        x ^= x >> 16
        return Double(x % 10_000) / 10_000
    }
}

#Preview {
    MatrixRain()
        .frame(width: 300, height: 220)
        .background(.black)
}
