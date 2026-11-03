import SwiftUI
import MotionLibrary

// Demo views for the v0.3 effects. Same rule as Demos.swift: each must look
// good in a ~160x140 grid cell and in the large detail preview.

// MARK: - Shared artwork

/// Coloured tiles used by several card and transition demos.
struct DemoTile: Identifiable, Hashable {
    let id: Int
    let color: Color
    let symbol: String

    static let all = [
        DemoTile(id: 0, color: .pink, symbol: "heart.fill"),
        DemoTile(id: 1, color: .orange, symbol: "sun.max.fill"),
        DemoTile(id: 2, color: .teal, symbol: "leaf.fill"),
        DemoTile(id: 3, color: .indigo, symbol: "moon.stars.fill"),
        DemoTile(id: 4, color: .mint, symbol: "drop.fill"),
        DemoTile(id: 5, color: .purple, symbol: "sparkles"),
    ]
}

// MARK: - Text

struct CountUpDemo: View {
    @State private var value = 12_480.0

    var body: some View {
        VStack(spacing: 4) {
            CountUpText(value: value, prefix: "$")
                .font(.title.bold())
            Text("revenue")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture { value = value > 20_000 ? 12_480 : value + 9_250 }
    }
}

struct SplitTextDemo: View {
    var body: some View {
        if #available(iOS 18, macOS 15, visionOS 2, *) {
            SplitText("Hello, motion!")
                .font(.title2.bold())
        } else {
            Text("Requires iOS 18")
                .foregroundStyle(.secondary)
        }
    }
}

struct RotatingTextDemo: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("We")
            RotatingText(["design", "build", "ship"], interval: 1.4)
                .foregroundStyle(.blue)
        }
        .font(.title2.bold())
    }
}

struct GlitchDemo: View {
    var body: some View {
        Text("GLITCH")
            .font(.system(size: 30, weight: .black, design: .monospaced))
            .glitch(interval: 1.2)
    }
}

struct CircularTextDemo: View {
    var body: some View {
        ZStack {
            CircularText("SWIFTUI • MOTION • LIBRARY • ", radius: 44, speed: 30)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundStyle(.orange)
        }
    }
}

struct FocusTextDemo: View {
    var body: some View {
        FocusText("Motion made simple", interval: 1)
            .font(.headline)
    }
}

struct HighlighterDemo: View {
    @State private var on = true

    var body: some View {
        VStack(spacing: 10) {
            Text("the key idea")
                .font(.title3.bold())
                .highlighter(isActive: on)
            Text("underlined")
                .font(.title3.bold())
                .highlighter(isActive: on, color: .pink, style: .underline)
        }
        .contentShape(Rectangle())
        .onTapGesture { on.toggle() }
        .task {
            // Replays on a loop so the grid cell keeps showing the swipe.
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                on.toggle()
            }
        }
    }
}

// MARK: - Button

struct ShineDemo: View {
    var body: some View {
        Label("Go Premium", systemImage: "crown.fill")
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Capsule().fill(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)))
            .shine(every: 1.8)
    }
}

struct JellyDemo: View {
    @State private var taps = 0

    var body: some View {
        Button("Boing") { taps += 1 }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.purple)
            .jelly(trigger: taps)
    }
}

struct ClickSparkDemo: View {
    var body: some View {
        Text("Click anywhere")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 150, height: 80)
            .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .clickSpark(color: .yellow)
    }
}

struct LikeButtonDemo: View {
    @State private var liked = false

    var body: some View {
        LikeButton(isLiked: $liked, size: 34)
    }
}

struct AnimatedSymbolDemo: View {
    var body: some View {
        HStack(spacing: 18) {
            AnimatedSymbol("bell.fill", interval: 1.2)
                .foregroundStyle(.orange)
            AnimatedSymbol("heart.fill", style: .pulse)
                .foregroundStyle(.pink)
            AnimatedSymbol("wifi", style: .variableColor)
                .foregroundStyle(.blue)
        }
        .font(.title)
    }
}

struct LiquidToggleDemo: View {
    @State private var wifi = true
    @State private var dark = false

    var body: some View {
        VStack(spacing: 10) {
            Toggle("Wi-Fi", isOn: $wifi)
                .toggleStyle(.liquid)
            Toggle("Dark", isOn: $dark)
                .toggleStyle(.liquid(tint: .purple))
        }
        .font(.subheadline.weight(.medium))
        .frame(width: 140)
    }
}

// MARK: - Card & Group

