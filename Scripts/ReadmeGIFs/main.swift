// Records a short animated GIF of every gallery demo for the README.
//
// Not part of the package. `Scripts/record-readme-gifs.sh` copies the sources
// into a temporary package, adds this file as an executable target, builds it
// and turns the captured frames into GIFs with ffmpeg.
//
// Usage: Recorder <frames-dir> [effect-id ...]

import AppKit
import SwiftUI
import MotionGallery
import MotionLibrary

// MARK: - Stage

/// Frames come from the window server, which composites everything the user
/// would see, including GPU work such as Metal shaders. Redrawing the view
/// with `cacheDisplay` (WINDOW_CAPTURE=0) skips shaders and can return stale
/// frames for some views. Either way the window is parked far off every
/// display, so nothing appears on screen.
let windowCapture = ProcessInfo.processInfo.environment["WINDOW_CAPTURE"] != "0"

let fps = 30.0
let defaultStage = CGSize(width: 360, height: 220)

/// A synthetic input step, in stage coordinates (origin top-left, points).
enum Step {
    case down(CGPoint)
    case up(CGPoint)
    case move(CGPoint)
    case click(CGPoint)
}

struct Recording {
    var duration: Double
    /// Appear effects are recorded from the moment the demo is mounted; every
    /// other demo gets time to settle first so the GIF doesn't start blank.
    var appear = false
    var stage: CGSize = defaultStage
    var steps: [(at: Double, step: Step)] = []
    /// Replaces the catalog demo when the effect needs to be driven in code
    /// (for example a programmatic scroll).
    var scene: (@MainActor () -> AnyView)?
}

private func center(_ stage: CGSize = defaultStage) -> CGPoint {
    CGPoint(x: stage.width / 2, y: stage.height / 2)
}

/// A straight drag from `from` to `to`, eased in and out.
private func linearDrag(start: Double, length: Double, from: CGPoint, to: CGPoint) -> [(at: Double, step: Step)] {
    var steps: [(at: Double, step: Step)] = [(start, .down(from))]
    let count = max(1, Int(length * fps))
    for i in 1...count {
        let t = Double(i) / Double(count)
        let eased = CGFloat(0.5 - 0.5 * cos(t * .pi))
        let p = CGPoint(x: from.x + (to.x - from.x) * eased, y: from.y + (to.y - from.y) * eased)
        steps.append((start + t * length, .move(p)))
    }
    steps.append((start + length + 0.02, .up(to)))
    return steps
}

/// A drag that circles around the stage centre, so the tilt goes in every direction.
private func circularDrag(start: Double, length: Double, radius: CGFloat) -> [(at: Double, step: Step)] {
    let c = center()
    var steps: [(at: Double, step: Step)] = [(start, .down(c))]
    let count = Int(length * fps)
    for i in 1...count {
        let t = Double(i) / Double(count)
        // Ease the radius in and out so the card starts and ends near flat.
        let r = radius * CGFloat(sin(t * .pi))
        let angle = t * 2 * .pi * 1.25
        let p = CGPoint(x: c.x + r * CGFloat(cos(angle)), y: c.y + r * CGFloat(sin(angle)))
        steps.append((start + t * length, .move(p)))
    }
    steps.append((start + length + 0.02, .up(steps.last!.step.point)))
    return steps
}

private extension Step {
    var point: CGPoint {
        switch self {
        case let .down(p), let .up(p), let .move(p), let .click(p): p
        }
    }
}

