import SwiftUI

/// A card with a tappable header that expands to reveal its detail. The
/// height springs open, the chevron turns, and the detail un-blurs into place.
/// Stack several for an accordion.
public struct ExpandableCard<Header: View, Detail: View>: View {
    @Binding private var isExpanded: Bool
    private let cornerRadius: CGFloat
    private let header: Header
    private let detail: Detail

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - isExpanded: Whether the detail is showing.
    ///   - cornerRadius: Corner radius of the card.
    ///   - header: Always visible; tapping it toggles the card.
    ///   - detail: Shown below the header when expanded.
    public init(
        isExpanded: Binding<Bool>,
        cornerRadius: CGFloat = 16,
        @ViewBuilder header: () -> Header,
        @ViewBuilder detail: () -> Detail
    ) {
        _isExpanded = isExpanded
        self.cornerRadius = cornerRadius
        self.header = header()
        self.detail = detail()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    header
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(isExpanded ? Text("Expanded") : Text("Collapsed"))

            if isExpanded {
                detail
                    .padding([.horizontal, .bottom])
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .opacity.combined(with: .offset(y: -8)).combined(with: BlurTransition.blur)
                    )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(isExpanded ? 0.12 : 0.06), radius: isExpanded ? 12 : 4, y: isExpanded ? 6 : 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// Blurs a view while it is inserted or removed.
private struct BlurTransition: ViewModifier {
    var radius: CGFloat

    func body(content: Content) -> some View {
        content.blur(radius: radius)
    }

    static var blur: AnyTransition {
        .modifier(active: BlurTransition(radius: 6), identity: BlurTransition(radius: 0))
    }
}

#Preview {
    struct Demo: View {
        @State private var open = [true, false, false]

        var body: some View {
            VStack(spacing: 12) {
                ForEach(0..<3) { index in
                    ExpandableCard(isExpanded: $open[index]) {
                        Text("Question \(index + 1)").font(.headline)
                    } detail: {
                        Text("Answers expand smoothly with a spring, and the detail fades and un-blurs into place.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
    }
    return Demo()
}
