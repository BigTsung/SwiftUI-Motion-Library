import SwiftUI

/// A floating tab bar: a pill glides to the selected tab and its icon does a
/// little squash-and-hop.
public struct BouncyTabBar: View {
    /// One tab: an SF Symbol and a short title.
    public struct Item: Hashable, Sendable {
        public var symbol: String
        public var title: String

        public init(_ symbol: String, _ title: String) {
            self.symbol = symbol
            self.title = title
        }
    }

    @Binding private var selection: Int
    private let items: [Item]
    private let color: Color

    @Namespace private var namespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - selection: Index of the selected tab.
    ///   - items: The tabs, in order.
    ///   - color: Tint of the selected tab.
    public init(selection: Binding<Int>, items: [Item], color: Color = .accentColor) {
        _selection = selection
        self.items = items
        self.color = color
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(items.indices, id: \.self) { index in
                tab(index)
            }
        }
        .padding(6)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        .haptic(.lightImpact, trigger: selection)
    }

    private func tab(_ index: Int) -> some View {
        let selected = index == selection
        let bounce = selected && !reduceMotion
        return Button {
            withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(duration: 0.4, bounce: 0.3)) {
                selection = index
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: items[index].symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .keyframeAnimator(initialValue: HopValues(), trigger: selection) { view, value in
                        view
                            .scaleEffect(x: bounce ? value.scaleX : 1, y: bounce ? value.scaleY : 1, anchor: .bottom)
                            .offset(y: bounce ? value.y : 0)
                    } keyframes: { _ in
                        KeyframeTrack(\.scaleX) {
                            CubicKeyframe(1.25, duration: 0.08)
                            CubicKeyframe(0.9, duration: 0.14)
                            SpringKeyframe(1, duration: 0.3, spring: .bouncy)
                        }
                        KeyframeTrack(\.scaleY) {
                            CubicKeyframe(0.75, duration: 0.08)
                            CubicKeyframe(1.12, duration: 0.14)
                            SpringKeyframe(1, duration: 0.3, spring: .bouncy)
                        }
                        KeyframeTrack(\.y) {
                            LinearKeyframe(0, duration: 0.08)
                            CubicKeyframe(-7, duration: 0.14)
                            SpringKeyframe(0, duration: 0.3, spring: .bouncy)
                        }
                    }
                Text(items[index].title)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(selected ? color : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background {
                if selected {
                    Capsule()
                        .fill(color.opacity(0.15))
                        .matchedGeometryEffect(id: "pill", in: namespace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(items[index].title)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

private struct HopValues {
    var scaleX: CGFloat = 1
    var scaleY: CGFloat = 1
    var y: CGFloat = 0
}

#Preview {
    struct Demo: View {
        @State private var tab = 0
        var body: some View {
            BouncyTabBar(selection: $tab, items: [
                .init("house.fill", "Home"),
                .init("magnifyingglass", "Search"),
                .init("heart.fill", "Saved"),
                .init("person.fill", "Profile"),
            ])
            .padding()
        }
    }
    return Demo()
}