struct HeroGridDemo: View {
    var body: some View {
        HeroGrid(Array(DemoTile.all.prefix(6)), columns: 3, spacing: 6, cornerRadius: 10) { tile in
            Rectangle().fill(tile.color.gradient)
                .frame(height: 40)
                .overlay(Image(systemName: tile.symbol).foregroundStyle(.white))
        } detail: { tile in
            Rectangle().fill(tile.color.gradient)
                .overlay(
                    VStack(spacing: 6) {
                        Image(systemName: tile.symbol).font(.largeTitle)
                        Text("Tap to close").font(.caption.bold())
                    }
                    .foregroundStyle(.white)
                )
        }
        .frame(width: 160, height: 92)
    }
}

struct SpotlightDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: "bolt.fill").foregroundStyle(.yellow)
            Text("Fast by default").font(.headline)
            Text("Move over me").font(.caption).foregroundStyle(.white.opacity(0.6))
        }
        .foregroundStyle(.white)
        .padding()
        .frame(width: 160, height: 100, alignment: .leading)
        .background(Color(white: 0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .spotlight()
    }
}

struct DockDemo: View {
    var body: some View {
        MagnifyingDock(Array(DemoTile.all.prefix(5)), size: 26, magnification: 1.7, range: 70, spacing: 5) { tile in
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(tile.color.gradient)
                .overlay(Image(systemName: tile.symbol).font(.caption).foregroundStyle(.white))
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct JiggleDemo: View {
    @State private var editing = true

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(38), spacing: 10), count: 3), spacing: 10) {
            ForEach(DemoTile.all) { tile in
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(tile.color.gradient)
                    .frame(width: 38, height: 38)
                    .overlay(Image(systemName: tile.symbol).font(.caption).foregroundStyle(.white))
                    .jiggle(isActive: editing)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { editing.toggle() }
    }
}

struct FanStackDemo: View {
    @State private var spread = false

    var body: some View {
        FanStack(Array(DemoTile.all.prefix(5)), isSpread: spread, angle: 9, spacing: 24) { tile in
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(tile.color.gradient)
                .frame(width: 44, height: 64)
                .overlay(Image(systemName: tile.symbol).font(.caption).foregroundStyle(.white))
                .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
        }
        .contentShape(Rectangle())
        .onTapGesture { spread.toggle() }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.6))
                spread.toggle()
            }
        }
    }
}

// MARK: - Shape

/// A looping signature-like scribble for the draw-on demo.
struct ScribbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: rect.minX, y: rect.midY + h * 0.2))
        path.addCurve(to: CGPoint(x: rect.minX + w * 0.3, y: rect.minY + h * 0.2),
                      control1: CGPoint(x: rect.minX + w * 0.1, y: rect.minY - h * 0.1),
                      control2: CGPoint(x: rect.minX + w * 0.2, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.minX + w * 0.45, y: rect.maxY - h * 0.1),
                      control1: CGPoint(x: rect.minX + w * 0.4, y: rect.minY + h * 0.5),
                      control2: CGPoint(x: rect.minX + w * 0.3, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.minX + w * 0.7, y: rect.minY + h * 0.3),
                      control1: CGPoint(x: rect.minX + w * 0.6, y: rect.maxY - h * 0.2),
                      control2: CGPoint(x: rect.minX + w * 0.55, y: rect.minY + h * 0.1))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                      control1: CGPoint(x: rect.minX + w * 0.85, y: rect.minY + h * 0.5),
                      control2: CGPoint(x: rect.minX + w * 0.9, y: rect.maxY))
        return path
    }
}

struct DrawOnDemo: View {
    @State private var drawn = true

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .drawOn(isDrawn: drawn, style: Color.green, lineWidth: 4, duration: 0.9)
                .frame(width: 44, height: 44)
            ScribbleShape()
                .drawOn(isDrawn: drawn, style: Color.blue, lineWidth: 3, duration: 1.4)
                .frame(width: 90, height: 50)
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(drawn ? 2.2 : 0.9))
                drawn.toggle()
            }
        }
    }
}

struct ProgressRingDemo: View {
    @State private var progress = 0.25

    var body: some View {
        ProgressRing(progress: progress, lineWidth: 10)
            .frame(width: 96, height: 96)
            .contentShape(Rectangle())
            .onTapGesture { progress = progress >= 0.9 ? 0.25 : progress + 0.25 }
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1.2))
                    progress = progress >= 0.9 ? 0.25 : progress + 0.25
                }
            }
    }
}

struct SkeletonDemo: View {
    @State private var loading = true

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 3) {
                Text("Taylor").font(.headline)
                Text("Shipped a build").font(.caption)
            }
        }
        .skeleton(isLoading: loading)
        .contentShape(Rectangle())
        .onTapGesture { loading.toggle() }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(loading ? 2 : 1.4))
                loading.toggle()
            }
        }
    }
}

