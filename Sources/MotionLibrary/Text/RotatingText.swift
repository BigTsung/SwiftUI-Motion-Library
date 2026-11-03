import SwiftUI

/// Cycles through a list of words: the current word slides up and out while
/// the next one rises in, and the width springs to fit.
public struct RotatingText: View {
    private let words: [String]
    private let interval: Double

    @State private var index = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - words: The words to cycle through.
    ///   - interval: Seconds each word stays on screen.
    public init(_ words: [String], interval: Double = 2) {
        self.words = words
        self.interval = interval
    }

    public var body: some View {
        ZStack {
            if !words.isEmpty {
                Text(words[index % words.count])
                    .id(index)
                    .transition(reduceMotion ? .opacity : .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .fixedSize()
        .clipped()
        .task {
            guard words.count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    index = (index + 1) % words.count
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(words.joined(separator: ", "))
    }
}

#Preview {
    HStack(spacing: 6) {
        Text("We")
        RotatingText(["design", "build", "ship"])
            .foregroundStyle(.blue)
        Text("apps.")
    }
    .font(.title.bold())
    .padding()
}
