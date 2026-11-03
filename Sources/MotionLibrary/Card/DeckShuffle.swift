import SwiftUI

/// A small deck of cards that riffle-shuffles every time `trigger` changes:
/// the deck splits into two halves that slide apart, the order is mixed, and
/// the cards spring back together into a slightly messy stack.
public struct DeckShuffle<Data: RandomAccessCollection, Trigger: Equatable, Content: View>: View
where Data.Element: Identifiable {
    private let items: Data
    private let trigger: Trigger
    private let spread: CGFloat
    private let content: (Data.Element) -> Content

    @State private var order: [Data.Element.ID] = []
    @State private var isSplit = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - items: The cards, bottom to top.
    ///   - trigger: Shuffles whenever it changes.
    ///   - spread: How far each half slides out, in points.
    ///   - content: Draws one card.
    public init(_ items: Data, trigger: Trigger, spread: CGFloat = 70, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.trigger = trigger
        self.spread = spread
        self.content = content
    }

    public var body: some View {
        let ids = order.isEmpty ? items.map(\.id) : order
        ZStack {
            ForEach(Array(items)) { item in
                let position = ids.firstIndex(of: item.id) ?? 0
                let tilt = Self.tilt(for: position)
                content(item)
                    .rotationEffect(.degrees(isSplit ? (position.isMultiple(of: 2) ? -8 : 8) : tilt))
                    .offset(
                        x: isSplit ? (position.isMultiple(of: 2) ? -spread : spread) : 0,
                        y: isSplit ? 0 : -CGFloat(position) * 2
                    )
                    .zIndex(Double(position))
            }
        }
        .onAppear { if order.isEmpty { order = items.map(\.id) } }
        .onChange(of: trigger) { shuffle() }
    }

    /// A small, stable tilt per stack position so the deck looks hand-made.
    private static func tilt(for position: Int) -> Double {
        let values: [Double] = [0, -2.5, 2, -1, 3, -2, 1.5, -3]
        return values[position % values.count]
    }

    private func shuffle() {
        let shuffled = (order.isEmpty ? items.map(\.id) : order).shuffled()
        if reduceMotion {
            withAnimation(.easeInOut(duration: 0.3)) { order = shuffled }
            return
        }
        withAnimation(.easeOut(duration: 0.28)) { isSplit = true }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            // Re-ordering while apart changes which half each card is in, so
            // cards visibly cross over as they come back together.
            withAnimation(.spring(duration: 0.55, bounce: 0.3)) {
                order = shuffled
                isSplit = false
            }
        }
    }
}

#Preview {
    struct Card: Identifiable { let id: Int; let color: Color }
    struct Demo: View {
        @State private var shuffles = 0
        let cards = [Card(id: 0, color: .pink), Card(id: 1, color: .orange), Card(id: 2, color: .teal), Card(id: 3, color: .indigo), Card(id: 4, color: .mint)]
        var body: some View {
            DeckShuffle(cards, trigger: shuffles) { card in
                RoundedRectangle(cornerRadius: 12).fill(card.color.gradient).frame(width: 80, height: 112)
            }
            .onTapGesture { shuffles += 1 }
            .padding(80)
        }
    }
    return Demo()
}
