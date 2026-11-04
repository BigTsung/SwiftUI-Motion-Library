import SwiftUI

/// A two-sided card that turns over in 3D, showing `back` when `isFlipped`
/// is true. The faces swap exactly at 90°, so the back never shows mirrored.
public struct FlipCard<Front: View, Back: View>: View {
    private let isFlipped: Bool
    private let axis: Axis
    private let front: Front
    private let back: Back

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - isFlipped: Shows the back when true.
    ///   - axis: `.horizontal` turns like a page (around the vertical axis),
    ///     `.vertical` tumbles top over bottom.
    public init(
        isFlipped: Bool,
        axis: Axis = .horizontal,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self.isFlipped = isFlipped
        self.axis = axis
        self.front = front()
        self.back = back()
    }

    public var body: some View {
        if reduceMotion {
            // Cross-fade instead of turning.
            ZStack {
                front.opacity(isFlipped ? 0 : 1)
                back.opacity(isFlipped ? 1 : 0)
            }
            .animation(.easeInOut(duration: 0.3), value: isFlipped)
        } else {
            ZStack {
                front.modifier(FlipFace(angle: isFlipped ? 180 : 0, axis: axis, isBack: false))
                back.modifier(FlipFace(angle: isFlipped ? 180 : 0, axis: axis, isBack: true))
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.75), value: isFlipped)
        }
    }
}

/// Rotates one face by `angle` and hides it while it faces away.
private struct FlipFace: ViewModifier, Animatable {
    var angle: Double
    var axis: Axis
    var isBack: Bool

    nonisolated var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func body(content: Content) -> some View {
        // The back starts already turned 180° so it reads correctly when shown.
        let faceAngle = isBack ? angle - 180 : angle
        let visible = abs(faceAngle) < 90
        content
            .opacity(visible ? 1 : 0)
            .accessibilityHidden(!visible)
            .rotation3DEffect(
                .degrees(faceAngle),
                axis: axis == .horizontal ? (x: 0, y: 1, z: 0) : (x: 1, y: 0, z: 0),
                perspective: 0.5
            )
    }
}

#Preview {
    struct Demo: View {
        @State private var flipped = false

        var body: some View {
            FlipCard(isFlipped: flipped) {
                RoundedRectangle(cornerRadius: 20).fill(.blue.gradient)
                    .overlay(Text("Front").font(.title.bold()).foregroundStyle(.white))
            } back: {
                RoundedRectangle(cornerRadius: 20).fill(.orange.gradient)
                    .overlay(Text("Back").font(.title.bold()).foregroundStyle(.white))
            }
            .frame(width: 200, height: 260)
            .onTapGesture { flipped.toggle() }
        }
    }
    return Demo()
}