@MainActor
func recording(for id: String) -> Recording {
    let c = center()
    switch id {
    case "typewriter":
        return Recording(duration: 3.2, appear: true)
    case "scramble":
        return Recording(duration: 2.4, appear: true)
    case "shimmer":
        return Recording(duration: 3.0)
    case "pressable":
        return Recording(duration: 2.8, steps: [
            (0.5, .down(c)), (1.1, .up(c)),
            (1.6, .down(c)), (2.0, .up(c)),
        ])
    case "ripple":
        return Recording(duration: 2.8, steps: [
            (0.4, .click(CGPoint(x: c.x - 45, y: c.y - 12))),
            (1.1, .click(CGPoint(x: c.x + 50, y: c.y + 14))),
            (1.8, .click(c)),
        ])
    case "shake":
        return Recording(duration: 2.6, steps: [
            (0.4, .click(c)),
            (1.5, .click(c)),
        ])
    case "staggered-appear":
        return Recording(duration: 2.0, appear: true)
    case "tilt":
        return Recording(duration: 3.4, steps: circularDrag(start: 0.3, length: 2.4, radius: 110))
    case "scroll-reveal":
        let stage = CGSize(width: 360, height: 300)
        return Recording(duration: 4.6, stage: stage, scene: { AnyView(ScrollRevealScene()) })
    case "pulse-rings":
        return Recording(duration: 3.0)
    case "burst":
        // Like, unlike, like again.
        return Recording(duration: 2.8, steps: [
            (0.4, .click(c)),
            (1.4, .click(c)),
            (1.8, .click(c)),
        ])
    case "aurora":
        return Recording(duration: 4.0, scene: {
            AnyView(MotionCatalog.all.first { $0.id == "aurora" }!.demo().padding(20))
        })
    case "rolling-number":
        // The "+" and "−" buttons sit under the number.
        let plus = CGPoint(x: c.x + 22, y: c.y + 30)
        let minus = CGPoint(x: c.x - 22, y: c.y + 30)
        return Recording(duration: 3.2, steps: [
            (0.4, .click(plus)),
            (1.2, .click(plus)),
            (2.0, .click(minus)),
        ])

    // MARK: v0.2

    case "magnetic":
        return Recording(duration: 3.0, steps: circularDrag(start: 0.3, length: 2.2, radius: 70))
    case "hold-to-confirm":
        // A full hold (fills, confirms, resets), then an early release that drains.
        return Recording(duration: 4.4, steps: [
            (0.3, .down(c)), (1.8, .up(c)),
            (3.0, .down(c)), (3.6, .up(c)),
        ])
    case "status-button":
        // The demo alternates success and failure.
        return Recording(duration: 6.2, steps: [(0.3, .click(c)), (3.3, .click(c))])
    case "glow-border", "gradient-sweep", "wave-text", "float-3d":
        return Recording(duration: 3.0)
    case "blur-in":
        return Recording(duration: 2.4, appear: true)
    case "marquee":
        return Recording(duration: 4.0)
    case "flip-card":
        // Toggled in code: synthetic clicks are unreliable on onTapGesture.
        return Recording(duration: 3.0, scene: { AnyView(FlipScene()) })
    case "swipe-stack":
        let start = CGPoint(x: c.x, y: c.y - 8)
        return Recording(duration: 3.0, steps:
            linearDrag(start: 0.3, length: 0.45, from: start, to: CGPoint(x: start.x + 170, y: start.y + 20))
            + linearDrag(start: 1.6, length: 0.45, from: start, to: CGPoint(x: start.x - 170, y: start.y + 10))
        )
    case "parallax-carousel":
        return Recording(duration: 4.4, scene: {
            AnyView(SteppingScene(steps: [1, 2, 3, 1]) { selection in
                ParallaxCarousel(Swatch.all, selection: selection, cornerRadius: 16) { swatch in
                    swatch.gradient
                        .overlay(Image(systemName: swatch.symbol).font(.system(size: 40)).foregroundStyle(.white.opacity(0.9)))
                }
                .frame(width: 320, height: 160)
            })
        })
    case "expandable-card":
        // Collapsed, the header is at the centre; expanded, the card grows
        // around the centre and the header moves up.
        return Recording(duration: 3.4, steps: [
            (0.4, .click(c)),
            (2.2, .click(CGPoint(x: c.x, y: c.y - 30))),
        ])
    case "checkmark":
        // The demo checks itself on appear; then uncheck and check again.
        return Recording(duration: 4.0, appear: true, steps: [(2.0, .click(c)), (2.8, .click(c))])
    case "confetti":
        return Recording(duration: 3.6, steps: [(0.3, .click(c)), (1.5, .click(c))])
    case "loaders":
        return Recording(duration: 3.0, scene: {
            AnyView(HStack(spacing: 22) {
                ForEach(MotionLoader.Style.allCases, id: \.self) { style in
                    MotionLoader(style).frame(width: 40, height: 40)
                }
            })
        })
    case "morphing-blob":
        return Recording(duration: 4.0)
    case "particle-field", "starfield":
        return Recording(duration: 4.0, scene: {
            AnyView(MotionCatalog.all.first { $0.id == id }!.demo().padding(20))
        })
    case "cover-flow":
        return Recording(duration: 4.4, scene: {
            AnyView(SteppingScene(steps: [1, 2, 3, 4, 2]) { selection in
                CoverFlow(Swatch.all, selection: selection, itemWidth: 110) { swatch in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(swatch.gradient)
                        .frame(height: 110)
                        .overlay(Image(systemName: swatch.symbol).font(.largeTitle).foregroundStyle(.white))
                }
                .frame(height: 170)
            })
        })
    // MARK: v0.3

    case "count-up", "split-text":
        return Recording(duration: 2.2, appear: true)
    case "rotating-text", "focus-text":
        return Recording(duration: 3.6)
    case "glitch":
        return Recording(duration: 2.6)
    case "highlighter":
        return Recording(duration: 4.2)
    case "jelly":
        return Recording(duration: 2.4, steps: [(0.3, .click(c)), (1.3, .click(c))])
    case "click-spark":
        return Recording(duration: 2.4, steps: [
            (0.3, .click(CGPoint(x: c.x - 40, y: c.y - 15))),
            (0.9, .click(CGPoint(x: c.x + 45, y: c.y + 12))),
            (1.5, .click(c)),
        ])
    case "like-button":
        // Like, unlike, like again.
        return Recording(duration: 3.0, steps: [(0.3, .click(c)), (1.6, .click(c)), (2.0, .click(c))])
    case "liquid-toggle":
        // The switches sit at the right edge of a 140 pt column.
        let top = CGPoint(x: c.x + 44, y: c.y - 21)
        let bottom = CGPoint(x: c.x + 44, y: c.y + 21)
        return Recording(duration: 3.0, steps: [
            (0.3, .click(top)), (0.9, .click(bottom)), (1.7, .click(top)), (2.3, .click(bottom)),
        ])
    case "hero-expand":
        // Open the middle tile of the top row, then tap the detail to close it.
        return Recording(duration: 3.2, steps: [
            (0.3, .click(CGPoint(x: c.x, y: c.y - 23))),
            (1.8, .click(c)),
        ])
    case "spotlight-card", "flashlight", "holo-card":
        return Recording(duration: 3.0, steps: circularDrag(start: 0.2, length: 2.4, radius: 55))
    case "dock":
        let y = c.y + 12
        return Recording(duration: 3.6, steps:
            linearDrag(start: 0.2, length: 1.6, from: CGPoint(x: c.x - 80, y: y), to: CGPoint(x: c.x + 80, y: y))
            + linearDrag(start: 2.2, length: 1.0, from: CGPoint(x: c.x + 60, y: y), to: CGPoint(x: c.x - 20, y: y))
        )
    case "sliding-tabs":
        return Recording(duration: 3.0, steps: [
            (0.3, .click(CGPoint(x: c.x + 62, y: c.y - 25))),
            (1.2, .click(CGPoint(x: c.x - 62, y: c.y - 25))),
            (2.1, .click(CGPoint(x: c.x, y: c.y + 25))),
        ])
    case "fan-stack", "skeleton":
        return Recording(duration: 3.6)
    case "progress-ring", "draw-on":
        return Recording(duration: 4.0)
    case "iris", "blinds", "clock-wipe", "dissolve", "poof", "swoosh", "film-exposure":
        return Recording(duration: 3.4)
    case "fireworks", "snowfall", "warp-tunnel", "retro-grid", "waves", "grain", "mesh-gradient":
        return Recording(duration: 3.0, scene: {
            AnyView(MotionCatalog.all.first { $0.id == id }!.demo().scaleEffect(1.6))
        })
    // MARK: v0.4
    case "bouncy-tab-bar":
        // Click Saved, Me, then Home. (Known issue: this view stops refreshing
        // in the off-screen panel, so the GIF may come out frozen.)
        return Recording(duration: 3.0, steps: [
            (0.3, .click(c)),
            (1.2, .click(CGPoint(x: c.x + 66, y: c.y))),
            (2.1, .click(CGPoint(x: c.x - 66, y: c.y))),
        ])
    case "gooey-menu":
        // The main button sits at the bottom centre of a 168 × 120 pt menu.
        let button = CGPoint(x: c.x, y: c.y + 24)
        return Recording(duration: 3.0, steps: [(0.3, .click(button)), (1.9, .click(button))])
    case "slide-to-confirm":
        return Recording(duration: 3.4, steps:
            linearDrag(start: 0.3, length: 0.9, from: CGPoint(x: c.x - 72, y: c.y), to: CGPoint(x: c.x + 80, y: c.y)))
    case "download-button":
        return Recording(duration: 3.2, steps: [(0.3, .click(c))])
    case "scratch-card":
        var strokes: [(at: Double, step: Step)] = []
        for (index, y) in [-34.0, -18, -2, 14, 30].enumerated() {
            let left = index.isMultiple(of: 2)
            strokes += linearDrag(
                start: 0.2 + Double(index) * 0.32, length: 0.28,
                from: CGPoint(x: c.x + (left ? -68 : 68), y: c.y + y),
                to: CGPoint(x: c.x + (left ? 68 : -68), y: c.y + y + 6)
            )
        }
        return Recording(duration: 3.8, steps: strokes)
    case "drag-to-dismiss":
        return Recording(duration: 3.6, steps:
            linearDrag(start: 0.3, length: 0.3, from: c, to: CGPoint(x: c.x + 130, y: c.y + 30))
            + linearDrag(start: 2.0, length: 0.5, from: c, to: CGPoint(x: c.x - 40, y: c.y + 20)))
    case "dot-grid":
        return Recording(duration: 3.0, steps: circularDrag(start: 0.2, length: 2.6, radius: 45))
    case "animated-chart":
        return Recording(duration: 4.0, appear: true)
    case "morphing-text", "deck-shuffle", "split-flap", "cube", "page-turn", "liquid-swipe", "shatter", "origami", "noise-dissolve", "star-rating", "circular-reveal":
        return Recording(duration: 3.6)
    case "slot-machine", "stacking-cards", "shrinking-header", "stretchy-header", "reading-progress", "physics-emoji", "water-ripple":
        return Recording(duration: 4.0)
    case "pixellate", "needle-gauge":
        return Recording(duration: 3.2)
    default:
        return Recording(duration: 3.0)
    }
}

