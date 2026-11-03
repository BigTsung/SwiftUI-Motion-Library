import SwiftUI
import MotionLibrary
import MotionShaders

// Demo views for the v0.4 effects. Same rule as Demos.swift: each must look
// good in a ~160x140 grid cell and in the large detail preview. Demos that
// need input also play by themselves, so the grid stays alive.

/// Repeats `action` every `seconds` while the view is on screen.
private struct Every: ViewModifier {
    let seconds: Double
    let action: @MainActor () -> Void

    func body(content: Content) -> some View {
        content.task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(seconds))
                guard !Task.isCancelled else { return }
                action()
            }
        }
    }
}

private extension View {
    func every(_ seconds: Double, _ action: @escaping @MainActor () -> Void) -> some View {
        modifier(Every(seconds: seconds, action: action))
    }
}

/// A dark rounded panel for effects that glow.
private struct DarkPanel<Content: View>: View {
    var color = Color(red: 0.05, green: 0.06, blue: 0.12)
    var width: CGFloat = 150
    var height: CGFloat = 110
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(width: width, height: height)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Text

struct MorphingTextDemo: View {
    var body: some View {
        MorphingText(["Design", "Build", "Ship"], interval: 1.8, morphDuration: 0.8)
            .font(.system(size: 30, weight: .black, design: .rounded))
    }
}

struct NeonDemo: View {
    var body: some View {
        DarkPanel(color: Color(red: 0.08, green: 0.03, blue: 0.1), height: 90) {
            Text("OPEN")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .neon(color: .pink)
        }
    }
}

struct KaraokeDemo: View {
    @State private var progress = 0.0

    var body: some View {
        KaraokeText("Sing it loud", progress: progress, highlight: .pink)
            .font(.title3.bold())
            .task {
                while !Task.isCancelled {
                    var reset = Transaction()
                    reset.disablesAnimations = true
                    withTransaction(reset) { progress = 0 }
                    try? await Task.sleep(for: .seconds(0.3))
                    withAnimation(.linear(duration: 2.2)) { progress = 1 }
                    try? await Task.sleep(for: .seconds(3))
                }
            }
    }
}

struct WeightWaveDemo: View {
    var body: some View {
        WeightWaveText("Variable")
            .font(.system(size: 30, design: .rounded))
    }
}

struct ExplodingTextDemo: View {
    @State private var exploded = false

    var body: some View {
        if #available(iOS 18, macOS 15, visionOS 2, *) {
            ExplodingText("Kaboom!", isExploded: exploded, distance: 45)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .contentShape(Rectangle())
                .onTapGesture { exploded.toggle() }
                .every(1.3) { exploded.toggle() }
        } else {
            Text("Requires iOS 18").foregroundStyle(.secondary)
        }
    }
}

// MARK: - Button

struct GooeyMenuDemo: View {
    var body: some View {
        GooeyMenu(symbols: ["camera.fill", "photo.fill", "mic.fill"], color: .indigo, distance: 54) { _ in }
    }
}

struct SlideToConfirmDemo: View {
    var body: some View {
        SlideToConfirm("Slide to pay", color: .green) {}
            .frame(width: 200)
    }
}

struct DownloadButtonDemo: View {
    @State private var progress: Double?

    var body: some View {
        DownloadButton(progress: progress) { start() }
            .every(4.2) { if progress == nil { start() } }
    }

    private func start() {
        Task {
            progress = 0
            while let p = progress, p < 1 {
                try? await Task.sleep(for: .milliseconds(50))
                progress = min(1, p + 0.04)
            }
            try? await Task.sleep(for: .seconds(1.2))
            progress = nil
        }
    }
}

struct StarRatingDemo: View {
    @State private var rating = 3
    @State private var step = 0
    private let sequence = [5, 2, 4, 1, 3]

    var body: some View {
        StarRating(rating: $rating, size: 22)
            .every(1.4) {
                step += 1
                rating = sequence[step % sequence.count]
            }
    }
}

struct BouncyTabBarDemo: View {
    @State private var tab = 0

