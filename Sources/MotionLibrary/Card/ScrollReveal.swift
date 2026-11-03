import SwiftUI

public extension View {
    /// Items scale up and come into focus as they scroll into the visible
    /// area, and fade back out as they leave. Use inside a `ScrollView`.
    ///
    /// ```swift
    /// ScrollView {
    ///     LazyVStack {
    ///         ForEach(items) { item in
    ///             Row(item).scrollReveal()
    ///         }
    ///     }
    /// }
    /// ```
    func scrollReveal(
        axis: Axis = .vertical,
        minScale: CGFloat = 0.85,
        minOpacity: Double = 0.3,
        blur: CGFloat = 2
    ) -> some View {
        scrollTransition(.interactive, axis: axis) { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : minOpacity)
                .scaleEffect(phase.isIdentity ? 1 : minScale)
                .blur(radius: phase.isIdentity ? 0 : blur)
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack(spacing: 12) {
            ForEach(0..<30, id: \.self) { index in
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.accentColor.gradient)
                    .frame(height: 80)
                    .overlay(Text("Row \(index)").foregroundStyle(.white))
                    .scrollReveal()
            }
        }
        .padding()
    }
}
