import SwiftUI

/// The look of a `.highlighter()` stroke.
public enum HighlighterStyle: Sendable {
    /// A translucent marker band behind the lower part of the text.
    case marker
    /// A thick line under the text.
    case underline
}

/// A highlighter pen swipes across the text from left to right, and back off
/// again when deactivated.
struct HighlighterModifier: ViewModifier {
    var isActive: Bool
    var color: Color
    var style: HighlighterStyle
    var duration: Double

    @State private var drawn = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .background(alignment: .bottomLeading) {
                GeometryReader { geometry in
                    let size = geometry.size
                    let band: CGFloat = style == .marker ? size.height * 0.55 : max(3, size.height * 0.1)
                    RoundedRectangle(cornerRadius: style == .marker ? 3 : band / 2)
                        .fill(color.opacity(style == .marker ? 0.45 : 1))
                        .frame(width: size.width + 6, height: band)
                        // Slightly tilted, like a hand-drawn stroke.
                        .rotationEffect(.degrees(style == .marker ? -1.2 : 0))
                        .scaleEffect(x: drawn ? 1 : 0, anchor: .leading)
                        .offset(x: -3, y: size.height - band * (style == .marker ? 0.9 : 0.6))
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .onAppear { update(isActive) }
            .onChange(of: isActive) { _, newValue in update(newValue) }
    }

    private func update(_ active: Bool) {
        // Reduce Motion: fade in place of the swipe.
        withAnimation(reduceMotion ? nil : .easeOut(duration: duration)) {
            drawn = active
        }
    }
}

public extension View {
    /// Draws a highlighter stroke across the view while `isActive` is true.
    ///
    /// ```swift
    /// Text("the important part")
    ///     .highlighter()
    ///
    /// Text("Pricing")
    ///     .highlighter(isActive: isSelected, color: .pink, style: .underline)
    /// ```
    func highlighter(
        isActive: Bool = true,
        color: Color = .yellow,
        style: HighlighterStyle = .marker,
        duration: Double = 0.6
    ) -> some View {
        modifier(HighlighterModifier(isActive: isActive, color: color, style: style, duration: duration))
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Read the important part")
            .font(.title2.bold())
            .highlighter()
        Text("Underlined")
            .font(.title2.bold())
            .highlighter(color: .pink, style: .underline)
    }
    .padding()
}