/// The gallery's flip card demo, flipped over and back on a timer.
struct FlipScene: View {
    @State private var flipped = false

    var body: some View {
        FlipCard(isFlipped: flipped) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.blue.gradient)
                .overlay(Image(systemName: "questionmark").font(.largeTitle.bold()).foregroundStyle(.white))
        } back: {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.orange.gradient)
                .overlay(Text("42").font(.largeTitle.bold()).foregroundStyle(.white))
        }
        .frame(width: 90, height: 120)
        .task {
            // 0.6 s settle time + 0.4 s into the recording, then back 1.4 s later.
            try? await Task.sleep(for: .seconds(1.0))
            flipped = true
            try? await Task.sleep(for: .seconds(1.4))
            flipped = false
        }
    }
}

/// Same artwork as the gallery's carousel demos.
struct Swatch: Identifiable {
    let id: Int
    let colors: [Color]
    let symbol: String

    static let all = [
        Swatch(id: 0, colors: [.orange, .pink], symbol: "sun.horizon.fill"),
        Swatch(id: 1, colors: [.teal, .blue], symbol: "water.waves"),
        Swatch(id: 2, colors: [.purple, .indigo], symbol: "moon.stars.fill"),
        Swatch(id: 3, colors: [.mint, .green], symbol: "leaf.fill"),
        Swatch(id: 4, colors: [.yellow, .orange], symbol: "bolt.fill"),
        Swatch(id: 5, colors: [.pink, .purple], symbol: "sparkles"),
    ]

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

/// Scrolls a carousel demo through `steps` (item ids), one every 0.8 s.
struct SteppingScene<Content: View>: View {
    let steps: [Int]
    @ViewBuilder let content: (Binding<Int?>) -> Content
    @State private var selection: Int? = 0

