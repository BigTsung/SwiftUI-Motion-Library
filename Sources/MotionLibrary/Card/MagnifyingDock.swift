import SwiftUI

/// A row of icons that swell as the pointer (or a dragging finger) passes
/// over them, like the macOS Dock. Neighbours grow a little too.
public struct MagnifyingDock<Item: Identifiable, Content: View>: View {
    private let items: [Item]
    private let size: CGFloat
    private let magnification: CGFloat
    private let range: CGFloat
    private let spacing: CGFloat
    private let content: (Item) -> Content

    @State private var pointerX: CGFloat?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - items: The items to show.
    ///   - size: Resting icon size, in points.
    ///   - magnification: Scale of the icon right under the pointer.
    ///   - range: Distance in points over which neighbours still grow.
    ///   - spacing: Gap between icons.
    ///   - content: The icon for an item; it is sized to fill a square.
    public init(
        _ items: [Item],
        size: CGFloat = 40,
        magnification: CGFloat = 1.8,
        range: CGFloat = 110,
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.size = size
        self.magnification = magnification
        self.range = range
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: spacing) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let side = size * scale(for: index)
                content(item)
                    .frame(width: side, height: side)
            }
        }
        // A frame the size of the resting row: the magnified row overflows it
        // evenly on both sides, and the pointer is measured in resting
        // coordinates, so the icons don't run away from it.
        .frame(width: restingWidth, height: size * magnification, alignment: .bottom)
        .contentShape(Rectangle())
        .onContinuousHover(coordinateSpace: .local) { phase in
            switch phase {
            case let .active(point): track(point.x)
            case .ended: track(nil)
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { track($0.location.x) }
                .onEnded { _ in track(nil) }
        )
        .padding(.horizontal, size * (magnification - 1) + spacing)
        .padding(.vertical, 6)
    }

    private var restingWidth: CGFloat {
        CGFloat(items.count) * size + CGFloat(max(0, items.count - 1)) * spacing
    }

    /// Scale of the icon at `index`: a cosine falloff of the distance between
    /// its resting centre and the pointer.
    private func scale(for index: Int) -> CGFloat {
        guard let pointerX, !reduceMotion else { return 1 }
        let restingCentre = CGFloat(index) * (size + spacing) + size / 2
        let distance = abs(pointerX - restingCentre)
        guard distance < range else { return 1 }
        let falloff = cos(distance / range * .pi / 2)
        return 1 + (magnification - 1) * falloff
    }

    private func track(_ x: CGFloat?) {
        withAnimation(x == nil ? .spring(response: 0.35, dampingFraction: 0.75) : .interactiveSpring(response: 0.2, dampingFraction: 0.85)) {
            pointerX = x
        }
    }
}

#Preview {
    struct App: Identifiable {
        let id: String
        let color: Color
    }
    let apps = [("message.fill", Color.green), ("safari.fill", .blue), ("music.note", .pink), ("photo.fill", .orange), ("gearshape.fill", .gray)]
        .map { App(id: $0.0, color: $0.1) }
    return MagnifyingDock(apps) { app in
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(app.color.gradient)
            .overlay(Image(systemName: app.id).foregroundStyle(.white))
    }
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    .padding()
}
