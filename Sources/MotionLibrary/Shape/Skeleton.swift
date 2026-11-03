import SwiftUI

/// Swaps a view for a shimmering grey placeholder of the same layout while
/// it loads, then fades the real content in.
struct SkeletonModifier: ViewModifier {
    var isLoading: Bool

    func body(content: Content) -> some View {
        content
            .redacted(reason: isLoading ? .placeholder : [])
            // `.shimmer()` already pauses itself for Reduce Motion.
            .shimmer(isActive: isLoading)
            .allowsHitTesting(!isLoading)
            .animation(.easeInOut(duration: 0.3), value: isLoading)
            // Placeholder text is meaningless to VoiceOver.
            .accessibilityHidden(isLoading)
    }
}

public extension View {
    /// Shows a shimmering placeholder of the view's own layout while
    /// `isLoading` is true.
    ///
    /// ```swift
    /// ArticleRow(article)
    ///     .skeleton(isLoading: article.isPlaceholder)
    /// ```
    func skeleton(isLoading: Bool) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading))
    }
}

#Preview {
    struct Demo: View {
        @State private var loading = true
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill").font(.largeTitle)
                VStack(alignment: .leading) {
                    Text("Taylor Appleseed").font(.headline)
                    Text("Shipped a new build").font(.subheadline)
                }
            }
            .skeleton(isLoading: loading)
            .onTapGesture { loading.toggle() }
        }
    }
    return Demo().padding()
}
