import SwiftUI

/// A capsule button that fills with liquid while it is held and runs its
/// action only when the fill reaches the top. Letting go early drains it.
/// Good for destructive or irreversible actions.
public struct HoldToConfirmButton<Label: View>: View {
    private let duration: Double
    private let fillColor: Color
    private let action: () -> Void
    private let label: Label

    @State private var progress: CGFloat = 0
    @State private var isPressing = false
    @State private var isConfirmed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - duration: Seconds the user must hold.
    ///   - fillColor: Colour of the liquid. The resting background is a tint
    ///     of it and the label is drawn in it, turning white where submerged.
    ///   - action: Runs once the hold completes.
    ///   - label: The button's content.
    public init(
        duration: Double = 1.2,
        fillColor: Color = .red,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.duration = duration
        self.fillColor = fillColor
        self.action = action
        self.label = label()
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion || (!isPressing && progress == 0))) { timeline in
            let liquid = LiquidFill(
                progress: progress,
                phase: reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate * 6,
                waveHeight: progress > 0 && progress < 1 ? 4 : 0
            )
            // The label sizes the button; the capsule and liquid only decorate it.
            content
                .foregroundStyle(fillColor)
                .background(Capsule().fill(fillColor.opacity(0.15)))
                .overlay {
                    // The liquid, with the label redrawn in white where it's submerged.
                    ZStack {
                        liquid.fill(fillColor)
                        content.foregroundStyle(.white)
                    }
                    .mask(liquid)
                }
                .clipShape(Capsule())
        }
        .scaleEffect(isPressing ? 0.97 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressing)
        .contentShape(Capsule())
        .onLongPressGesture(minimumDuration: duration) {
            confirm()
        } onPressingChanged: { pressing in
            guard !isConfirmed else { return }
            isPressing = pressing
            if pressing {
                withAnimation(.linear(duration: duration * (1 - progress))) { progress = 1 }
            } else if progress < 1 {
                withAnimation(.easeOut(duration: 0.35)) { progress = 0 }
            }
        }
        .haptic(.success, trigger: isConfirmed) { _, confirmed in confirmed }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Press and hold to confirm")
        .accessibilityAction { action() }
    }

    /// The label (swapped for a checkmark once confirmed), padded to button size.
    private var content: some View {
        label
            .opacity(isConfirmed ? 0 : 1)
            .overlay {
                Image(systemName: "checkmark")
                    .fontWeight(.bold)
                    .scaleEffect(isConfirmed ? 1 : 0.3)
                    .opacity(isConfirmed ? 1 : 0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
    }

    private func confirm() {
        isPressing = false
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { isConfirmed = true }
        action()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.4)) {
                isConfirmed = false
                progress = 0
            }
        }
    }
}

public extension HoldToConfirmButton where Label == Text {
    /// A hold-to-confirm button with a text label.
    ///
    /// ```swift
    /// HoldToConfirmButton("Hold to delete") { deleteAccount() }
    /// ```
    init(
        _ title: LocalizedStringKey,
        duration: Double = 1.2,
        fillColor: Color = .red,
        action: @escaping () -> Void
    ) {
        self.init(duration: duration, fillColor: fillColor, action: action) {
            Text(title).font(.headline)
        }
    }
}

/// A rectangle filled from the bottom up to `progress`, with a sine wave on top.
private struct LiquidFill: Shape {
    var progress: CGFloat
    var phase: Double
    var waveHeight: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(progress, waveHeight) }
        set { progress = newValue.first; waveHeight = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        // Overfill slightly so the wave crests are hidden when full.
        let level = rect.maxY - (rect.height + waveHeight * 2) * progress
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        let steps = 24
        for step in 0...steps {
            let x = rect.minX + rect.width * CGFloat(step) / CGFloat(steps)
            let angle = Double(step) / Double(steps) * .pi * 3 + phase
            path.addLine(to: CGPoint(x: x, y: level + CGFloat(sin(angle)) * waveHeight))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    HoldToConfirmButton("Hold to delete") { }
        .padding()
}
