import SwiftUI

/// A grid of thumbnails where tapping one grows it into a detail card that
/// fills the grid, morphing frame and corners with `matchedGeometryEffect`.
/// Tapping the detail shrinks it back into its slot.
public struct HeroGrid<Item: Identifiable, Thumbnail: View, Detail: View>: View {
    private let items: [Item]
    private let columns: Int
    private let spacing: CGFloat
    private let cornerRadius: CGFloat
    private let thumbnail: (Item) -> Thumbnail
    private let detail: (Item) -> Detail

    @State private var selected: Item.ID?
    @Namespace private var namespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - items: The items to show.
    ///   - columns: Number of grid columns.
    ///   - spacing: Gap between cells, in points.
    ///   - cornerRadius: Corner radius of thumbnails and the detail card.
    ///   - thumbnail: The small cell for an item. Give it a background so the
    ///     morph has something to stretch.
    ///   - detail: The expanded card for an item.
    public init(
        _ items: [Item],
        columns: Int = 3,
        spacing: CGFloat = 10,
        cornerRadius: CGFloat = 14,
        @ViewBuilder thumbnail: @escaping (Item) -> Thumbnail,
        @ViewBuilder detail: @escaping (Item) -> Detail
    ) {
        self.items = items
        self.columns = columns
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.thumbnail = thumbnail
        self.detail = detail
    }

    public var body: some View {
        // Reduce Motion: cross-fade in place of the morph.
        let morph: MatchedGeometryProperties = reduceMotion ? [] : .frame
        ZStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: max(1, columns)), spacing: spacing) {
                ForEach(items) { item in
                    ZStack {
                        if selected != item.id {
                            Button { open(item.id) } label: {
                                thumbnail(item)
                                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .matchedGeometryEffect(id: item.id, in: namespace, properties: morph)
                            .transition(.opacity.animation(.easeInOut(duration: 0.15)))
                        } else {
                            // Keep the slot so the grid doesn't reflow.
                            thumbnail(item).hidden()
                        }
                    }
                }
            }
            .opacity(selected == nil ? 1 : 0.3)

            if let id = selected, let item = items.first(where: { $0.id == id }) {
                Button { close() } label: {
                    detail(item)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)
                .matchedGeometryEffect(id: id, in: namespace, properties: morph)
                .transition(.opacity.animation(.easeInOut(duration: 0.15)))
                .zIndex(1)
            }
        }
    }

    private func open(_ id: Item.ID) {
        withAnimation(reduceMotion ? .easeInOut(duration: 0.25) : .spring(response: 0.45, dampingFraction: 0.82)) {
            selected = id
        }
    }

    private func close() {
        withAnimation(reduceMotion ? .easeInOut(duration: 0.25) : .spring(response: 0.4, dampingFraction: 0.85)) {
            selected = nil
        }
    }
}

#Preview {
    struct Tile: Identifiable {
        let id: Int
        let color: Color
    }
    let tiles = [Color.pink, .orange, .teal, .indigo, .mint, .purple].enumerated().map { Tile(id: $0.offset, color: $0.element) }
    return HeroGrid(tiles) { tile in
        tile.color.frame(height: 70)
    } detail: { tile in
        tile.color.overlay(Text("Tile \(tile.id + 1)").font(.title.bold()).foregroundStyle(.white))
    }
    .frame(width: 300, height: 160)
    .padding()
}