    var body: some View {
        BouncyTabBar(selection: $tab, items: [
            .init("house.fill", "Home"),
            .init("heart.fill", "Saved"),
            .init("person.fill", "Me"),
        ])
        .frame(width: 210)
        .every(1.2) {
            withAnimation(.spring(duration: 0.4, bounce: 0.3)) { tab = (tab + 1) % 3 }
        }
    }
}

// MARK: - Card

struct ScratchCardDemo: View {
    @State private var round = 0

    var body: some View {
        VStack(spacing: 4) {
            Text("🎁").font(.system(size: 34))
            Text("You won!").font(.headline)
        }
        .frame(width: 150, height: 100)
        .background(Color.yellow.opacity(0.25))
        .scratchToReveal(LinearGradient(colors: [Color(white: 0.62), Color(white: 0.78)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 28) {
            Task {
                try? await Task.sleep(for: .seconds(1.4))
                round += 1
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .id(round)
    }
}

struct StackingCardsDemo: View {
    var body: some View {
        AutoScroller(rows: DemoTile.all.count, height: 140) {
            ForEach(Array(DemoTile.all.enumerated()), id: \.offset) { index, tile in
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tile.color.gradient)
                    .frame(height: 80)
                    .overlay(alignment: .topLeading) {
                        Image(systemName: tile.symbol).foregroundStyle(.white).padding(10)
                    }
                    .stackingCard(top: 8)
                    .id(index)
            }
        }
        .frame(width: 150)
    }
}

/// A scroll view that scrolls itself down and back up, for scroll demos.
/// Children must be tagged `.id(0)…id(rows - 1)`.
struct AutoScroller<Content: View>: View {
    let rows: Int
    let height: CGFloat
    var spacing: CGFloat = 10
    @ViewBuilder var content: Content

    @State private var position: Int? = 0

    var body: some View {
        ScrollView {
            VStack(spacing: spacing) {
                content
                Color.clear.frame(height: height)
            }
            .scrollTargetLayout()
            .padding(.horizontal, 4)
            .padding(.top, 8)
        }
        .scrollPosition(id: $position, anchor: .top)
        .scrollIndicators(.hidden)
        .frame(height: height)
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(0.8))
                withAnimation(.easeInOut(duration: 2.4)) { position = rows - 1 }
                try? await Task.sleep(for: .seconds(3))
                withAnimation(.easeInOut(duration: 1.2)) { position = 0 }
                try? await Task.sleep(for: .seconds(1.6))
            }
        }
    }
}

struct DeckShuffleDemo: View {
    @State private var shuffles = 0

    var body: some View {
        DeckShuffle(Array(DemoTile.all.prefix(5)), trigger: shuffles, spread: 46) { tile in
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(tile.color.gradient)
                .frame(width: 60, height: 84)
                .overlay(Image(systemName: tile.symbol).foregroundStyle(.white))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.white.opacity(0.6), lineWidth: 1.5))
        }
        .contentShape(Rectangle())
        .onTapGesture { shuffles += 1 }
        .every(1.6) { shuffles += 1 }
    }
}

struct LoopingCarouselDemo: View {
    var body: some View {
        LoopingCarousel(DemoTile.all, spacing: 8, peek: 22, autoplay: 1.4) { tile in
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tile.color.gradient)
                .frame(height: 90)
                .overlay(Image(systemName: tile.symbol).font(.title2).foregroundStyle(.white))
        }
        .frame(width: 200, height: 100)
    }
}

struct DragToDismissDemo: View {
    @State private var shown = true

    var body: some View {
        ZStack {
            if shown {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom))
                    .frame(width: 90, height: 112)
                    .overlay(Image(systemName: "hand.draw.fill").font(.title2).foregroundStyle(.white))
                    .dragToDismiss(isPresented: $shown, threshold: 70)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
            }
        }
        .frame(width: 150, height: 130)
        .onChange(of: shown) { _, new in
            guard !new else { return }
            Task {
                try? await Task.sleep(for: .seconds(0.6))
                withAnimation(.spring(duration: 0.5, bounce: 0.35)) { shown = true }
            }
        }
    }
}

