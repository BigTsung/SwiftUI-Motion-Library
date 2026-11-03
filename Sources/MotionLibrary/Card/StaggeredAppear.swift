import SwiftUI

/// Items fade, rise and settle into place one after another when they first
/// appear.
struct StaggeredAppearModifier: ViewModifier {
    var index: Int
    var delayPerItem: Double
    var distance: CGFloat

    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : distance)
            .scaleEffect(visible ? 1 : 0.96)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * delayPerItem)) {
                    visible = true
                }
            }
    }
}

public extension View {
    /// Staggered entrance. Give each item in a list its position.
    ///
    /// ```swift
    /// ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
    ///     CardView(item)
    ///         .staggeredAppear(index: index)
    /// }
    /// ```
    func staggeredAppear(index: Int, delayPerItem: Double = 0.08, distance: CGFloat = 24) -> some View {
        modifier(StaggeredAppearModifier(index: index, delayPerItem: delayPerItem, distance: distance))
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(0..<5, id: \.self) { index in
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentColor.opacity(0.2 + Double(index) * 0.15))
                .frame(height: 56)
                .staggeredAppear(index: index)
        }
    }
    .padding()
}
