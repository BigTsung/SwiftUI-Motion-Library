import SwiftUI

/// A horizontal carousel in the style of Cover Flow: the centred item faces
/// you, and items to either side turn away in 3D, recede and dim. Items snap
/// to the centre.
public struct CoverFlow<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    private let items: Data
    private let selection: Binding<Data.Element.ID?>?
    private let itemWidth: CGFloat
    private let spacing: CGFloat
    private let maxAngle: Double
    private let content: (Data.Element) -> Content

    @State private var internalSelection: Data.Element.ID?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - items: One item per element.
    ///   - selection: Optional binding to the centred item; set it to scroll.
    ///   - itemWidth: Width of each item in points.
    ///   - spacing: Gap between items (negative values overlap them).
    ///   - maxAngle: How far side items turn, in degrees.
    ///   - content: Builds one item, usually artwork.
    public init(
        _ items: Data,
        selection: Binding<Data.Element.ID?>? = nil,
        itemWidth: CGFloat = 140,
        spacing: CGFloat = -10,
        maxAngle: Double = 50,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.items = items
        self.selection = selection
        self.itemWidth = itemWidth
        self.spacing = spacing
        self.maxAngle = maxAngle
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            // Plain values for the visualEffect closure, which can't touch the view.
            let fallbackWidth = geometry.size.width
            let itemWidth = itemWidth
            let maxAngle = reduceMotion ? 0 : maxAngle
            ScrollView(.horizontal) {
                LazyHStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                            .frame(width: itemWidth)
                            .visualEffect { view, proxy in
                                // -1 (one item left of centre) … 0 (centred) … 1.
                                let frame = proxy.frame(in: .scrollView(axis: .horizontal))
                                let viewport = proxy.bounds(of: .scrollView(axis: .horizontal))?.width ?? fallbackWidth
                                let clamped = max(-1, min(1, (frame.midX - viewport / 2) / itemWidth))
                                let angle = -clamped * maxAngle
                                return view
                                    .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                                    .scaleEffect(1 - abs(clamped) * 0.18)
                                    .brightness(-abs(clamped) * 0.25)
                            }
                            // Centred item draws on top of its neighbours.
                            .zIndex(isSelected(item) ? 1 : 0)
                            .id(item.id)
                    }
                }
                .scrollTargetLayout()
                .frame(height: geometry.size.height)
            }
            .contentMargins(.horizontal, max(0, (geometry.size.width - itemWidth) / 2), for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollPosition(id: selection ?? $internalSelection, anchor: .center)
        }
    }

    private func isSelected(_ item: Data.Element) -> Bool {
        (selection?.wrappedValue ?? internalSelection) == item.id
    }
}

#Preview {
    struct Album: Identifiable {
        let id: Int
        let color: Color
    }
    let albums = [Color.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple]
        .enumerated().map { Album(id: $0, color: $1) }
    return CoverFlow(albums) { album in
        RoundedRectangle(cornerRadius: 12)
            .fill(album.color.gradient)
            .aspectRatio(1, contentMode: .fit)
            .overlay(Image(systemName: "music.note").font(.largeTitle).foregroundStyle(.white))
    }
    .frame(height: 200)
}