struct SlidingTabsDemo: View {
    @State private var range = "Week"

    var body: some View {
        VStack(spacing: 12) {
            SlidingTabs(["Day", "Week", "Month"], selection: $range)
            SlidingTabs(["Day", "Week", "Month"], selection: $range, indicator: .underline)
        }
        .controlSize(.small)
    }
}

// MARK: - Background

struct MeshGradientDemo: View {
    var body: some View {
        if #available(iOS 18, macOS 15, visionOS 2, *) {
            AnimatedMeshGradient(speed: 2)
                .frame(width: 160, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            Text("Requires iOS 18")
                .foregroundStyle(.secondary)
        }
    }
}

struct RetroGridDemo: View {
    var body: some View {
        RetroGrid(color: .pink, spacing: 24, speed: 1)
            .background(
                LinearGradient(colors: [Color(red: 0.1, green: 0.02, blue: 0.2), Color(red: 0.25, green: 0.05, blue: 0.3)], startPoint: .top, endPoint: .bottom)
            )
            .overlay(alignment: .top) {
                Circle()
                    .fill(LinearGradient(colors: [.yellow, .pink], startPoint: .top, endPoint: .bottom))
                    .frame(width: 44, height: 44)
                    .padding(.top, 12)
            }
            .frame(width: 160, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct BorderBeamDemo: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("PRO").font(.caption.bold()).foregroundStyle(.orange)
            Text("$9 / mo").font(.title3.bold())
        }
        .foregroundStyle(.white)
        .frame(width: 150, height: 90)
        .background(Color(white: 0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .borderBeam(cornerRadius: 16, duration: 2.5)
    }
}

struct WavesDemo: View {
    var body: some View {
        WaveBackground(amplitude: 8, speed: 1.4)
            .background(Color.cyan.opacity(0.08))
            .frame(width: 160, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct GrainDemo: View {
    var body: some View {
        LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            .grain(opacity: 0.45)
            .overlay(Text("Grain").font(.title2.bold()).foregroundStyle(.white))
            .frame(width: 160, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct FlashlightDemo: View {
    var body: some View {
        LinearGradient(colors: [.yellow, .orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "key.fill").font(.title)
                    Text("Find the key").font(.caption.bold())
                }
                .foregroundStyle(.white)
            )
            .frame(width: 160, height: 110)
            .flashlight(radius: 55)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Particle & 3D

struct FireworksDemo: View {
    var body: some View {
        Fireworks(interval: 0.7, sparks: 28)
            .background(Color(red: 0.03, green: 0.03, blue: 0.1))
            .frame(width: 160, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct SnowfallDemo: View {
    var body: some View {
        HStack(spacing: 0) {
            Snowfall(count: 40)
                .background(Color(red: 0.12, green: 0.18, blue: 0.35))
            Snowfall(.rain, count: 50)
                .background(Color(white: 0.18))
        }
        .frame(width: 160, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct FloatingReactionsDemo: View {
    @State private var count = 0

    var body: some View {
        Button {
            count += 1
        } label: {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Color.pink))
        }
        .buttonStyle(.plain)
        .floatingReactions(trigger: count, height: 90)
        .padding(.top, 70)
        .task {
            // Sends a few reactions by itself so the grid cell is alive.
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(0.7))
                count += 1
            }
        }
    }
}

struct WarpTunnelDemo: View {
    var body: some View {
        WarpTunnel(rings: 14, sides: 6)
            .background(.black)
            .frame(width: 160, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct HolographicDemo: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom))
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "bolt.fill").font(.title).foregroundStyle(.yellow)
                    Text("RARE").font(.caption2.bold()).foregroundStyle(.white)
                }
            )
            .frame(width: 80, height: 112)
            .holographic(cornerRadius: 12)
    }
}

// MARK: - Transition

/// Shows and hides a tile on a loop with the given transition.
struct TransitionDemo<T: Transition>: View {
    let transition: T
    var duration: Double = 0.8

    @State private var shown = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            if shown {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(Image(systemName: "photo.fill").font(.largeTitle).foregroundStyle(.white))
                    .transition(transition)
            }
        }
        .frame(width: 120, height: 96)
        .contentShape(Rectangle())
        .onTapGesture { toggle() }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(duration + 0.7))
                toggle()
            }
        }
    }

    private func toggle() {
        withAnimation(.easeInOut(duration: duration)) { shown.toggle() }
    }
}
