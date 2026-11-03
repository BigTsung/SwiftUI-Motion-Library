import SwiftUI

/// A stack of cards that fans out like a hand of playing cards, and gathers
/// back into a neat pile. Cards follow each other with a short stagger.
public struct FanStack<Item: Identifiable, Content: View>: View {
    private let items: [Item]
    private let isSpread: Bool
    private let angle: Double
    private let spacing: CGFloat
    private let content: (Item) -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - items: The cards, bottom first.
    ///   - isSpread: Fanned out (true) or stacked (false).
    ///   - angle: Rotation between neighbouring cards when fanned, in degrees.
    ///   - spacing: Horizontal distance between neighbouring cards when fanned.
    ///   - content: The card for an item.
    public init(
        _ items: [Item],
        isSpread: Bool,
        angle: Double = 10,
        spacing: CGFloat = 34,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.isSpread = isSpread
        self.angle = angle
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        ZStack {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let centred = Double(index) - Double(items.count - 1) / 2
                content(item)
                    .rotationEffect(
                        .degrees(isSpread ? centred * angle : centred * 1.5),
                        anchor: isSpread ? .bottom : .center
                    )
                    .offset(
                        x: isSpread ? CGFloat(centred) * spacing : 0,
                        // The outer cards dip, following the arc of the fan.
                        y: isSpread ? CGFloat(abs(centred) * abs(centred)) * 4 : CGFloat(-index) * 2
                    )
                    .animation(
                        reduceMotion
                            ? .easeInOut(duration: 0.25)
                            : .spring(response: 0.45, dampingFraction: 0.7).delay(Double(index) * 0.03),
                        value: isSpread
                    )
            }
        }
    }
}

#Preview {
    struct Card: Identifiable {
        let id: Int
        let color: Color
    }
    struct Demo: View {
        @State private var spread = false
        let cards = [Color.pink, .orange, .yellow, .mint, .blue].enumerated().map { Card(id: $0.offset, color: $0.element) }
        var body: some View {
            FanStack(cards, isSpread: spread) { card in
                RoundedRectangle(cornerRadius: 10).fill(card.color.gradient).frame(width: 60, height: 86)
            }
            .onTapGesture { spread.toggle() }
        }
    }
    return Demo().padding(60)
}
