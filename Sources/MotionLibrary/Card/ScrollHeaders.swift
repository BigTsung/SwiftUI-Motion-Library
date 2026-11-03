import SwiftUI

// Headers that react to the scroll position, driven by `visualEffect` so
// they cost no extra layout passes. Apply them to the first view inside a
// vertical `ScrollView`.

// MARK: - Shrinking header

struct ShrinkingHeaderModifier: ViewModifier {
    var minScale: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let minScale = minScale, reduceMotion = reduceMotion
        return content
            .visualEffect { effect, proxy in
                let frame = proxy.frame(in: .scrollView)
                let scrolled = max(0, -frame.minY)
                // Shrinks over the distance it loses in height, then stays put.
                let range = max(1, frame.height * (1 - minScale))
                let progress = min(1, scrolled / range)
                // Scale first, then offset: the other way round the scale
                // would shrink the pinning offset too and the header would
                // drift off the top.
                return effect
                    .scaleEffect(reduceMotion ? 1 : 1 - (1 - minScale) * progress, anchor: .top)
                    .offset(y: scrolled)
            }
            // Stay above the content that scrolls underneath.
            .zIndex(1)
    }
}

// MARK: - Stretchy header

struct StretchyHeaderModifier: ViewModifier {
    var parallax: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let parallax = reduceMotion ? 0 : parallax
        return content.visualEffect { effect, proxy in
            let frame = proxy.frame(in: .scrollView)
            let pull = max(0, frame.minY)
            let height = max(1, frame.height)
            return effect
                // Pulled down: grow from the bottom so it fills the gap.
                .scaleEffect(1 + pull / height, anchor: .bottom)
                // Scrolled up: lag behind the content for a parallax feel.
                .offset(y: min(0, frame.minY) * -parallax)
        }
    }
}

public extension View {
    /// Pins the header to the top of its scroll view and shrinks it as the
    /// content scrolls up underneath.
    ///
    /// ```swift
    /// ScrollView {
    ///     VStack(spacing: 0) {
    ///         ProfileHeader().shrinkingHeader()
    ///         ForEach(posts) { PostRow($0) }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter minScale: The header's scale once fully collapsed.
    func shrinkingHeader(minScale: CGFloat = 0.6) -> some View {
        modifier(ShrinkingHeaderModifier(minScale: minScale))
    }

    /// Makes a header image stretch when the scroll view is pulled down past
    /// the top, and drift with a parallax when scrolled up.
    ///
    /// ```swift
    /// ScrollView {
    ///     Image("cover")
    ///         .resizable()
    ///         .scaledToFill()
    ///         .frame(height: 260)
    ///         .clipped()
    ///         .stretchyHeader()
    ///     ArticleBody()
    /// }
    /// ```
    ///
    /// - Parameter parallax: How much slower than the content it moves when
    ///   scrolled up (0 = none, 0.5 = half speed).
    func stretchyHeader(parallax: CGFloat = 0.5) -> some View {
        modifier(StretchyHeaderModifier(parallax: parallax))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
                .frame(height: 200)
                .overlay(Text("Stretch me").font(.title.bold()).foregroundStyle(.white))
                .stretchyHeader()
            ForEach(0..<20, id: \.self) { index in
                Text("Row \(index)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.background)
            }
        }
    }
}
