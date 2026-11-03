import SwiftUI

/// A collectible-card shine: the view tilts toward the pointer or finger, a
/// rainbow foil slides across it and a white glare follows the light source.
/// Springs back flat on release.
struct HolographicModifier: ViewModifier {
    var cornerRadius: CGFloat
    var maxAngle: Double

    /// Pointer position in -1…1 on both axes; nil when not touching.
    @State private var pointer: CGPoint?
    @State private var size: CGSize = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let p = pointer ?? .zero
        let active = pointer != nil
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .overlay {
                ZStack {
                    // Rainbow foil, shifted by the tilt.
                    LinearGradient(
                        colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .red],
                        startPoint: UnitPoint(x: -0.5 + p.x * 0.6, y: -0.5 + p.y * 0.3),
                        endPoint: UnitPoint(x: 1.5 + p.x * 0.6, y: 1.5 + p.y * 0.3)
                    )
                    .blendMode(.overlay)
                    .opacity(active ? 0.55 : 0.15)

                    // Glare where the light hits.
                    RadialGradient(
                        colors: [.white.opacity(0.7), .white.opacity(0)],
                        center: UnitPoint(x: 0.5 + p.x * 0.5, y: 0.5 + p.y * 0.5),
                        startRadius: 0,
                        endRadius: max(size.width, size.height) * 0.6
                    )
                    .blendMode(.softLight)
                    .opacity(active ? 1 : 0)
                }
                .clipShape(shape)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .onAppear { size = geometry.size }
                        .onChange(of: geometry.size) { _, newSize in size = newSize }
                }
            }
            // Reduce Motion: the foil and glare still react, but the card stays flat.
            .rotation3DEffect(.degrees(reduceMotion ? 0 : Double(p.y) * -maxAngle), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
            .rotation3DEffect(.degrees(reduceMotion ? 0 : Double(p.x) * maxAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
            .scaleEffect(active && !reduceMotion ? 1.03 : 1)
            .onContinuousHover(coordinateSpace: .local) { phase in
                switch phase {
                case let .active(location): track(location)
                case .ended: release()
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { track($0.location) }
                    .onEnded { _ in release() }
            )
    }

    private func track(_ location: CGPoint) {
        guard size.width > 0, size.height > 0 else { return }
        let x = min(1, max(-1, location.x / size.width * 2 - 1))
        let y = min(1, max(-1, location.y / size.height * 2 - 1))
        withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.8)) {
            pointer = CGPoint(x: x, y: y)
        }
    }

    private func release() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { pointer = nil }
    }
}

public extension View {
    /// Turns the view into a holographic trading card that tilts and shines
    /// under the pointer or finger.
    ///
    /// ```swift
    /// Image("card-art")
    ///     .resizable()
    ///     .aspectRatio(5 / 7, contentMode: .fit)
    ///     .clipShape(RoundedRectangle(cornerRadius: 16))
    ///     .holographic(cornerRadius: 16)
    /// ```
    ///
    /// - Parameters:
    ///   - cornerRadius: Match the view's own corner radius.
    ///   - maxAngle: Tilt at the edges, in degrees.
    func holographic(cornerRadius: CGFloat = 16, maxAngle: Double = 14) -> some View {
        modifier(HolographicModifier(cornerRadius: cornerRadius, maxAngle: maxAngle))
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom))
        .overlay(Image(systemName: "bolt.fill").font(.system(size: 50)).foregroundStyle(.yellow))
        .frame(width: 150, height: 210)
        .holographic()
        .padding(40)
}
