import SwiftUI
import MotionLibrary
import MotionShaders

// Demo views for the v0.5 effects. Same rule as Demos.swift: each must look
// good in a ~160x140 grid cell and in the large detail preview. Demos that
// need input also play by themselves where they can, so the grid stays alive.

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

/// A colourful little "photo" for the shader demos.
private struct SampleScene: View {
    var symbol = "sun.max.fill"
    var width: CGFloat = 150
    var height: CGFloat = 110

    var body: some View {
        LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(alignment: .bottom) {
                Ellipse().fill(Color.indigo.opacity(0.8)).frame(width: width * 1.4, height: height * 0.5).offset(y: height * 0.3)
            }
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: height * 0.38))
                    .foregroundStyle(.yellow)
                    .offset(y: -height * 0.08)
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Text

struct LiquidFillDemo: View {
    @State private var step = 1
    private let levels = [0.3, 0.5, 0.7, 0.4]

    var body: some View {
        let level = levels[step % levels.count]
        LiquidFillText("\(Int(level * 100))%", progress: level, color: .cyan)
            .font(.system(size: 52, weight: .black, design: .rounded))
            .contentTransition(.numericText())
            .every(1.8) { step += 1 }
    }
}

// MARK: - Button

struct PullCordDemo: View {
    @State private var on = false

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(on ? Color.yellow.opacity(0.18) : Color.secondary.opacity(0.08))
            HStack(alignment: .top, spacing: 18) {
                Image(systemName: on ? "lightbulb.max.fill" : "lightbulb")
                    .font(.system(size: 34))
                    .foregroundStyle(on ? .yellow : .secondary)
                    .padding(.top, 34)
                PullCord(isOn: $on, length: 44)
            }
        }
        .frame(width: 150, height: 120)
        .animation(.easeInOut(duration: 0.25), value: on)
    }
}

// MARK: - Card

struct IslandPillDemo: View {
    @State private var open = false

    var body: some View {
        IslandPill(isExpanded: open, compactSize: CGSize(width: 76, height: 24), expandedSize: CGSize(width: 150, height: 74)) {
            HStack {
                Image(systemName: "music.note")
                Spacer()
                Image(systemName: "waveform").foregroundStyle(.green)
            }
            .font(.caption2)
            .padding(.horizontal, 9)
            .foregroundStyle(.white)
        } expanded: {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8).fill(Color.orange.gradient).frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Now Playing").font(.caption.bold())
                    Text("Motion").font(.caption2).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .foregroundStyle(.white)
        }
        .onTapGesture { open.toggle() }
        .frame(width: 150, height: 110, alignment: .top)
        .padding(.top, 8)
        .every(1.8) { open.toggle() }
    }
}

struct HoverLiftDemo: View {
    /// Lifts each card in turn, so the grid shows the effect without a pointer.
    var autoplay = true
    @State private var active = 0

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill([Color.orange, .pink, .indigo][index].gradient)
                    .overlay(Image(systemName: ["paintbrush.fill", "camera.fill", "music.note"][index]).foregroundStyle(.white))
                    .frame(width: 40, height: 56)
                    .hoverLift(scale: 1.12, tilt: 10, isActive: autoplay && index == active)
            }
        }
        .frame(width: 160, height: 110)
        .every(1) { if autoplay { active = (active + 1) % 3 } }
    }
}

struct MarqueeWallDemo: View {
    private let colors: [Color] = [.orange, .pink, .purple, .blue, .teal, .green, .yellow, .red]
    private let symbols = ["star.fill", "heart.fill", "bolt.fill", "leaf.fill", "moon.fill", "flame.fill", "drop.fill", "cloud.fill"]