    var body: some View {
        content($selection)
            .task {
                // 0.6 s settle time + 0.3 s into the recording.
                try? await Task.sleep(for: .seconds(0.9))
                for step in steps {
                    withAnimation(.smooth(duration: 0.6)) { selection = step }
                    try? await Task.sleep(for: .seconds(0.8))
                }
            }
    }
}

/// Same content as the catalog demo, scrolled in code so the GIF shows rows
/// revealing on the way down and back up.
struct ScrollRevealScene: View {
    @State private var position: Int? = 0

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(0..<20, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.gradient)
                        .frame(height: 44)
                        .overlay(Text("Row \(index + 1)").font(.caption.bold()).foregroundStyle(.white))
                        .scrollReveal()
                        .id(index)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 12)
        }
        .scrollPosition(id: $position, anchor: .top)
        .scrollIndicators(.hidden)
        .frame(width: 240, height: 280)
        .task {
            // 0.6 s settle time + 0.4 s into the recording.
            try? await Task.sleep(for: .seconds(1.0))
            withAnimation(.easeInOut(duration: 1.8)) { position = 12 }
            try? await Task.sleep(for: .seconds(2.2))
            withAnimation(.easeInOut(duration: 1.6)) { position = 0 }
        }
    }
}

// MARK: - Window and capture

