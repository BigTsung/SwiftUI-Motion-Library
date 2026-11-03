import SwiftUI

/// Material-style ripple that expands from the exact point the user tapped.
struct RippleModifier: ViewModifier {
    var color: Color
    var cornerRadius: CGFloat
    var duration: Double

    @State private var ripples: [Ripple] = []

    private struct Ripple: Identifiable {
        let id = UUID()
        let location: CGPoint
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let size = geometry.size
                    // Large enough to cover the view from any tap point.
                    let diameter = 2 * hypot(size.width, size.height)
                    ZStack {
                        ForEach(ripples) { ripple in
                            RippleCircle(color: color, diameter: diameter, duration: duration)
                                .position(ripple.location)
                        }
                    }
                    .frame(width: size.width, height: size.height)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .allowsHitTesting(false)
            }
            .simultaneousGesture(
                SpatialTapGesture().onEnded { value in
                    let ripple = Ripple(location: value.location)
                    ripples.append(ripple)
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
                        ripples.removeAll { $0.id == ripple.id }
                    }
                }
            )
    }
}

private struct RippleCircle: View {
    let color: Color
    let diameter: CGFloat
    let duration: Double

    @State private var expanded = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: diameter, height: diameter)
            .scaleEffect(expanded ? 1 : 0.01)
            .opacity(expanded ? 0 : 0.35)
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    expanded = true
                }
            }
    }
}

public extension View {
    /// Adds a ripple that starts at the tap location.
    ///
    /// ```swift
    /// Button("Tap") { }
    ///     .padding()
    ///     .background(.blue, in: RoundedRectangle(cornerRadius: 12))
    ///     .ripple(cornerRadius: 12)
    /// ```
    func ripple(
        color: Color = .white,
        cornerRadius: CGFloat = 12,
        duration: Double = 0.7
    ) -> some View {
        modifier(RippleModifier(color: color, cornerRadius: cornerRadius, duration: duration))
    }
}

#Preview {
    Text("Tap anywhere")
        .font(.headline)
        .foregroundStyle(.white)
        .frame(width: 240, height: 80)
        .background(Color.indigo, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .ripple(cornerRadius: 16)
        .padding()
}
