import SwiftUI

/// The phases a `StatusButton` moves through.
public enum MotionButtonStatus: Equatable, Sendable {
    case idle
    case loading
    case success
    case failure
}

/// A capsule button that morphs to show the result of its action: it shrinks
/// into a spinning circle while loading, then turns green with a drawn
/// checkmark on success, or red with a shake on failure.
///
/// You own the status, so it works with any async work:
///
/// ```swift
/// @State private var status = MotionButtonStatus.idle
///
/// StatusButton("Pay now", status: status) {
///     status = .loading
///     Task {
///         status = await pay() ? .success : .failure
///         try? await Task.sleep(for: .seconds(1.5))
///         status = .idle
///     }
/// }
/// ```
public struct StatusButton: View {
    private let title: LocalizedStringKey
    private let status: MotionButtonStatus
    private let tint: Color
    private let action: () -> Void

    @State private var spin = false
    @State private var shakes = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let height: CGFloat = 50

    public init(
        _ title: LocalizedStringKey,
        status: MotionButtonStatus,
        tint: Color = .accentColor,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.status = status
        self.tint = tint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 28)
                    .opacity(status == .idle ? 1 : 0)
                    .scaleEffect(status == .idle ? 1 : 0.6)

                if status == .loading {
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 22, height: 22)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .onAppear {
                            spin = false
                            withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                                spin = true
                            }
                        }
                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                }

                CheckmarkShape()
                    .trim(from: 0, to: status == .success ? 1 : 0)
                    .stroke(.white, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 20, height: 16)
                    .animation(status == .success ? .easeOut(duration: 0.35).delay(0.15) : nil, value: status)

                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .scaleEffect(status == .failure ? 1 : 0.3)
                    .opacity(status == .failure ? 1 : 0)
            }
            .foregroundStyle(.white)
            .frame(width: status == .idle ? nil : height, height: height)
            .background(Capsule().fill(background))
            .contentShape(Capsule())
        }
        .buttonStyle(StatusPressStyle())
        .disabled(status != .idle)
        .modifier(StatusShake(shakes: CGFloat(shakes)))
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: status)
        .onChange(of: status) { _, newValue in
            if newValue == .failure, !reduceMotion {
                withAnimation(.linear(duration: 0.4)) { shakes += 1 }
            }
        }
        .haptic(trigger: status) { _, newValue in
            switch newValue {
            case .success: .success
            case .failure: .error
            default: nil
            }
        }
        .accessibilityLabel(Text(title))
        .accessibilityValue(accessibilityStatus)
    }

    private var background: Color {
        switch status {
        case .idle, .loading: tint
        case .success: .green
        case .failure: .red
        }
    }

    private var accessibilityStatus: Text {
        switch status {
        case .idle: Text("")
        case .loading: Text("Loading")
        case .success: Text("Done")
        case .failure: Text("Failed")
        }
    }
}

private struct StatusPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Horizontal shake, one full shake per unit of `shakes`.
private struct StatusShake: GeometryEffect {
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 8 * sin(shakes * .pi * 6), y: 0))
    }
}

/// A checkmark drawn left to right, sized to its frame.
struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

#Preview {
    struct Demo: View {
        @State private var status = MotionButtonStatus.idle

        var body: some View {
            StatusButton("Pay now", status: status) {
                status = .loading
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { status = .success }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { status = .idle }
            }
        }
    }
    return Demo()
}