/// Far outside every display, so recording never covers or interrupts what
/// the user is doing.
let offscreenOrigin = CGPoint(x: -20_000, y: -20_000)

/// A non-activating panel: it can become key and receive the synthetic mouse
/// events without activating the app, so it doesn't steal focus from whatever
/// the user is doing.
final class StageWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

struct StageView: View {
    let size: CGSize
    let content: AnyView

    var body: some View {
        ZStack {
            Color(white: 0.97)
            content
        }
        .frame(width: size.width, height: size.height)
        .environment(\.colorScheme, .light)
        // Render controls as if the window were frontmost (prominent buttons
        // turn grey in inactive windows).
        .environment(\.controlActiveState, .key)
        .tint(.blue)
        .accentColor(.blue)
    }
}

typealias CGWindowListCreateImageFn = @convention(c) (CGRect, UInt32, UInt32, UInt32) -> Unmanaged<CGImage>?

/// `CGWindowListCreateImage` is unavailable to Swift in the macOS 15+ SDK but
/// still works for the caller's own windows without screen-recording permission.
let windowListCreateImage: CGWindowListCreateImageFn? = {
    guard let handle = dlopen("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics", RTLD_NOW),
          let symbol = dlsym(handle, "CGWindowListCreateImage") else { return nil }
    return unsafeBitCast(symbol, to: CGWindowListCreateImageFn.self)
}()

@MainActor
func captureWindow(_ window: NSWindow) -> CGImage? {
    let includingWindow: UInt32 = 1 << 3
    let boundsIgnoreFraming: UInt32 = 1 << 0
    let bestResolution: UInt32 = 1 << 3
    return windowListCreateImage?(.null, includingWindow, UInt32(window.windowNumber), boundsIgnoreFraming | bestResolution)?
        .takeRetainedValue()
}

