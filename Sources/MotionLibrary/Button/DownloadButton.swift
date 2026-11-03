import SwiftUI

/// A button that morphs through a download: a labelled capsule shrinks into
/// a circle whose ring fills with progress, then pops into a checkmark.
public struct DownloadButton: View {
    private let title: String
    private let progress: Double?
    private let color: Color
    private let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Phase: Equatable { case idle, loading, done }

    /// - Parameters:
    ///   - title: The label shown before the download starts.
    ///   - progress: `nil` = not started, 0..<1 = downloading, 1 = finished.
    ///   - color: Tint of the button and the ring.
    ///   - action: Called when the idle button is tapped.
    public init(_ title: String = "Download", progress: Double?, color: Color = .accentColor, action: @escaping () -> Void) {
        self.title = title
        self.progress = progress
        self.color = color
        self.action = action
    }

    private var phase: Phase {
        guard let progress else { return .idle }
        return progress >= 1 ? .done : .loading
    }

    public var body: some View {
        let size: CGFloat = 44
        Button {
            if phase == .idle { action() }
        } label: {
            ZStack {
                Capsule()
                    .fill(phase == .loading ? Color.secondary.opacity(0.12) : (phase == .done ? Color.green : color))

                if phase == .loading {
                    Circle()
                        .trim(from: 0, to: progress ?? 0)
                        .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .padding(3)
                        .animation(.easeOut(duration: 0.2), value: progress)
                    Image(systemName: "stop.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(color)
                }

                if phase == .idle {
                    Label(title, systemImage: "arrow.down")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .fixedSize()
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }

                if phase == .done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .transition(.scale(scale: 0.2).combined(with: .opacity))
                }
            }
            .frame(width: phase == .idle ? 150 : size, height: size)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? .easeInOut(duration: 0.25) : .spring(duration: 0.5, bounce: 0.35), value: phase)
        .haptic(.success, trigger: phase) { _, new in new == .done }
        .accessibilityLabel(phase == .idle ? title : phase == .done ? "Downloaded" : "Downloading")
        .accessibilityValue(phase == .loading ? "\(Int((progress ?? 0) * 100)) percent" : "")
    }
}

#Preview {
    struct Demo: View {
        @State private var progress: Double?
        var body: some View {
            DownloadButton(progress: progress) {
                Task {
                    progress = 0
                    while let p = progress, p < 1 {
                        try? await Task.sleep(for: .milliseconds(60))
                        progress = min(1, p + 0.03)
                    }
                    try? await Task.sleep(for: .seconds(1.2))
                    progress = nil
                }
            }
            .padding()
        }
    }
    return Demo()
}