    var body: some View {
        MarqueeWall(count: 8, columns: 4, itemSize: CGSize(width: 40, height: 52), spacing: 7, speed: 0.67) { index in
            Rectangle().fill(colors[index].gradient)
                .overlay(Image(systemName: symbols[index]).font(.caption).foregroundStyle(.white.opacity(0.9)))
        }
        .frame(width: 150, height: 110)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct PhotoDevelopDemo: View {
    @State private var shots = 0

    var body: some View {
        VStack(spacing: 0) {
            SampleScene(width: 92, height: 80)
                .clipShape(Rectangle())
                .photoDevelop(trigger: shots, duration: 2.6)
            Color.white.frame(width: 92, height: 20)
        }
        .padding([.top, .horizontal], 6)
        .background(.white)
        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
        .rotationEffect(.degrees(-3))
        .every(4) { shots += 1 }
    }
}

// MARK: - Background

struct NetworkDemo: View {
    var body: some View {
        DarkPanel {
            NetworkBackground(count: 26, linkDistance: 46, color: .cyan)
        }
    }
}

struct TopographicDemo: View {
    var body: some View {
        DarkPanel(color: Color(red: 0.05, green: 0.08, blue: 0.07)) {
            TopographicLines(levels: 10, scale: 55, color: .mint, speed: 2)
        }
    }
}

struct DayNightSkyDemo: View {
    var body: some View {
        DayNightSky(cycle: 9)
            .frame(width: 150, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Number

struct ContributionGridDemo: View {
    @State private var seed = 1

    var body: some View {
        ContributionGrid(values: values, color: .green, cellSize: 8, spacing: 2)
            .every(2.6) { seed += 1 }
    }

    private var values: [Double] {
        (0..<(7 * 14)).map { index in
            let x = sin(Double(index * 7 + seed * 131) * 12.9898) * 43_758.5453
            let r = x - floor(x)
            return r < 0.3 ? 0 : r * 10
        }
    }
}

struct AnalogClockDemo: View {
    @State private var date = Calendar.current.date(bySettingHour: 10, minute: 8, second: 30, of: .now) ?? .now

    var body: some View {
        AnalogClock(date: date, accent: .orange)
            .frame(width: 96, height: 96)
            .every(1.6) { date.addTimeInterval(2 * 3600 + 25 * 60 + 13) }
    }
}

// MARK: - Particle & 3D

struct FlockDemo: View {
    var body: some View {
        DarkPanel(color: Color(red: 0.06, green: 0.1, blue: 0.2)) {
            Flock(count: 28, color: .white, speed: 0.6)
        }
    }
}

struct InkTrailDemo: View {
    var body: some View {
        DarkPanel(color: Color(red: 0.07, green: 0.05, blue: 0.1)) {
            Text("Drag here")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.35))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .inkTrail(color: .pink, size: 20)
        }
    }
}

struct RainOnGlassDemo: View {
    var body: some View {
        LinearGradient(colors: [Color(red: 0.12, green: 0.18, blue: 0.35), Color(red: 0.4, green: 0.22, blue: 0.4)], startPoint: .top, endPoint: .bottom)
            .overlay {
                // Blurry city lights behind the glass.
                HStack(spacing: 14) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle().fill([Color.orange, .yellow, .pink, .cyan, .orange][index]).frame(width: 14, height: 14)
                            .offset(y: CGFloat([10, -8, 18, 0, -12][index]))
                    }
                }
                .blur(radius: 6)
            }
            .overlay(RainOnGlass(drops: 6))
            .frame(width: 150, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct OrbitsDemo: View {
    var body: some View {
        DarkPanel {
            Orbits(colors: [.orange, .cyan, .pink])
                .padding(8)
        }
    }
}

// MARK: - Transition

struct InkBleedDemo: View {
    @State private var page = 0
    private let pages: [(Color, String)] = [(.indigo, "drop.fill"), (.teal, "leaf.fill"), (.pink, "heart.fill")]

    var body: some View {
        ZStack {
            ForEach(0..<pages.count, id: \.self) { index in
                if index == page {
                    Rectangle().fill(pages[index].0.gradient)
                        .overlay(Image(systemName: pages[index].1).font(.system(size: 34)).foregroundStyle(.white))
                        .transition(.asymmetric(insertion: AnyTransition(.inkBleed(origin: index.isMultiple(of: 2) ? .topLeading : .bottomTrailing)), removal: .opacity.animation(.easeOut(duration: 0.01).delay(1.1))))
                        .zIndex(Double(page))
                }
            }
        }
        .frame(width: 150, height: 110)
        .background(Color(white: 0.92))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .every(1.8) { withAnimation(.easeInOut(duration: 1.1)) { page = (page + 1) % pages.count } }
    }
}

struct ZoomBlurDemo: View {
    @State private var index = 0
    private let words = ["WARP", "ZOOM", "RUSH"]

    var body: some View {
        ZStack {
            Text(words[index])
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(.indigo)
                .id(index)
                .transition(.zoomBlur)
        }
        .frame(width: 150, height: 110)
        .every(1.5) { withAnimation(.easeOut(duration: 0.55)) { index = (index + 1) % words.count } }
    }
}

// MARK: - Shader

struct HalftoneDemo: View {
    @State private var big = false

    var body: some View {
        SampleScene()
            .halftone(dotSize: big ? 8 : 4.5)
            .every(2) { withAnimation(.easeInOut(duration: 1)) { big.toggle() } }
    }
}

struct DitherDemo: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            LinearGradient(colors: [Color(white: 0.15), Color(white: 0.55)], startPoint: .bottom, endPoint: .top)
                .overlay {
                    Circle()
                        .fill(RadialGradient(colors: [.white, Color(white: 0.45), .black], center: UnitPoint(x: 0.35, y: 0.3), startRadius: 2, endRadius: 46))
                        .frame(width: 64, height: 64)
                        .offset(x: CGFloat(sin(t * 1.3) * 28), y: CGFloat(-abs(sin(t * 2.6)) * 18 + 8))
                }
                .frame(width: 150, height: 110)
                .dither(pixelSize: 2.5)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct ThermalDemo: View {
    @State private var on = true

    var body: some View {
        ZStack {
            Color(white: 0.12)
            RadialGradient(colors: [.white, Color(white: 0.55), .clear], center: .center, startRadius: 4, endRadius: 46)
                .frame(width: 92, height: 92)
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color(white: 0.8))
        }
        .frame(width: 150, height: 110)
        .thermal(on ? 1 : 0)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .every(2) { withAnimation(.easeInOut(duration: 0.7)) { on.toggle() } }
    }
}

struct KaleidoscopeDemo: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom)
            // A ring of shapes all the way round, so every wedge finds something.
            ForEach(0..<10, id: \.self) { index in
                let angle = Double(index) / 10 * 2 * .pi
                let distance = 18 + Double(index % 3) * 16
                Circle()
                    .fill([Color.orange, .yellow, .mint, .pink, .cyan][index % 5])
                    .frame(width: CGFloat(10 + (index * 7) % 14))
                    .offset(x: cos(angle) * distance, y: sin(angle) * distance)
            }
        }
        .frame(width: 120, height: 120)
            .kaleidoscope(segments: 8)
            .clipShape(Circle())
    }
}

