import SwiftUI

/// Which way a card left the stack.
public enum SwipeDirection: Sendable {
    case left
    case right
}

/// A Tinder-style deck. The top card follows the finger and tilts; past a
/// threshold it flies off and the cards behind move up. Drag less and it
/// springs back.
public struct SwipeCardStack<Data: RandomAccessCollection, Card: View>: View where Data.Element: Identifiable {
    private let items: Data
    private let visibleCount: Int
    private let loops: Bool
    private let onSwipe: (Data.Element, SwipeDirection) -> Void
    private let card: (Data.Element) -> Card

    @State private var position = 0
    @State private var drag: CGSize = .zero
    @State private var flyingOff: SwipeDirection?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let threshold: CGFloat = 110

    /// - Parameters:
    ///   - items: The cards, top card first.
    ///   - visibleCount: How many cards are drawn in the pile.
    ///   - loops: Starts over from the first card when the deck runs out.
    ///   - onSwipe: Called after a card leaves, with the direction it went.
    ///   - card: Builds the view for one item.
    public init(
        _ items: Data,
        visibleCount: Int = 3,
        loops: Bool = true,
        onSwipe: @escaping (Data.Element, SwipeDirection) -> Void = { _, _ in },
        @ViewBuilder card: @escaping (Data.Element) -> Card
    ) {
        self.items = items
        self.visibleCount = visibleCount
        self.loops = loops
        self.onSwipe = onSwipe
        self.card = card
    }

    public var body: some View {
        let elements = Array(items)
        ZStack {
            ForEach(Array(visibleCards(elements).enumerated()).reversed(), id: \.element.id) { depth, item in
                card(item)
                    .modifier(StackedCard(depth: depth, drag: depth == 0 ? drag : .zero, threshold: threshold))
                    .allowsHitTesting(depth == 0)
                    .gesture(depth == 0 ? dragGesture(for: item) : nil)
                    .accessibilityHidden(depth != 0)
                    .accessibilityActions {
                        Button("Swipe left") { swipe(item, .left) }
                        Button("Swipe right") { swipe(item, .right) }
                    }
            }
        }
    }

    private func visibleCards(_ elements: [Data.Element]) -> [Data.Element] {
        guard !elements.isEmpty else { return [] }
        let remaining = loops ? elements.count : max(0, elements.count - position)
        return (0..<min(visibleCount, remaining)).map { elements[(position + $0) % elements.count] }
    }

    private func dragGesture(for item: Data.Element) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard flyingOff == nil else { return }
                drag = value.translation
            }
            .onEnded { value in
                guard flyingOff == nil else { return }
                // Use the predicted end so a quick flick counts too.
                let x = value.predictedEndTranslation.width
                if abs(x) > threshold {
                    swipe(item, x > 0 ? .right : .left)
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { drag = .zero }
                }
            }
    }

    private func swipe(_ item: Data.Element, _ direction: SwipeDirection) {
        flyingOff = direction
        let distance: CGFloat = direction == .right ? 600 : -600
        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .easeIn(duration: 0.25)) {
            drag = CGSize(width: distance, height: drag.height + 40)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { drag = .zero }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { position += 1 }
            flyingOff = nil
            onSwipe(item, direction)
        }
    }
}

/// Places a card in the pile: deeper cards are smaller and lower; the top
/// card follows the drag and tilts away from it.
private struct StackedCard: ViewModifier {
    var depth: Int
    var drag: CGSize
    var threshold: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay {
                // Green or red wash that grows as the card nears the threshold.
                let progress = min(1, abs(drag.width) / threshold)
                (drag.width > 0 ? Color.green : Color.red)
                    .opacity(depth == 0 ? Double(progress) * 0.25 : 0)
                    .mask { content }
                    .allowsHitTesting(false)
            }
            .scaleEffect(1 - CGFloat(depth) * 0.05)
            .offset(y: CGFloat(depth) * 12)
            .offset(drag)
            .rotationEffect(.degrees(Double(drag.width / 20)), anchor: .bottom)
    }
}

#Preview {
    struct Item: Identifiable {
        let id: Int
        let color: Color
    }
    let items = [Color.pink, .orange, .teal, .indigo].enumerated().map { Item(id: $0, color: $1) }
    return SwipeCardStack(items) { item in
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(item.color.gradient)
            .frame(width: 220, height: 300)
            .overlay(Text("Card \(item.id + 1)").font(.title.bold()).foregroundStyle(.white))
    }
    .padding(40)
}