struct ShrinkingHeaderDemo: View {
    var body: some View {
        AutoScroller(rows: 9, height: 140, spacing: 6) {
            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                .frame(height: 60)
                .overlay(Text("Inbox").font(.title2.bold()).foregroundStyle(.white))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shrinkingHeader(minScale: 0.6)
                .id(0)
            ForEach(1..<9, id: \.self) { index in
                DemoRow(index: index).id(index)
            }
        }
        .frame(width: 150)
    }
}

struct StretchyHeaderDemo: View {
    var body: some View {
        AutoScroller(rows: 9, height: 140, spacing: 0) {
            LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
                .frame(height: 70)
                .overlay(Image(systemName: "mountain.2.fill").font(.title).foregroundStyle(.white))
                .stretchyHeader(parallax: 0.6)
                .id(0)
            ForEach(1..<9, id: \.self) { index in
                DemoRow(index: index)
                    .padding(.top, 6)
                    .background(Color(white: 0.97))
                    .id(index)
            }
        }
        .frame(width: 150)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// A placeholder list row.
private struct DemoRow: View {
    let index: Int

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(DemoTile.all[index % DemoTile.all.count].color.gradient).frame(width: 22, height: 22)
            VStack(alignment: .leading, spacing: 3) {
                Capsule().fill(Color.secondary.opacity(0.4)).frame(width: 70, height: 6)
                Capsule().fill(Color.secondary.opacity(0.2)).frame(width: 50, height: 5)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .frame(height: 30)
    }
}

// MARK: - Shape

struct ReadingProgressDemo: View {
    @State private var position: Int? = 0

    var body: some View {
        ReadingProgressScrollView(color: .pink) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<14, id: \.self) { index in
                    Capsule()
                        .fill(Color.secondary.opacity(index.isMultiple(of: 4) ? 0.45 : 0.2))
                        .frame(width: index.isMultiple(of: 4) ? 90 : 130 - CGFloat(index % 3) * 20, height: index.isMultiple(of: 4) ? 9 : 6)
                        .id(index)
                }
            }
            .scrollTargetLayout()
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollPosition(id: $position, anchor: .top)
        .scrollIndicators(.hidden)
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(0.8))
                withAnimation(.easeInOut(duration: 2.4)) { position = 13 }
                try? await Task.sleep(for: .seconds(3))
                withAnimation(.easeInOut(duration: 1.2)) { position = 0 }
                try? await Task.sleep(for: .seconds(1.6))
            }
        }
        .frame(width: 150, height: 120)
        .background(Color.secondary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Number

struct SplitFlapDemo: View {
    @State private var index = 0
    private let words = ["12:45", "08:10", "GATE5"]

    var body: some View {
        SplitFlapText(words[index], size: 24)
            .onTapGesture { index = (index + 1) % words.count }
            .every(2.4) { index = (index + 1) % words.count }
    }
}

struct SlotMachineDemo: View {
    @State private var value = 777

    var body: some View {
        SlotMachineNumber(value: value, size: 30)
            .onTapGesture { value = Int.random(in: 0...999) }
            .every(2.6) { value = Int.random(in: 0...999) }
    }
}

struct PriceTickerDemo: View {
    @State private var price = 182.40

    var body: some View {
        PriceTicker(value: price)
            .font(.title3.bold())
            .every(1.1) { price = max(1, price + Double.random(in: -3...3)) }
    }
}

struct AnimatedChartDemo: View {
    @State private var values: [Double] = [3, 7, 4, 9, 6]

    var body: some View {
        HStack(spacing: 14) {
            GrowingBarChart(values: values, color: .blue)
                .frame(width: 70, height: 70)
            DrawingLineChart(values: values + [values[2] + 2], color: .pink)
                .frame(width: 80, height: 70)
        }
        .every(2.6) { values = values.map { _ in Double.random(in: 2...10) } }
    }
}

struct NeedleGaugeDemo: View {
    @State private var value = 0.35

    var body: some View {
        NeedleGauge(value: value)
            .frame(width: 120, height: 120)
            .onTapGesture { value = Double.random(in: 0...1) }
            .every(1.8) { value = Double.random(in: 0.05...0.95) }
    }
}

// MARK: - Background

struct LavaLampDemo: View {
    var body: some View {
        LavaLamp()
            .frame(width: 140, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct MatrixRainDemo: View {
    var body: some View {
        DarkPanel(color: .black, width: 160) { MatrixRain(fontSize: 12) }
    }
}

struct DotGridDemo: View {
    var body: some View {
        InteractiveDotGrid(spacing: 14, radius: 55)
            .frame(width: 160, height: 110)
            .background(Color.secondary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct MeteorsDemo: View {
    var body: some View {
        DarkPanel(color: Color(red: 0.03, green: 0.04, blue: 0.13), width: 160) { Meteors() }
    }
}

struct FlowFieldDemo: View {
    var body: some View {
        DarkPanel(color: Color(white: 0.06), width: 160) { FlowField(lines: 110) }
    }
}

// MARK: - Particle & 3D

struct PhysicsEmojiDemo: View {
    @State private var drops = 0

    var body: some View {
        PhysicsEmoji(trigger: drops, batch: 4, size: 24)
            .frame(width: 150, height: 120)
            .background(Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .contentShape(Rectangle())
            .onTapGesture { drops += 1 }
            .every(1.1) { drops += 1 }
    }
}

struct ShatterDemo: View {
    var body: some View {
        TransitionDemo(transition: .shatter, duration: 0.9)
    }
}

struct CubeDemo: View {
    @State private var page = 0

    var body: some View {
        ZStack {
            let tile = DemoTile.all[page % DemoTile.all.count]
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tile.color.gradient)
                .overlay(Image(systemName: tile.symbol).font(.largeTitle).foregroundStyle(.white))
                .id(page)
                .transition(.cube)
        }
        .frame(width: 110, height: 96)
        .every(1.6) { withAnimation(.easeInOut(duration: 0.7)) { page += 1 } }
    }
}

struct DotGlobeDemo: View {
    var body: some View {
        DarkPanel(color: Color(red: 0.03, green: 0.05, blue: 0.12), width: 140, height: 120) {
            DotGlobe(dots: 500).padding(6)
        }
    }
}

struct BubblesDemo: View {
    var body: some View {
        Bubbles(count: 14)
            .frame(width: 150, height: 110)
            .background(LinearGradient(colors: [.blue.opacity(0.55), .indigo], startPoint: .top, endPoint: .bottom))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct FirefliesDemo: View {
    var body: some View {
        DarkPanel(color: Color(red: 0.02, green: 0.07, blue: 0.06), width: 160) { Fireflies(count: 20) }
    }
}

// MARK: - Transition

struct CircularRevealDemo: View {
    @State private var dark = false
    @State private var origin = UnitPoint(x: 0.85, y: 0.2)
    @State private var step = 0
    private let origins: [UnitPoint] = [UnitPoint(x: 0.85, y: 0.2), UnitPoint(x: 0.2, y: 0.8), .center, UnitPoint(x: 0.15, y: 0.15)]

    var body: some View {
        GeometryReader { geometry in
            CircularReveal(value: dark, origin: origin) { isDark in
                ZStack {
                    isDark ? Color(white: 0.1) : Color(white: 0.95)
                    Image(systemName: isDark ? "moon.stars.fill" : "sun.max.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(isDark ? .yellow : .orange)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                origin = UnitPoint(x: location.x / geometry.size.width, y: location.y / geometry.size.height)
                dark.toggle()
            }
        }
        .frame(width: 140, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .every(1.6) {
            step += 1
            origin = origins[step % origins.count]
            dark.toggle()
        }
    }
}

struct LiquidSwipeDemo: View {
    @State private var page = 0

    var body: some View {
        ZStack {
            let tile = DemoTile.all[page % DemoTile.all.count]
            tile.color
                .overlay(Image(systemName: tile.symbol).font(.largeTitle).foregroundStyle(.white))
                .id(page)
                .transition(.liquidSwipe)
        }
        .frame(width: 120, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .every(1.7) { withAnimation(.easeInOut(duration: 0.9)) { page += 1 } }
    }
}

struct PageTurnDemo: View {
    @State private var page = 0

    var body: some View {
        ZStack {
            let tile = DemoTile.all[page % DemoTile.all.count]
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(tile.color.gradient)
                .overlay(Image(systemName: tile.symbol).font(.largeTitle).foregroundStyle(.white))
                .id(page)
                .transition(.pageTurn)
        }
        .frame(width: 96, height: 118)
        .every(1.7) { withAnimation(.easeInOut(duration: 0.9)) { page += 1 } }
    }
}

struct GlitchTransitionDemo: View {
    var body: some View {
        TransitionDemo(transition: .glitch, duration: 0.5)
    }
}

struct OrigamiDemo: View {
    var body: some View {
        TransitionDemo(transition: .origami, duration: 0.9)
    }
}

// MARK: - Shader

/// Shared artwork for the shader demos.
private struct ShaderCard: View {
    var colors: [Color] = [.cyan, .blue, .indigo]
    var symbol = "fish.fill"

    var body: some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(Image(systemName: symbol).font(.system(size: 40)).foregroundStyle(.white))
            .frame(width: 150, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct WaterRippleDemo: View {
    @State private var origin = CGPoint(x: 75, y: 55)
    @State private var ripples = 0
    @State private var step = 0
    private let points = [CGPoint(x: 75, y: 55), CGPoint(x: 40, y: 35), CGPoint(x: 110, y: 75)]

    var body: some View {
        ShaderCard()
            // A dotted texture so the distortion is easy to see.
            .overlay {
                Canvas { context, size in
                    for x in stride(from: 8.0, to: size.width, by: 12) {
                        for y in stride(from: 8.0, to: size.height, by: 12) {
                            context.fill(Path(ellipseIn: CGRect(x: x - 1.5, y: y - 1.5, width: 3, height: 3)), with: .color(.white.opacity(0.35)))
                        }
                    }
                }
                .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .waterRipple(at: origin, trigger: ripples, amplitude: 16)
            .onTapGesture { location in
                origin = location
                ripples += 1
            }
            .every(2.2) {
                step += 1
                origin = points[step % points.count]
                ripples += 1
            }
    }
}

struct PixellateDemo: View {
    @State private var blocky = false

    var body: some View {
        ShaderCard(colors: [.orange, .pink, .purple], symbol: "photo.artframe")
            .pixellate(blocky ? 14 : 1)
            .every(1.5) { withAnimation(.easeInOut(duration: 0.7)) { blocky.toggle() } }
    }
}

struct ChromaticDemo: View {
    @State private var amount = 1.5

    var body: some View {
        Text("RGB")
            .font(.system(size: 46, weight: .black, design: .rounded))
            .chromaticAberration(amount)
            .every(0.9) {
                // A beat: spike fast, then settle.
                withAnimation(.easeOut(duration: 0.12)) { amount = 7 } completion: {
                    withAnimation(.easeOut(duration: 0.5)) { amount = 1.5 }
                }
            }
    }
}

struct CRTDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("READY.").font(.system(size: 18, weight: .bold, design: .monospaced))
            Text("RUN_").font(.system(size: 14, design: .monospaced))
        }
        .foregroundStyle(.green)
        .frame(width: 150, height: 110)
        .background(Color(red: 0.02, green: 0.1, blue: 0.05))
        .crtScreen(curvature: 0.08)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct HeatHazeDemo: View {
    var body: some View {
        ShaderCard(colors: [.yellow, .orange, .brown], symbol: "sun.max.fill")
            .heatHaze(strength: 7)
    }
}

struct NoiseDissolveDemo: View {
    @State private var burnt = false

    var body: some View {
        ShaderCard(colors: [.indigo, .purple], symbol: "doc.text.fill")
            .noiseDissolve(burnt ? 1 : 0)
            .every(1.6) { withAnimation(.easeInOut(duration: 1.1)) { burnt.toggle() } }
    }
}
