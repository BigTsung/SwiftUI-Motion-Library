import SwiftUI

/// Focus moves from word to word: the current word is sharp and framed by
/// corner brackets that glide to it, while the others are blurred.
public struct FocusText: View {
    private let words: [String]
    private let text: String
    private let interval: Double
    private let blur: CGFloat
    private let bracketColor: Color

    @State private var focus = 0
    @Namespace private var namespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - text: The sentence; it is split into words at spaces.
    ///   - interval: Seconds the focus stays on each word.
    ///   - blur: Blur radius of the unfocused words.
    ///   - bracketColor: Colour of the corner brackets.
    public init(_ text: String, interval: Double = 1.2, blur: CGFloat = 3, bracketColor: Color = .accentColor) {
        self.text = text
        self.words = text.split(separator: " ").map(String.init)
        self.interval = interval
        self.blur = blur
        self.bracketColor = bracketColor
    }

    public var body: some View {
        HStack(spacing: 10) {
            ForEach(words.indices, id: \.self) { index in
                let focused = index == focus
                Text(words[index])
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .blur(radius: focused ? 0 : blur)
                    .opacity(focused ? 1 : 0.55)
                    .background {
                        if focused {
                            FocusBrackets(color: bracketColor)
                                .matchedGeometryEffect(id: "focus", in: namespace)
                        }
                    }
            }
        }
        .task {
            guard words.count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { return }
                withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.8)) {
                    focus = (focus + 1) % words.count
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}

/// Four L-shaped corners.
private struct FocusBrackets: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let arm: CGFloat = min(8, size.width / 3, size.height / 3)
            var path = Path()
            for (x, y, dx, dy) in [(0.0, 0.0, 1.0, 1.0), (size.width, 0, -1, 1), (0, size.height, 1, -1), (size.width, size.height, -1, -1)] {
                path.move(to: CGPoint(x: x + dx * arm, y: y))
                path.addLine(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x, y: y + dy * arm))
            }
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
        .padding(-2)
        .allowsHitTesting(false)
    }
}

#Preview {
    FocusText("Motion made simple")
        .font(.title.bold())
        .padding()
}
