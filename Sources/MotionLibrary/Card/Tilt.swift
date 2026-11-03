import SwiftUI

/// 3D card tilt that follows the finger, with a moving glare, then springs
/// back flat on release.
struct TiltModifier: ViewModifier {
    var maxAngle: Double
    var glare: Bool
    var cornerRadius: CGFloat

    /// Normalised drag, each axis in -1...1.
    @State private var tilt: CGSize = .zero
    @State private var isDragging = false

    /// Translation (in points) that maps to the maximum angle.
    private let range: CGFloat = 120

    func body(content: Content) -> some View {
        content
            .overlay {
                if glare {
                    LinearGradient(
                        colors: [.white.opacity(isDragging ? 0.35 : 0), .clear],
                        startPoint: UnitPoint(x: 0.5 - tilt.width * 0.5, y: 0.5 - tilt.height * 0.5),
                        endPoint: UnitPoint(x: 0.5 + tilt.width * 0.5, y: 0.5 + tilt.height * 0.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .allowsHitTesting(false)
                }
            }
            .rotation3DEffect(.degrees(Double(-tilt.height) * maxAngle), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(Double(tilt.width) * maxAngle), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(isDragging ? 1.03 : 1)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            isDragging = true
                            tilt = CGSize(
                                width: clamp(value.translation.width / range),
                                height: clamp(value.translation.height / range)
                            )
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
                            isDragging = false
                            tilt = .zero
                        }
                    }
            )
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        min(1, max(-1, value))
    }
}

public extension View {
    /// Tilts the view in 3D while it is dragged.
    ///
    /// ```swift
    /// CardView()
    ///     .tiltOnDrag(maxAngle: 15, cornerRadius: 20)
    /// ```
    func tiltOnDrag(maxAngle: Double = 12, glare: Bool = true, cornerRadius: CGFloat = 16) -> some View {
        modifier(TiltModifier(maxAngle: maxAngle, glare: glare, cornerRadius: cornerRadius))
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
        .frame(width: 220, height: 300)
        .tiltOnDrag(cornerRadius: 20)
        .padding(40)
}
