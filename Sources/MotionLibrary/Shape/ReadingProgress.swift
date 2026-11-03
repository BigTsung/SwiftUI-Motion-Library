import SwiftUI

/// A vertical scroll view with a reading-progress bar along its top edge
/// that fills as you scroll from the top to the bottom of the content.
public struct ReadingProgressScrollView<Content: View>: View {
    private let color: Color
    private let height: CGFloat
    private let content: Content

    /// - Parameters:
    ///   - color: Bar colour.
    ///   - height: Bar thickness, in points.
    ///   - content: The scrolling content.
    public init(color: Color = .accentColor, height: CGFloat = 4, @ViewBuilder content: () -> Content) {
        self.color = color
        self.height = height
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            content.overlay(alignment: .top) { bar }
        }
    }

    /// The bar lives inside the scrolled content and is pinned and sized by
    /// `visualEffect`, so it needs no state, no preferences (they don't reach
    /// out of an iOS scroll view reliably) and no extra layout passes.
    private var bar: some View {
        Color.clear
            .overlay(alignment: .topLeading) {
                Capsule()
                    .fill(color)
                    .frame(height: height)
                    .shadow(color: color.opacity(0.5), radius: 4)
            }
            .visualEffect { effect, proxy in
                let frame = proxy.frame(in: .scrollView)
                let viewport = proxy.bounds(of: .scrollView)?.size ?? frame.size
                let scrollable = max(1, frame.height - viewport.height)
                let progress = min(1, max(0, -frame.minY / scrollable))
                return effect
                    // Span the scroll view's width, filled to `progress`.
                    .scaleEffect(x: viewport.width * progress / max(1, frame.width), y: 1, anchor: .topLeading)
                    // Stay pinned to the top of the visible area.
                    .offset(x: -frame.minX, y: -frame.minY)
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

#Preview {
    ReadingProgressScrollView(color: .pink) {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(0..<30, id: \.self) { index in
                Text("Paragraph \(index + 1). Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
            }
        }
        .padding()
    }
}