struct SwirlDemo: View {
    @State private var stirred = false

    var body: some View {
        SampleScene(symbol: "hurricane")
            .swirl(at: CGPoint(x: 75, y: 55), radius: 70, strength: stirred ? 4 : 0)
            .every(1.6) { withAnimation(.spring(duration: 1.1, bounce: 0.35)) { stirred.toggle() } }
    }
}

struct GlassLensDemo: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            VStack(alignment: .leading, spacing: 3) {
                ForEach(0..<7, id: \.self) { _ in
                    Text("Glass bends the light around it.").font(.system(size: 7))
                }
            }
            .frame(width: 150, height: 110)
            .background(.white)
            .glassLens(at: CGPoint(x: 75 + cos(t * 1.2) * 40, y: 55 + sin(t * 1.6) * 22), radius: 30, magnification: 2)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct DisintegrateDemo: View {
    @State private var gone = false

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.orange.gradient)
            .overlay(Image(systemName: "person.fill").font(.system(size: 40)).foregroundStyle(.white))
            .frame(width: 96, height: 96)
            .disintegrate(gone ? 1 : 0, wind: CGVector(dx: 70, dy: -36), grain: 1.5)
            .frame(width: 150, height: 110)
            .every(1.9) { withAnimation(gone ? .easeOut(duration: 0.9) : .easeIn(duration: 1.4)) { gone.toggle() } }
    }
}

struct GenieDemo: View {
    @State private var minimised = false

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.blue.gradient)
                .overlay(Image(systemName: "doc.text.fill").font(.title).foregroundStyle(.white))
                .frame(width: 110, height: 72)
                .genie(minimised ? 1 : 0, toward: 0.8)
                .frame(width: 110, height: 80, alignment: .top)
            Capsule().fill(.secondary.opacity(0.25)).frame(width: 120, height: 14)
        }
        .every(1.6) { withAnimation(.easeInOut(duration: 0.8)) { minimised.toggle() } }
    }
}

struct FlagWaveDemo: View {
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Capsule().fill(Color.gray).frame(width: 4, height: 104)
            LinearGradient(colors: [.indigo, .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay {
                    Text("MOTION")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
            .frame(width: 120, height: 70)
            .flagWave(amplitude: 6, wavelength: 70)
        }
    }
}

struct VoronoiDemo: View {
    var body: some View {
        VoronoiCells(cellSize: 34)
            .frame(width: 150, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