/// Renders the hosting view's current (animated) state, independent of the
/// window's alpha, so the stage window can stay invisible.
@MainActor
func captureView(_ view: NSView) -> CGImage? {
    guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return nil }
    view.cacheDisplay(in: view.bounds, to: rep)
    return rep.cgImage
}

func writePNG(_ image: CGImage, to url: URL) {
    let rep = NSBitmapImageRep(cgImage: image)
    try? rep.representation(using: .png, properties: [:])?.write(to: url)
}

@MainActor
final class Recorder {
    let outDir: URL
    let ids: [String]
    let ioQueue = DispatchQueue(label: "png-writer")
    let ioGroup = DispatchGroup()
    /// One window for every recording: a freshly created window isn't always
    /// key in time, and then the first synthetic mouse-down is swallowed.
    let window: StageWindow
    let host: NSHostingView<StageView>

    init(outDir: URL, ids: [String]) {
        self.outDir = outDir
        self.ids = ids
        window = StageWindow(
            contentRect: CGRect(origin: offscreenOrigin, size: defaultStage),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.appearance = NSAppearance(named: .aqua)
        window.isReleasedWhenClosed = false
        window.hasShadow = false
        // Fully transparent: nothing ever appears on screen. Frames are read
        // from the hosting view (cacheDisplay), which still renders every
        // animation frame at alpha 0.
        window.alphaValue = windowCapture ? 1 : 0
        // Transparent windows let clicks through by default; the synthetic
        // taps and drags must still land.
        window.ignoresMouseEvents = false
        // The app is never active, so the panel must not hide on deactivation.
        window.hidesOnDeactivate = false
        // Stay above every other window: an occluded window stops rendering
        // animation frames, and the capture comes out frozen.
        window.level = .statusBar
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        host = NSHostingView(rootView: StageView(size: defaultStage, content: AnyView(EmptyView())))
        window.contentView = host
    }

    func run() async {
        for id in ids {
            guard let effect = MotionCatalog.all.first(where: { $0.id == id }) else {
                print("unknown effect id: \(id)")
                continue
            }
            await record(effect)
        }
        await withCheckedContinuation { done in
            ioGroup.notify(queue: .main) { done.resume() }
        }
        NSApp.terminate(nil)
    }

    func record(_ effect: MotionEffect) async {
        let plan = recording(for: effect.id)
        let dir = outDir.appendingPathComponent(effect.id)
        try? FileManager.default.removeItem(at: dir)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        // Synthetic events occasionally miss SwiftUI's tap and drag gestures
        // (AppKit also looks at the real mouse state), which leaves a frozen
        // recording. Detect that and try again.
        let maxAttempts = plan.steps.isEmpty ? 1 : 10
        var frames: [CGImage] = []
        for attempt in 1...maxAttempts {
            frames = await capture(effect, plan: plan)
            guard !plan.steps.isEmpty else { break }
            let changed = changedFrameCount(frames)
            if changed >= frames.count / 5 { break }
            if attempt == maxAttempts {
                print("WARNING: \(effect.id) looks frozen after \(maxAttempts) attempts; record it again")
                break
            }
            print("  \(effect.id): only \(changed)/\(frames.count) frames moved, retrying")
        }

        for (index, image) in frames.enumerated() {
            let url = dir.appendingPathComponent(String(format: "%04d.png", index))
            ioGroup.enter()
            ioQueue.async { [ioGroup] in
                writePNG(image, to: url)
                ioGroup.leave()
            }
        }
        print("recorded \(effect.id) (\(frames.count) frames)")
    }

    private func capture(_ effect: MotionEffect, plan: Recording) async -> [CGImage] {
        let size = plan.stage
        host.rootView = StageView(size: size, content: AnyView(EmptyView()))
        window.setContentSize(size)
        window.setFrameOrigin(offscreenOrigin)
        // Ordered in but never made key, so it can't take keyboard focus.
        window.orderFrontRegardless()
        try? await Task.sleep(for: .seconds(0.3))
        // Prime the window with a click on the empty stage.
        send(.click(CGPoint(x: 4, y: 4)), to: window, stageHeight: size.height)
        try? await Task.sleep(for: .seconds(0.2))

        // Mount the demo now so appear animations are captured from the start.
        host.rootView = StageView(size: size, content: plan.scene?() ?? effect.demo())
        if !plan.appear {
            try? await Task.sleep(for: .seconds(0.6))
        }

        var frames: [CGImage] = []
        var pending = plan.steps.sorted { $0.at < $1.at }
        let start = Date()
        let frameCount = Int(plan.duration * fps)
        for frame in 0..<frameCount {
            let target = start.addingTimeInterval(Double(frame) / fps)
            let wait = target.timeIntervalSinceNow
            if wait > 0 { try? await Task.sleep(for: .seconds(wait)) }

            let elapsed = -start.timeIntervalSinceNow
            while let next = pending.first, next.at <= elapsed {
                pending.removeFirst()
                send(next.step, to: window, stageHeight: size.height)
            }

            let windowImage = captureWindow(window)
            guard let image = windowCapture ? windowImage : captureView(host) else {
                print("capture failed for \(effect.id)")
                break
            }
            frames.append(image)
        }
        // Let a pending click's mouse-up land before the next recording.
        try? await Task.sleep(for: .seconds(0.2))
        return frames
    }

    /// Number of frames whose pixels differ from the first frame.
    private func changedFrameCount(_ frames: [CGImage]) -> Int {
        func bytes(_ image: CGImage) -> Data? {
            image.dataProvider?.data as Data?
        }
        guard let first = frames.first.flatMap(bytes) else { return 0 }
        return frames.dropFirst().filter { bytes($0) != first }.count
    }

    private var eventNumber = 0

    func send(_ step: Step, to window: NSWindow, stageHeight: CGFloat) {
        func event(_ type: NSEvent.EventType, _ p: CGPoint) -> NSEvent? {
            eventNumber += 1
            return NSEvent.mouseEvent(
                with: type,
                location: CGPoint(x: p.x, y: stageHeight - p.y),
                modifierFlags: [],
                timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: window.windowNumber,
                context: nil,
                eventNumber: eventNumber,
                clickCount: 1,
                pressure: type == .leftMouseUp ? 0 : 1
            )
        }
        // Post through the app's event queue (like real input) rather than
        // calling window.sendEvent directly.
        func post(_ event: NSEvent?) {
            if let event { NSApp.postEvent(event, atStart: false) }
        }
        switch step {
        case let .down(p): post(event(.leftMouseDown, p))
        case let .up(p): post(event(.leftMouseUp, p))
        case let .move(p): post(event(.leftMouseDragged, p))
        case let .click(p):
            post(event(.leftMouseDown, p))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                post(event(.leftMouseUp, p))
            }
        }
    }
}

// MARK: - Entry point

let arguments = CommandLine.arguments.dropFirst()
guard let outPath = arguments.first else {
    print("usage: Recorder <frames-dir> [effect-id ...]")
    exit(1)
}
let requested = Array(arguments.dropFirst())
// Scroll-driven effects can't be recorded here: programmatic scrolling in an
// off-screen macOS window jumps instead of animating. Their GIFs were recorded
// from the gallery demos in the iOS Simulator by Scripts/record-simulator-gifs.sh,
// so a full run here leaves them alone (name them explicitly to record them
// here anyway).
let simulatorRecorded: Set = ["stacking-cards", "shrinking-header", "stretchy-header", "reading-progress"]
let ids = requested.isEmpty ? MotionCatalog.all.map(\.id).filter { !simulatorRecorded.contains($0) } : requested

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
MainActor.assumeIsolated {
    let recorder = Recorder(outDir: URL(fileURLWithPath: outPath), ids: ids)
    Task { @MainActor in await recorder.run() }
}
app.run()
