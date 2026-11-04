import SwiftUI

/// Lifts the view towards the pointer on hover (iPad trackpad or mouse, Mac):
/// it grows a little, rises, casts a deeper shadow and leans slightly
/// towards the pointer. On visionOS, where apps can't see the gaze, it uses
/// the system hover effect instead.
struct HoverLiftModifier: ViewModifier {
    var scale: CGFloat
    var tilt: Double
    var cornerRadius: CGFloat
    var isActive: Bool

    @State private var location: CGPoint?
    @State private var size: CGSize = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        #if os(visionOS)
        content
            .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .hoverEffect()
            .scaleEffect(isActive && !reduceMotion ? scale : 1)
            .animation(.spring(duration: 0.35, bounce: 0.3), value: isActive)
        #else
        let hovering = location != nil || isActive
        // -1…1 from the centre, for the lean.
        let lean = location.map { CGPoint(x: size.width > 0 ? $0.x / size.width * 2 - 1 : 0, y: size.height > 0 ? $0.y / size.height * 2 - 1 : 0) } ?? .zero
        let moves = !reduceMotion
        content
            .scaleEffect(hovering && moves ? scale : 1)
            .rotation3DEffect(.degrees(moves ? tilt * Double(lean.x) : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
            .rotation3DEffect(.degrees(moves ? -tilt * Double(lean.y) : 0), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
            .offset(y: hovering && moves ? -4 : 0)
            .shadow(color: .black.opacity(hovering ? 0.22 : 0.08), radius: hovering ? 18 : 6, y: hovering ? 12 : 3)
            .brightness(hovering && !moves ? 0.05 : 0)
            .animation(.spring(duration: 0.35, bounce: 0.3), value: hovering)
            .animation(.interactiveSpring(duration: 0.25), value: lean)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { size = proxy.size }
                        .onChange(of: proxy.size) { _, new in size = new }
                }
            }
            .onContinuousHover(coordinateSpace: .local) { phase in
                switch phase {
                case let .active(point): location = point
                case .ended: location = nil
                }
            }
        #endif
    }
}

public extension View {
    /// Lifts the view under the pointer: it scales up, rises, deepens its
    /// shadow and leans towards the pointer. For iPad pointers and the Mac;
    /// visionOS gets the system hover highlight.
    ///
    /// ```swift
    /// ProjectCard(project)
    ///     .hoverLift()
    /// ```
    ///
    /// - Parameters:
    ///   - scale: Scale while hovered.
    ///   - tilt: Maximum lean towards the pointer, in degrees.
    ///   - cornerRadius: Corner radius of the hover shape on visionOS.
    ///   - isActive: Also lifts the view while true, for example for the
    ///     focused or selected card (without the lean, which follows the pointer).
    func hoverLift(scale: CGFloat = 1.05, tilt: Double = 6, cornerRadius: CGFloat = 16, isActive: Bool = false) -> some View {
        modifier(HoverLiftModifier(scale: scale, tilt: tilt, cornerRadius: cornerRadius, isActive: isActive))
    }
}

#Preview {
    HStack(spacing: 20) {
        ForEach(0..<3) { index in
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill([Color.orange, .pink, .indigo][index].gradient)
                .frame(width: 90, height: 120)
                .hoverLift()
        }
    }
    .padding(40)
}
