import SwiftUI

/// A paging carousel whose card contents slide slower than the cards
/// themselves, so images seem to sit deeper than the frame around them.
/// Neighbouring cards peek in from both sides.
public struct ParallaxCarousel<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    private let items: Data
    private let selection: Binding<Data.Element.ID?>?
    private let cardWidth: CGFloat
    private let spacing: CGFloat
    private let cornerRadius: CGFloat
    private let parallax: CGFloat
    private let content: (Data.Element) -> Content

    @State private var internalSelection: Data.Element.ID?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - items: One card per item.
    ///   - selection: Optional binding to the centred card; set it to scroll.
    ///   - cardWidth: Card width as a fraction of the carousel's width.
    ///   - spacing: Gap between cards.
    ///   - cornerRadius: Corner radius of each card.
    ///   - parallax: How much slower the content moves than its card (0…1).
    ///   - content: The card's content, usually an image. It is drawn wider
    ///     than the card so the parallax never reveals an edge.
    public init(
        _ items: Data,
        selection: Binding<Data.Element.ID?>? = nil,
        cardWidth: CGFloat = 0.78,
        spacing: CGFloat = 14,
        cornerRadius: CGFloat = 22,
        parallax: CGFloat = 0.35,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.items = items
        self.selection = selection
        self.cardWidth = cardWidth
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.parallax = parallax
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width * cardWidth
            let strength = reduceMotion ? 0 : parallax
            ScrollView(.horizontal) {
                LazyHStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                            // Extra width on both sides for the content to slide into.
                            .frame(width: width * (1 + strength), height: geometry.size.height)
                            .visualEffect { view, proxy in
                                // How far this card's centre is from the carousel's centre.
                                let frame = proxy.frame(in: .scrollView(axis: .horizontal))
                                let viewport = proxy.bounds(of: .scrollView(axis: .horizontal))?.width ?? frame.width
                                let distance = frame.midX - viewport / 2
                                return view.offset(x: -distance * strength)
                            }
                            .frame(width: width, height: geometry.size.height)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            .id(item.id)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, (geometry.size.width - width) / 2, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollPosition(id: selection ?? $internalSelection, anchor: .center)
        }
    }
}

#Preview {
    struct Place: Identifiable {
        let id: Int
        let colors: [Color]
    }
    let places = [
        Place(id: 0, colors: [.orange, .pink]),
        Place(id: 1, colors: [.teal, .blue]),
        Place(id: 2, colors: [.purple, .indigo]),
        Place(id: 3, colors: [.mint, .green]),
    ]
    return ParallaxCarousel(places) { place in
        LinearGradient(colors: place.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(Image(systemName: "mountain.2.fill").font(.system(size: 60)).foregroundStyle(.white.opacity(0.8)))
    }
    .frame(height: 220)
}
