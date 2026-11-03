import SwiftUI

/// A horizontally paging carousel that never ends: it wraps from the last
/// card back to the first. Neighbours peek in from the sides, shrunk and
/// faded, and it can advance on its own.
///
/// The items are laid out three times; after scrolling settles, the
/// position silently jumps back to the middle copy.
public struct LoopingCarousel<Data: RandomAccessCollection, Content: View>: View where Data.Index == Int {
    private let items: Data
    private let spacing: CGFloat
    private let peek: CGFloat
    private let autoplay: Double?
    private let content: (Data.Element) -> Content

    @State private var position: Int?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - items: The cards, in order.
    ///   - spacing: Gap between cards, in points.
    ///   - peek: How much of each neighbour shows at the sides, in points.
    ///   - autoplay: Seconds between automatic advances; `nil` to disable.
    ///   - content: Draws one card.
    public init(_ items: Data, spacing: CGFloat = 12, peek: CGFloat = 36, autoplay: Double? = nil, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.spacing = spacing
        self.peek = peek
        self.autoplay = autoplay
        self.content = content
    }

    public var body: some View {
        let count = items.count
        let reduceMotion = reduceMotion
        ScrollView(.horizontal) {
            LazyHStack(spacing: spacing) {
                ForEach(0..<(count * 3), id: \.self) { index in
                    content(items[items.startIndex + index % max(1, count)])
                        .containerRelativeFrame(.horizontal)
                        .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                            view
                                .scaleEffect(reduceMotion ? 1 : 1 - abs(phase.value) * 0.12)
                                .opacity(1 - abs(phase.value) * 0.4)
                        }
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, peek + spacing, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $position)
        .onAppear { if position == nil { position = count } }
        .task(id: position) {
            // Once scrolling has settled, recentre on the middle copy.
            try? await Task.sleep(for: .seconds(0.45))
            guard count > 0, let current = position, current < count || current >= count * 2 else { return }
            var jump = Transaction()
            jump.disablesAnimations = true
            withTransaction(jump) { position = count + current % count }
        }
        .task(id: autoplay) {
            guard let autoplay, count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(autoplay))
                guard !Task.isCancelled else { return }
                withAnimation(.spring(duration: 0.6, bounce: 0.15)) {
                    position = (position ?? count) + 1
                }
            }
        }
    }
}

#Preview {
    LoopingCarousel([Color.pink, .orange, .teal, .indigo], autoplay: 2) { color in
        RoundedRectangle(cornerRadius: 20).fill(color.gradient).frame(height: 180)
    }
    .frame(height: 200)
}
