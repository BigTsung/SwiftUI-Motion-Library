import SwiftUI

/// Reveals a string one character at a time with an optional blinking cursor.
///
/// ```swift
/// TypewriterText("Hello, SwiftUI!")
///     .font(.title.bold())
/// ```
///
/// The animation restarts whenever `text` changes.
public struct TypewriterText: View {
    private let text: String
    private let interval: Duration
    private let showsCursor: Bool
    private let cursor: String

    @State private var visibleCount = 0
    @State private var cursorVisible = true

    public init(
        _ text: String,
        interval: Duration = .milliseconds(60),
        showsCursor: Bool = true,
        cursor: String = "|"
    ) {
        self.text = text
        self.interval = interval
        self.showsCursor = showsCursor
        self.cursor = cursor
    }

    public var body: some View {
        (
            Text(String(text.prefix(visibleCount)))
            + Text(showsCursor ? cursor : "")
                .foregroundStyle(cursorVisible ? Color.accentColor : Color.clear)
        )
        .accessibilityLabel(text)
        .task(id: text) {
            visibleCount = 0
            guard !text.isEmpty else { return }
            for index in 1...text.count {
                try? await Task.sleep(for: interval)
                if Task.isCancelled { return }
                visibleCount = index
            }
        }
        .task {
            guard showsCursor else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(500))
                cursorVisible.toggle()
            }
        }
    }
}

#Preview {
    TypewriterText("Turning complex data into meaningful visuals.")
        .font(.title2.weight(.semibold))
        .padding()
}
