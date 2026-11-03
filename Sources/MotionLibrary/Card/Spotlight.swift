import SwiftUI

/// A soft glow that follows the pointer (or a dragging finger) across the
/// view, like a torch shone on the card. Fades out when the pointer leaves.
struct SpotlightModifier: ViewModifier {
    var color: Color
    var radius: CGFloat

    @State private var location: CGPoint?
    @State private var lastLocation: CGPoint = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let size = geometry.size
                    let point = location ?? lastLocation
                    RadialGradient(
                        colors: [color, color.opacity(0)],
                        center: UnitPoint(x: size.width > 0 ? point.x / size.width : 0.5,
                                          y: size.height > 0 ? point.y / size.height : 0.5),
                        startRadius: 0,
                        endRadius: radius
                    )
                    .opacity(location == nil ? 0 : 1)
                }
                .mask { content }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .onContinuousHover(coordinateSpace: .local) { phase in
                switch phase {
                case let .active(point): move(to: point)
                case .ended: hide()
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { move(to: $0.location) }
                    .onEnded { _ in hide() }
            )
    }

    private func move(to point: CGPoint) {
        // Reduce Motion: no glide, the glow jumps with the pointer.
        withAnimation(reduceMotion ? nil : .interactiveSpring(response: 0.2, dampingFraction: 0.9)) {
            location = point
            lastLocation = point
        }
    }

    private func hide() {
        withAnimation(.easeOut(duration: 0.35)) { location = nil }
    }
}

public extension View {
    /// Shines a soft glow on the view where the pointer or finger is.
    ///
    /// ```swift
    /// FeatureCard()
    ///     .background(.black, in: RoundedRectangle(cornerRadius: 20))
    ///     .spotlight()
    /// ```
    ///
    /// - Parameters:
    ///   - color: Colour at the centre of the glow.
    ///   - radius: Radius of the glow, in points.
    func spotlight(color: Color = .white.opacity(0.35), radius: CGFloat = 120) -> some View {
        modifier(SpotlightModifier(color: color, radius: radius))
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color(white: 0.1))
        .frame(width: 260, height: 160)
        .overlay(Text("Hover me").font(.headline).foregroundStyle(.white))
        .spotlight()
        .padding()
}
