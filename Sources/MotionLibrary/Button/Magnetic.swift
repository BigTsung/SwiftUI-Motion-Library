import SwiftUI

/// Pulls the view toward the pointer while it hovers nearby (iPad pointer,
/// Mac, visionOS), or toward the finger while it drags on touch screens, then
/// springs back to rest.
struct MagneticModifier: ViewModifier {
    var strength: CGFloat
    var radius: CGFloat

    @State private var offset: CGSize = .zero
    /// Size of the padded tracking area.
    @State private var areaSize: CGSize = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .offset(reduceMotion ? .zero : offset)
            // Grow the tracking area by `radius` so the pull starts before the
            // pointer reaches the view.
            .padding(radius)
            .contentShape(Rectangle())
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { areaSize = proxy.size }
                        .onChange(of: proxy.size) { _, newSize in areaSize = newSize }
                }
            }
            .onContinuousHover(coordinateSpace: .local) { phase in
                switch phase {
                case let .active(location):
                    attract(to: location)
                case .ended:
                    release()
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { attract(to: $0.location) }
                    .onEnded { _ in release() }
            )
            .padding(-radius)
    }

    private func attract(to location: CGPoint) {
        // `location` is in the padded tracking area, whose centre is the view's centre.
        let centre = CGPoint(x: areaSize.width / 2, y: areaSize.height / 2)
        withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.7)) {
            offset = CGSize(
                width: (location.x - centre.x) * strength,
                height: (location.y - centre.y) * strength
            )
        }
    }

    private func release() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.45)) {
            offset = .zero
        }
    }
}

public extension View {
    /// Makes the view drift toward a nearby pointer (or a dragging finger) and
    /// spring back when it leaves.
    ///
    /// ```swift
    /// Button("Get started") { }
    ///     .buttonStyle(.borderedProminent)
    ///     .magnetic()
    /// ```
    ///
    /// - Parameters:
    ///   - strength: Fraction of the pointer's distance from the centre that
    ///     the view moves (0…1).
    ///   - radius: How far outside the view, in points, the pull starts.
    func magnetic(strength: CGFloat = 0.3, radius: CGFloat = 60) -> some View {
        modifier(MagneticModifier(strength: strength, radius: radius))
    }
}

#Preview {
    Button("Get started") { }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .magnetic()
        .padding(80)
}
