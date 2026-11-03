import SwiftUI

/// A line of text that fills with colour from left to right as `progress`
/// goes from 0 to 1, with a soft leading edge, like karaoke lyrics or a
/// reading progress highlight. Drive `progress` from playback time, a scroll
/// position or an animation.
public struct KaraokeText: View {
    private let string: String
    private let progress: Double
    private let highlight: Color
    private let base: Color
    private let feather: CGFloat

    /// - Parameters:
    ///   - string: The text. It's laid out on one line.
    ///   - progress: 0 = nothing filled, 1 = all filled. Animatable.
    ///   - highlight: The fill colour.
    ///   - base: The colour of the unfilled text.
    ///   - feather: Width of the soft edge, in points.
    public init(_ string: String, progress: Double, highlight: Color = .accentColor, base: Color = .secondary.opacity(0.5), feather: CGFloat = 14) {
        self.string = string
        self.progress = progress
        self.highlight = highlight
        self.base = base
        self.feather = feather
    }

    public var body: some View {
        Text(string)
            .lineLimit(1)
            .foregroundStyle(base)
            .overlay {
                Text(string)
                    .lineLimit(1)
                    .foregroundStyle(highlight)
                    .mask(alignment: .leading) {
                        GeometryReader { geometry in
                            let p = min(1, max(0, progress))
                            // The solid part grows from -feather so 0 shows nothing
                            // and 1 shows everything, edge included.
                            HStack(spacing: 0) {
                                Rectangle()
                                    .frame(width: max(0, (geometry.size.width + feather) * p - feather))
                                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                                    .frame(width: feather)
                            }
                        }
                    }
                    .accessibilityHidden(true)
            }
    }
}

#Preview {
    struct Demo: View {
        @State private var progress = 0.0
        var body: some View {
            KaraokeText("Never gonna stop the music", progress: progress, highlight: .pink)
                .font(.title2.bold())
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) { progress = 1 }
                }
                .padding()
        }
    }
    return Demo()
}
