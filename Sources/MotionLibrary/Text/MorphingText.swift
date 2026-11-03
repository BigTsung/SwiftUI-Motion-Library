import SwiftUI

/// Cycles through words with a gooey morph: the outgoing word melts into the
/// incoming one. Both are blurred inside a `Canvas` and cut back to sharp
/// edges with an alpha threshold, so overlapping strokes fuse like liquid.
public struct MorphingText: View {
    private let words: [String]
    private let interval: Double
    private let morphDuration: Double
    private let color: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - words: The words to cycle through, in order.
    ///   - interval: Seconds each word stays, including the morph.
    ///   - morphDuration: Seconds the morph takes.
    ///   - color: Fill colour. The alpha threshold needs a solid colour.
    public init(_ words: [String], interval: Double = 2.2, morphDuration: Double = 0.9, color: Color = .primary) {
        self.words = words.isEmpty ? [""] : words
        self.interval = max(interval, morphDuration + 0.1)
        self.morphDuration = morphDuration
        self.color = color
    }

    public var body: some View {
        // Hidden copies of every word size the view to the widest one.
        ZStack {
            ForEach(words.indices, id: \.self) { index in
                Text(words[index]).hidden()
            }
        }
        .overlay {
            if reduceMotion {
                // Reduce Motion: a plain cross-fade.
                TimelineView(.periodic(from: .now, by: interval)) { timeline in
                    let index = wordIndex(at: timeline.date)
                    Text(words[index])
                        .foregroundStyle(color)
                        .id(index)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.4), value: index)
                }
            } else {
                TimelineView(.animation) { timeline in
                    morph(at: timeline.date)
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel(words.joined(separator: ", "))
    }

    private func wordIndex(at date: Date) -> Int {
        Int(date.timeIntervalSinceReferenceDate / interval) % words.count
    }

    @ViewBuilder
    private func morph(at date: Date) -> some View {
        let time = date.timeIntervalSinceReferenceDate
        let current = wordIndex(at: date)
        let next = (current + 1) % words.count
        let local = time.truncatingRemainder(dividingBy: interval)
        // 0 while the word rests, then 0 → 1 over the last `morphDuration`.
        let raw = (local - (interval - morphDuration)) / morphDuration
        let progress = min(1, max(0, raw))
        let eased = progress * progress * (3 - 2 * progress)

        if progress <= 0 {
            // At rest: crisp, plain text.
            Text(words[current]).foregroundStyle(color)
        } else {
            morphCanvas(current: current, next: next, eased: eased)
        }
    }

    private func morphCanvas(current: Int, next: Int, eased: Double) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.3, color: color))
            context.addFilter(.blur(radius: 1.5))
            context.drawLayer { layer in
                let centre = CGPoint(x: size.width / 2, y: size.height / 2)
                // Each word is blurred more the further it is from fully shown,
                // so mid-morph they overlap as soft blobs that the threshold fuses.
                // Both stay fully opaque through the middle so the blob never
                // thins out below the threshold and vanishes.
                if eased < 1, let outgoing = layer.resolveSymbol(id: current) {
                    var copy = layer
                    copy.addFilter(.blur(radius: 6 * eased))
                    copy.opacity = min(1, (1 - eased) * 2)
                    copy.draw(outgoing, at: centre)
                }
                if eased > 0, let incoming = layer.resolveSymbol(id: next) {
                    var copy = layer
                    copy.addFilter(.blur(radius: 6 * (1 - eased)))
                    copy.opacity = min(1, eased * 2)
                    copy.draw(incoming, at: centre)
                }
            }
        } symbols: {
            ForEach(words.indices, id: \.self) { index in
                Text(words[index]).tag(index)
            }
        }
        .padding(-12)
        .accessibilityHidden(true)
    }
}

#Preview {
    MorphingText(["Design", "Build", "Ship"])
        .font(.system(size: 44, weight: .black, design: .rounded))
        .padding()
}
