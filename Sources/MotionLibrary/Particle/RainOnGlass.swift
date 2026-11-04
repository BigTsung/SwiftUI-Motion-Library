import SwiftUI

/// Raindrops on a window: tiny beads cling to the glass while bigger drops
/// slide down in fits and starts, leaving a dotted trail behind them. Put it
/// over a blurred photo or a dark gradient.
///
/// ```swift
/// Image("city-night")
///     .blur(radius: 6)
///     .overlay(RainOnGlass())
/// ```
public struct RainOnGlass: View {
    private let drops: Int
    private let color: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - drops: Number of sliding drops.
    ///   - color: Colour of the drops' highlights.
    public init(drops: Int = 9, color: Color = .white) {
        self.drops = max(0, drops)
        self.color = color
    }

    @available(*, deprecated, renamed: "init(drops:color:)")
    public init(drops: Int = 9, tint: Color) {
        self.init(drops: drops, color: tint)
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                // Beads that cling to the glass.
                let beads = Int(size.width * size.height / 900)
                for index in 0..<beads {
                    let x = Self.hash(index, 1) * size.width, y = Self.hash(index, 2) * size.height
                    drawDrop(&context, at: CGPoint(x: x, y: y), radius: 0.8 + Self.hash(index, 3) * 1.8)
                }
                // Drops that slide down in fits and starts, then start over.
                for index in 0..<drops {
                    let cycle = 3.5 + Self.hash(index, 4) * 4
                    let local = (time + Self.hash(index, 5) * 20).truncatingRemainder(dividingBy: cycle) / cycle
                    // Stick-slip: a staircase smoothed with a little ease.
                    let steps = 5.0
                    let stepped = (floor(local * steps) + pow(local * steps - floor(local * steps), 3)) / steps
                    let startY = -20 + Self.hash(index, 6) * size.height * 0.4
                    let y = startY + stepped * (size.height + 40 - startY)
                    let wobble = sin(local * 9 + Double(index)) * 3
                    let x = Self.hash(index, 7) * size.width + wobble
                    let radius = 3.2 + Self.hash(index, 8) * 2.6
                    // The trail of tiny beads left behind.
                    let trailCount = Int((y - startY) / 9)
                    for t in 0..<max(0, trailCount) {
                        let ty = startY + Double(t) * 9 + Self.hash(index * 31 + t, 9) * 5
                        let tx = Self.hash(index, 7) * size.width + sin(Double(t) * 1.7 + Double(index)) * 1.5
                        drawDrop(&context, at: CGPoint(x: tx, y: ty), radius: 0.7 + Self.hash(index * 31 + t, 10) * 0.8)
                    }
                    drawDrop(&context, at: CGPoint(x: x, y: y), radius: radius, stretch: 1.25)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// A drop: darker rim at the bottom, bright fleck at the top-left, like a
    /// tiny lens.
    private func drawDrop(_ context: inout GraphicsContext, at p: CGPoint, radius r: Double, stretch: Double = 1) {
        let rect = CGRect(x: p.x - r, y: p.y - r * stretch, width: r * 2, height: r * 2 * stretch)
        context.fill(Path(ellipseIn: rect), with: .linearGradient(
            Gradient(colors: [color.opacity(0.35), color.opacity(0.05), Color.black.opacity(0.35)]),
            startPoint: CGPoint(x: rect.minX, y: rect.minY), endPoint: CGPoint(x: rect.maxX, y: rect.maxY)))
        let fleck = r * 0.35
        context.fill(Path(ellipseIn: CGRect(x: p.x - r * 0.45 - fleck / 2, y: p.y - r * stretch * 0.5 - fleck / 2, width: fleck, height: fleck)), with: .color(color.opacity(0.8)))
    }

    private static func hash(_ a: Int, _ b: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: a &* 73_856_093 ^ b &* 19_349_663 &+ 0x7A1D)
        x = (x ^ (x >> 33)) &* 0xff51_afd7_ed55_8ccd
        x ^= x >> 33
        return Double(x % 10_000) / 10_000
    }
}

#Preview {
    LinearGradient(colors: [Color(red: 0.1, green: 0.15, blue: 0.3), Color(red: 0.35, green: 0.2, blue: 0.4)], startPoint: .top, endPoint: .bottom)
        .overlay(RainOnGlass())
        .frame(width: 340, height: 240)
}
