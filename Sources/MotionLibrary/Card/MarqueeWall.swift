import SwiftUI

/// A tilted wall of cards whose columns scroll endlessly in alternating
/// directions, the showcase backdrop of portfolio and landing pages.
///
/// ```swift
/// MarqueeWall(count: 12, columns: 4) { index in
///     Image("shot-\(index)").resizable().scaledToFill()
/// }
/// .frame(height: 300)
/// .clipped()
/// ```
public struct MarqueeWall<Content: View>: View {
    private let count: Int
    private let columns: Int
    private let itemSize: CGSize
    private let spacing: CGFloat
    private let speed: Double
    private let angle: Angle
    private let content: (Int) -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - count: Number of distinct items; they're shared out between the columns.
    ///   - columns: Number of columns.
    ///   - itemSize: Size of each card.
    ///   - spacing: Gap between cards.
    ///   - speed: Scroll speed, in points per second.
    ///   - angle: Rotation of the whole wall.
    ///   - content: Builds the card for an index in `0..<count`.
    public init(
        count: Int,
        columns: Int = 4,
        itemSize: CGSize = CGSize(width: 110, height: 140),
        spacing: CGFloat = 12,
        speed: Double = 24,
        angle: Angle = .degrees(-14),
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.count = max(1, count)
        self.columns = max(1, columns)
        self.itemSize = itemSize
        self.spacing = spacing
        self.speed = speed
        self.angle = angle
        self.content = content
    }

    public var body: some View {
        // Each column shows its items twice over, so the loop is seamless.
        let perColumn = max(3, Int(ceil(Double(count) / Double(columns))))
        let loopHeight = CGFloat(perColumn) * (itemSize.height + spacing)
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            HStack(alignment: .top, spacing: spacing) {
                ForEach(0..<columns, id: \.self) { column in
                    let distance = CGFloat((time * speed * (1 + Double(column % 3) * 0.15)).truncatingRemainder(dividingBy: Double(loopHeight)))
                    let offset = column.isMultiple(of: 2) ? -distance : distance - loopHeight
                    VStack(spacing: spacing) {
                        ForEach(0..<(perColumn * 2), id: \.self) { row in
                            content((column * perColumn + row % perColumn) % count)
                                .frame(width: itemSize.width, height: itemSize.height)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                    .offset(y: offset)
                    .frame(height: loopHeight, alignment: .top)
                }
            }
            .rotationEffect(angle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    let colors: [Color] = [.orange, .pink, .purple, .blue, .teal, .green, .yellow, .red]
    return MarqueeWall(count: 8, columns: 4, itemSize: CGSize(width: 80, height: 100)) { index in
        Rectangle().fill(colors[index].gradient)
    }
    .frame(width: 340, height: 240)
    .clipped()
    .background(.black)
}
