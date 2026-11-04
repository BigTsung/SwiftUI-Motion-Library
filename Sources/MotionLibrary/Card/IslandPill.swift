import SwiftUI

/// A black pill that springs open into a larger rounded card and back, like a
/// live activity growing out of the top of the screen. The compact and
/// expanded contents cross-fade with a blur while the shape morphs.
///
/// ```swift
/// IslandPill(isExpanded: showsPlayer) {
///     Image(systemName: "waveform")
/// } expanded: {
///     NowPlayingView()
/// }
/// ```
public struct IslandPill<Compact: View, Expanded: View>: View {
    private let isExpanded: Bool
    private let compactSize: CGSize
    private let expandedSize: CGSize
    private let color: Color
    private let compact: Compact
    private let expanded: Expanded

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - isExpanded: Shows the expanded content when true. Changes animate.
    ///   - compactSize: Size of the closed pill.
    ///   - expandedSize: Size of the open card.
    ///   - color: Fill of the pill.
    ///   - compact: Content of the closed pill.
    ///   - expanded: Content of the open card.
    public init(
        isExpanded: Bool,
        compactSize: CGSize = CGSize(width: 126, height: 37),
        expandedSize: CGSize = CGSize(width: 340, height: 160),
        color: Color = .black,
        @ViewBuilder compact: () -> Compact,
        @ViewBuilder expanded: () -> Expanded
    ) {
        self.isExpanded = isExpanded
        self.compactSize = compactSize
        self.expandedSize = expandedSize
        self.color = color
        self.compact = compact()
        self.expanded = expanded()
    }

    public var body: some View {
        let size = isExpanded ? expandedSize : compactSize
        let radius = isExpanded ? min(44, expandedSize.height / 2) : compactSize.height / 2
        ZStack {
            compact
                .opacity(isExpanded ? 0 : 1)
                .blur(radius: isExpanded && !reduceMotion ? 8 : 0)
                .scaleEffect(isExpanded && !reduceMotion ? 1.6 : 1)
            expanded
                .opacity(isExpanded ? 1 : 0)
                .blur(radius: isExpanded || reduceMotion ? 0 : 10)
                .scaleEffect(isExpanded || reduceMotion ? 1 : 0.6, anchor: .top)
        }
        .frame(width: size.width, height: size.height)
        .background(color, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .environment(\.colorScheme, .dark)
        .animation(reduceMotion ? .easeInOut(duration: 0.25) : .spring(duration: 0.5, bounce: 0.32), value: isExpanded)
    }
}

#Preview {
    struct Demo: View {
        @State private var open = false
        var body: some View {
            IslandPill(isExpanded: open) {
                HStack {
                    Image(systemName: "music.note")
                    Spacer()
                    Image(systemName: "waveform").foregroundStyle(.green)
                }
                .padding(.horizontal, 14)
                .foregroundStyle(.white)
            } expanded: {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 12).fill(.orange.gradient).frame(width: 64, height: 64)
                    VStack(alignment: .leading) {
                        Text("Now Playing").font(.headline)
                        Text("Motion Library").foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(20)
                .foregroundStyle(.white)
            }
            .onTapGesture { open.toggle() }
            .frame(height: 220, alignment: .top)
        }
    }
    return Demo()
}
