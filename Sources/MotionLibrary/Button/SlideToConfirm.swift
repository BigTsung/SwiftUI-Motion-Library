import SwiftUI

/// A "slide to confirm" control: drag the knob all the way across to run the
/// action. Let go early and it springs back. The label fades as you slide and
/// the track fills behind the knob.
public struct SlideToConfirm: View {
    private let title: Text
    private let color: Color
    private let resetAfter: Double?
    private let action: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isConfirmed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let height: CGFloat = 56
    private let inset: CGFloat = 4

    /// - Parameters:
    ///   - title: The label inside the track.
    ///   - color: Knob and fill colour.
    ///   - resetAfter: Seconds after confirming before the control resets;
    ///     `nil` keeps it confirmed.
    ///   - action: Runs once the knob reaches the end.
    public init(_ title: LocalizedStringKey, color: Color = .accentColor, resetAfter: Double? = 1.5, action: @escaping () -> Void) {
        self.title = Text(title)
        self.color = color
        self.resetAfter = resetAfter
        self.action = action
    }

    /// A slider whose label is a string you already have, shown as is.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ title: S, color: Color = .accentColor, resetAfter: Double? = 1.5, action: @escaping () -> Void) {
        self.title = Text(title)
        self.color = color
        self.resetAfter = resetAfter
        self.action = action
    }

    public var body: some View {
        GeometryReader { geometry in
            let knob = height - inset * 2
            let maxOffset = max(0, geometry.size.width - knob - inset * 2)
            let progress = maxOffset > 0 ? offset / maxOffset : 0

            ZStack(alignment: .leading) {
                Capsule().fill(Color.secondary.opacity(0.15))

                title
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.leading, knob * 0.6)
                    .opacity(1 - progress * 1.6)

                // The fill grows with the knob.
                Capsule()
                    .fill(color.opacity(0.35))
                    .frame(width: offset + knob + inset * 2)

                Circle()
                    .fill(color)
                    .overlay {
                        Image(systemName: isConfirmed ? "checkmark" : "chevron.right.2")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .frame(width: knob, height: knob)
                    .shadow(color: color.opacity(0.4), radius: 6, y: 2)
                    .padding(inset)
                    .offset(x: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard !isConfirmed else { return }
                                offset = min(maxOffset, max(0, value.translation.width))
                            }
                            .onEnded { _ in
                                guard !isConfirmed else { return }
                                if offset > maxOffset * 0.85 {
                                    confirm(maxOffset)
                                } else {
                                    withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.45, bounce: 0.35)) {
                                        offset = 0
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: height)
        .haptic(.success, trigger: isConfirmed) { _, new in new }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { confirm(nil) }
    }

    private func confirm(_ maxOffset: CGFloat?) {
        withAnimation(.spring(duration: 0.3)) {
            if let maxOffset { offset = maxOffset }
            isConfirmed = true
        }
        action()
        guard let resetAfter else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(resetAfter))
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                offset = 0
                isConfirmed = false
            }
        }
    }
}

#Preview {
    SlideToConfirm("Slide to pay", color: .green) {}
        .frame(width: 280)
        .padding()
}
