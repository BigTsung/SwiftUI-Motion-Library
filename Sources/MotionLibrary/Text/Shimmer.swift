import SwiftUI

/// A band of light that sweeps across the view, clipped to the view's own
/// shape. Works on text, images, and skeleton placeholders.
struct ShimmerModifier: ViewModifier {
    var isActive: Bool
    var duration: Double
    var bandWidth: CGFloat
    var highlight: Color

    @State private var animating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let band = max(1, width * bandWidth)
                        LinearGradient(
                            colors: [.clear, highlight, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: band, height: geometry.size.height)
                        .offset(x: animating ? width : -band)
                    }
                    .mask { content }
                    .allowsHitTesting(false)
                    .onAppear {
                        animating = false
                        // Reduce Motion: no sweep; the band stays parked off-screen.
                        guard !reduceMotion else { return }
                        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                            animating = true
                        }
                    }
                }
            }
    }
}

public extension View {
    /// Sweeps a highlight across the view.
    ///
    /// ```swift
    /// Text("Loading…").font(.title).shimmer()
    /// RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.3)).shimmer()
    /// ```
    func shimmer(
        isActive: Bool = true,
        duration: Double = 1.6,
        bandWidth: CGFloat = 0.35,
        highlight: Color = .white.opacity(0.8)
    ) -> some View {
        modifier(ShimmerModifier(
            isActive: isActive,
            duration: duration,
            bandWidth: bandWidth,
            highlight: highlight
        ))
    }
}

#Preview {
    VStack(spacing: 16) {
        Text("Shimmering title")
            .font(.largeTitle.bold())
            .foregroundStyle(.gray)
            .shimmer()
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.25))
            .frame(height: 60)
            .shimmer()
    }
    .padding()
}
