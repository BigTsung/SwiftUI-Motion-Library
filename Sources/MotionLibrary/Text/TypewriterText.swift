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
    private let interval: Double
    private let showsCursor: Bool
    private let cursor: String

    @State private var visibleCount = 0
    @State private var cursorVisible = true

    /// - Parameters:
    ///   - text: The text to type out.
    ///   - interval: Seconds between characters.
    ///   - showsCursor: Shows a blinking cursor after the text.
    ///   - cursor: The cursor character.
    public init(
        _ text: String,
        interval: Double = 0.06,
        showsCursor: Bool = true,
        cursor: String = "|"
    ) {
        self.text = text
        self.interval = interval
        self.showsCursor = showsCursor
        self.cursor = cursor
    }

    @available(*, deprecated, message: "Pass interval in seconds as a Double, e.g. interval: 0.06")
    public init(
        _ text: String,
        interval: Duration,
        showsCursor: Bool = true,
        cursor: String = "|"
    ) {
        let parts = interval.components
        self.init(text, interval: Double(parts.seconds) + Double(parts.attoseconds) / 1e18, showsCursor: showsCursor, cursor: cursor)
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
                try? await Task.sleep(for: .seconds(interval))
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
