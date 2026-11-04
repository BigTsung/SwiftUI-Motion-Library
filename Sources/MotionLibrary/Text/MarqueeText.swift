import SwiftUI

/// A single line of text that scrolls sideways forever when it's too long to
/// fit, with faded edges. Short text just sits still.
public struct MarqueeText: View {
    private let text: String
    private let speed: Double
    private let gap: CGFloat
    private let fadeWidth: CGFloat

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - text: The string to show.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    ///   - gap: Space between the end of the text and its next repetition.
    ///   - fadeWidth: Width of the faded edges.
    public init(_ text: String, speed: Double = 1, gap: CGFloat = 40, fadeWidth: CGFloat = 16) {
        self.text = text
        self.speed = speed * 40
        self.gap = gap
        self.fadeWidth = fadeWidth
    }

    public var body: some View {
        let scrolls = textWidth > containerWidth && !reduceMotion
        // Reserve one line of height; the measured text lives in the overlay.
        Text(text)
            .lineLimit(1)
            .hidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .leading) {
                TimelineView(.animation(paused: !scrolls || speed == 0)) { timeline in
                    let cycle = textWidth + gap
                    let offset = scrolls
                        ? -CGFloat((timeline.date.timeIntervalSinceReferenceDate * speed)
                            .truncatingRemainder(dividingBy: Double(max(cycle, 1))))
                        : 0
                    HStack(spacing: gap) {
                        label
                        if scrolls { label }
                    }
                    .offset(x: offset)
                }
            }
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { containerWidth = proxy.size.width }
                        .onChange(of: proxy.size.width) { _, width in containerWidth = width }
                }
            }
            .clipped()
            .mask {
                if scrolls {
                    HStack(spacing: 0) {
                        LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                            .frame(width: fadeWidth)
                        Color.black
                        LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                            .frame(width: fadeWidth)
                    }
                } else {
                    Color.black
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(text)
    }

    private var label: some View {
        Text(text)
            .lineLimit(1)
            .fixedSize()
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { textWidth = proxy.size.width }
                        .onChange(of: proxy.size.width) { _, width in textWidth = width }
                }
            }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        MarqueeText("Now playing: Midnight City — M83 · Hurry Up, We're Dreaming")
            .font(.headline)
        MarqueeText("Short text stays put")
    }
    .frame(width: 240)
    .padding()
}
