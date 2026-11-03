import SwiftUI

/// Darkens the view except for a soft circle of light around the pointer (or
/// a dragging finger), like exploring a dark room with a torch.
struct FlashlightModifier: ViewModifier {
    var radius: CGFloat
    var darkness: Double

    @State private var location: CGPoint?
    @State private var lastLocation: CGPoint?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let size = geometry.size
                    let point = location ?? lastLocation ?? CGPoint(x: size.width / 2, y: size.height / 2)
                    RadialGradient(
                        colors: [.black.opacity(0), .black.opacity(darkness)],
                        center: UnitPoint(x: size.width > 0 ? point.x / size.width : 0.5,
                                          y: size.height > 0 ? point.y / size.height : 0.5),
                        startRadius: radius * 0.55,
                        endRadius: radius
                    )
                    // Lights come back on when the pointer leaves.
                    .opacity(location == nil ? 0 : 1)
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .onContinuousHover(coordinateSpace: .local) { phase in
                switch phase {
                case let .active(point): move(to: point)
                case .ended: release()
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { move(to: $0.location) }
                    .onEnded { _ in release() }
            )
    }

    private func move(to point: CGPoint) {
        // Reduce Motion: the light jumps with the pointer instead of trailing it.
        withAnimation(reduceMotion ? nil : .interactiveSpring(response: 0.18, dampingFraction: 0.9)) {
            location = point
            lastLocation = point
        }
    }

    private func release() {
        withAnimation(.easeOut(duration: 0.4)) { location = nil }
    }
}

public extension View {
    /// Dims the view except around the pointer or finger.
    ///
    /// ```swift
    /// TreasureMap()
    ///     .flashlight(radius: 100)
    /// ```
    ///
    /// - Parameters:
    ///   - radius: Radius of the lit circle, in points.
    ///   - darkness: Opacity of the darkness outside the light (0…1).
    func flashlight(radius: CGFloat = 90, darkness: Double = 0.85) -> some View {
        modifier(FlashlightModifier(radius: radius, darkness: darkness))
    }
}

#Preview {
    LinearGradient(colors: [.yellow, .orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        .overlay(Text("Find me").font(.largeTitle.bold()))
        .frame(width: 300, height: 200)
        .flashlight()
}
