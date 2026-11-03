import SwiftUI

/// A split-flap display, like an airport departures board. When the text
/// changes, each character flips through a few intermediate characters
/// before landing, with the top flap folding down over the bottom half.
public struct SplitFlapText: View {
    private let text: String
    private let size: CGFloat
    private let tile: Color
    private let ink: Color

    /// - Parameters:
    ///   - text: The characters to show. Letters are shown in upper case.
    ///   - size: Font size of each character; tiles are sized from it.
    ///   - tile: Tile colour.
    ///   - ink: Character colour.
    public init(_ text: String, size: CGFloat = 36, tile: Color = Color(white: 0.13), ink: Color = .white) {
        self.text = text.uppercased()
        self.size = size
        self.tile = tile
        self.ink = ink
    }

    public var body: some View {
        let characters = Array(text)
        HStack(spacing: size * 0.08) {
            ForEach(characters.indices, id: \.self) { index in
                FlapCell(target: characters[index], size: size, tile: tile, ink: ink, delay: Double(index) * 0.05)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(text)
    }
}

/// The order a real board cycles through.
private let flapAlphabet = Array(" ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:.-/")

private struct FlapCell: View {
    let target: Character
    let size: CGFloat
    let tile: Color
    let ink: Color
    let delay: Double

    @State private var current: Character = " "
    @State private var next: Character = " "
    @State private var topAngle: Double = 0
    @State private var bottomAngle: Double = 90
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let flipTime = 0.07

    var body: some View {
        let width = size * 0.78, height = size * 1.3
        ZStack {
            half(next, top: true)
            half(current, top: false)
            // The flap: the old top folds down…
            half(current, top: true)
                .rotation3DEffect(.degrees(topAngle), axis: (1, 0, 0), anchor: .bottom, perspective: 0.5)
                .opacity(topAngle > -89 ? 1 : 0)
            // …revealing the new bottom as it lands.
            half(next, top: false)
                .rotation3DEffect(.degrees(bottomAngle), axis: (1, 0, 0), anchor: .top, perspective: 0.5)
                .opacity(bottomAngle < 89 ? 1 : 0)
        }
        .frame(width: width, height: height)
        .overlay {
            Rectangle().fill(Color.black.opacity(0.5)).frame(height: max(1, size * 0.03))
        }
        .task(id: target) { await flip(to: target) }
    }

    private func half(_ character: Character, top: Bool) -> some View {
        let width = size * 0.78, height = size * 1.3
        return Text(String(character))
            .font(.system(size: size, weight: .bold, design: .monospaced))
            .foregroundStyle(ink)
            .frame(width: width, height: height)
            .background(tile, in: RoundedRectangle(cornerRadius: size * 0.12))
            .frame(height: height / 2, alignment: top ? .top : .bottom)
            .clipped()
            .frame(height: height, alignment: top ? .top : .bottom)
    }

    /// Steps through up to six characters of the alphabet on the way to `target`.
    private func flip(to target: Character) async {
        guard target != current else { return }
        if reduceMotion {
            current = target
            next = target
            return
        }
        try? await Task.sleep(for: .seconds(delay))
        var steps: [Character] = []
        if let from = flapAlphabet.firstIndex(of: current), let to = flapAlphabet.firstIndex(of: target) {
            var index = from
            while index != to && steps.count < 40 {
                index = (index + 1) % flapAlphabet.count
                steps.append(flapAlphabet[index])
            }
        }
        if steps.isEmpty { steps = [target] }
        for step in steps.suffix(6) {
            guard !Task.isCancelled else { return }
            await flipOnce(to: step)
        }
    }

    private func flipOnce(to character: Character) async {
        next = character
        withAnimation(.easeIn(duration: flipTime)) { topAngle = -90 }
        try? await Task.sleep(for: .seconds(flipTime))
        withAnimation(.easeOut(duration: flipTime)) { bottomAngle = 0 }
        try? await Task.sleep(for: .seconds(flipTime))
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) {
            current = character
            topAngle = 0
            bottomAngle = 90
        }
    }
}

#Preview {
    struct Demo: View {
        @State private var index = 0
        let words = ["12:45", "BOARD", "08:10"]
        var body: some View {
            SplitFlapText(words[index])
                .onTapGesture { index = (index + 1) % words.count }
                .padding()
        }
    }
    return Demo()
}
