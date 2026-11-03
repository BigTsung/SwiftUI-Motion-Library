import SwiftUI
import MotionLibrary

/// Every effect in the library, in display order.
///
/// To add an effect: implement it in `Sources/MotionLibrary/<Component>/`,
/// add a demo view in `Demos.swift`, then append an entry here.
/// See CONTRIBUTING.md for the checklist.
public enum MotionCatalog {
    public static let all: [MotionEffect] = text + button + card + shape + background + number

    public static func filtered(component: MotionComponent?, trigger: MotionTrigger?, search: String = "") -> [MotionEffect] {
        let query = search.trimmingCharacters(in: .whitespaces).lowercased()
        return all.filter { effect in
            (component == nil || effect.component == component)
            && (trigger == nil || effect.triggers.contains(trigger!))
            && (query.isEmpty
                || effect.name.lowercased().contains(query)
                || effect.summary.lowercased().contains(query))
        }
    }

    // MARK: - Text

    static let text: [MotionEffect] = [
        MotionEffect(
            id: "typewriter",
            name: "Typewriter",
            summary: "Characters appear one by one with a blinking cursor.",
            component: .text,
            triggers: [.appear, .change],
            sourceFile: "Text/TypewriterText.swift",
            usage: #"""
            TypewriterText("Hello, SwiftUI!", interval: .milliseconds(60))
                .font(.title.bold())
            """#,
            prompt: #"""
            Create a SwiftUI "typewriter" text view (iOS 17+). It reveals a string one character at a time at a fixed interval (default 60 ms), followed by a cursor character "|" in the accent color that blinks every 0.5 s. Implementation: keep a @State visibleCount, render Text(String(text.prefix(visibleCount))) concatenated with the cursor Text, and drive it from .task(id: text) with Task.sleep so it restarts when the text changes and cancels when the view disappears. Use the full text as the accessibility label.
            """#
        ) { TypewriterDemo() },

        MotionEffect(
            id: "scramble",
            name: "Scramble / Decode",
            summary: "Random glyphs resolve into the real text from left to right.",
            component: .text,
            triggers: [.appear, .change],
            sourceFile: "Text/ScrambleText.swift",
            usage: #"""
            ScrambleText("ACCESS GRANTED", duration: 1.0)
                .font(.title.bold())
            """#,
            prompt: #"""
            Create a SwiftUI "decode" text effect (iOS 17+). On appear, every character of the string is shown as a random glyph from a charset (A–Z, 0–9, #%&*), re-randomised every 30 ms. Over the given duration, characters lock into their real values from left to right until the full string is shown. Spaces never scramble. Use a monospaced font design so the width doesn't jitter, drive frames from .task(id: text) with Task.sleep, and set the real string as the accessibility label.
            """#
        ) { ScrambleDemo() },

        MotionEffect(
            id: "shimmer",
            name: "Shimmer",
            summary: "A band of light sweeps across text or skeleton placeholders.",
            component: .text,
            triggers: [.loop],
            sourceFile: "Text/Shimmer.swift",
            usage: #"""
            Text("Loading…")
                .font(.title)
                .shimmer()

            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.3))
                .frame(height: 44)
                .shimmer(duration: 1.2)
            """#,
            prompt: #"""
            Create a reusable SwiftUI .shimmer() view modifier (iOS 17+). A soft white highlight band (a horizontal LinearGradient clear → white 80% → clear, about 35% of the view width) moves from just off the left edge to just off the right edge, repeating forever with linear timing (~1.6 s). The band is placed in an overlay with a GeometryReader and masked by the original content so it only lights up the view's own pixels (text glyphs or skeleton shapes). It must not intercept touches and should accept isActive, duration, bandWidth and highlight color parameters.
            """#
        ) { ShimmerDemo() },
    ]

    // MARK: - Button

    static let button: [MotionEffect] = [
        MotionEffect(
            id: "pressable",
            name: "Pressable",
            summary: "Button squashes and darkens on press, then springs back with a light haptic.",
            component: .button,
            triggers: [.press],
            sourceFile: "Button/PressableButtonStyle.swift",
            usage: #"""
            Button("Continue") { }
                .buttonStyle(.pressable)

            Button("Big squish") { }
                .buttonStyle(.pressable(scale: 0.85))
            """#,
            prompt: #"""
            Create a SwiftUI ButtonStyle called PressableButtonStyle (iOS 17+). While pressed, the label scales to 0.94 and its brightness drops slightly (-0.06); on release it springs back using .spring(response: 0.3, dampingFraction: 0.6). Fire a light impact haptic with .sensoryFeedback only when the press begins. Expose it as .buttonStyle(.pressable) and .buttonStyle(.pressable(scale:haptics:)) via a static extension on ButtonStyle.
            """#
        ) { PressableDemo() },

        MotionEffect(
            id: "ripple",
            name: "Tap Ripple",
            summary: "A circular ripple expands from the exact tap location.",
            component: .button,
            triggers: [.tap],
            sourceFile: "Button/Ripple.swift",
            usage: #"""
            Text("Tap")
                .frame(width: 200, height: 60)
                .background(.indigo, in: RoundedRectangle(cornerRadius: 12))
                .ripple(color: .white, cornerRadius: 12)
            """#,
            prompt: #"""
            Create a SwiftUI .ripple() view modifier (iOS 17+) that shows a Material-style ripple. Use a simultaneous SpatialTapGesture so it doesn't block the view's own button action. Each tap appends a ripple at the tap location; each ripple is a translucent circle (white, 35% opacity) sized to 2× the view's diagonal that scales from ~0 to 1 while fading to 0 with easeOut over 0.7 s, then is removed. Ripples are drawn in an overlay clipped to a rounded rectangle with a configurable corner radius and never intercept touches. Multiple quick taps should produce overlapping ripples.
            """#
        ) { RippleDemo() },

        MotionEffect(
            id: "shake",
            name: "Error Shake",
            summary: "Horizontal \"no\" shake for wrong input, triggered by a value change.",
            component: .button,
            triggers: [.change],
            sourceFile: "Button/Shake.swift",
            usage: #"""
            @State private var attempts = 0

            SecureField("Password", text: $password)
                .shake(trigger: attempts)
                .sensoryFeedback(.error, trigger: attempts)

            // On a failed login:
            attempts += 1
            """#,
            prompt: #"""
            Create a SwiftUI .shake(trigger:) view modifier (iOS 17+) for error feedback. Every time the Equatable trigger changes, the view shakes horizontally using keyframeAnimator on an x offset: -10, +10, -7, +7, -3 points (≈0.07 s each, cubic keyframes) and then settles back to 0 with a bouncy SpringKeyframe. Amplitude should be configurable. Pair it with .sensoryFeedback(.error, trigger:) for haptics.
            """#
        ) { ShakeDemo() },
    ]

    // MARK: - Card & Group

    static let card: [MotionEffect] = [
        MotionEffect(
            id: "staggered-appear",
            name: "Staggered Entrance",
            summary: "List items fade and rise into place one after another.",
            component: .card,
            triggers: [.appear],
            sourceFile: "Card/StaggeredAppear.swift",
            usage: #"""
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                CardView(item)
                    .staggeredAppear(index: index)
            }
            """#,
            prompt: #"""
            Create a SwiftUI .staggeredAppear(index:) view modifier (iOS 17+) for list and grid entrances. Each item starts at opacity 0, offset 24 pt down and scale 0.96, then on appear animates to its resting state with .spring(response: 0.5, dampingFraction: 0.8), delayed by index × 0.08 s so the items cascade in. Delay per item and travel distance are configurable.
            """#
        ) { StaggeredDemo() },

        MotionEffect(
            id: "tilt",
            name: "3D Tilt",
            summary: "Card tilts in 3D toward the finger with a moving glare, then springs flat.",
            component: .card,
            triggers: [.drag],
            sourceFile: "Card/Tilt.swift",
            usage: #"""
            CardView()
                .tiltOnDrag(maxAngle: 15, cornerRadius: 20)
            """#,
            prompt: #"""
            Create a SwiftUI .tiltOnDrag() view modifier (iOS 17+). While the user drags on the view, convert the drag translation into a normalised -1…1 value per axis (120 pt = full tilt) and apply two rotation3DEffects (x axis from vertical drag, y axis from horizontal drag) up to a max angle of ~12°, plus a 1.03 scale. Overlay a white glare gradient whose start/end points follow the tilt and which is only visible while dragging, clipped to the card's corner radius. Use .interactiveSpring while dragging and a bouncy spring back to flat on release.
            """#
        ) { TiltDemo() },

        MotionEffect(
            id: "scroll-reveal",
            name: "Scroll Reveal",
            summary: "Rows scale up and come into focus as they enter the visible area.",
            component: .card,
            triggers: [.scroll],
            sourceFile: "Card/ScrollReveal.swift",
            usage: #"""
            ScrollView {
                LazyVStack {
                    ForEach(items) { item in
                        Row(item).scrollReveal()
                    }
                }
            }
            """#,
            prompt: #"""
            Create a SwiftUI .scrollReveal() view modifier (iOS 17+) using scrollTransition(.interactive). When an item is fully inside the scroll view (phase.isIdentity) it is at full opacity, scale 1 and no blur; as it moves toward the top or bottom edge it interpolates to opacity 0.3, scale 0.85 and a 2 pt blur. Axis, minimum scale, minimum opacity and blur amount should be parameters.
            """#
        ) { ScrollRevealDemo() },
    ]

    // MARK: - Shape

    static let shape: [MotionEffect] = [
        MotionEffect(
            id: "pulse-rings",
            name: "Pulse Rings",
            summary: "Concentric rings expand and fade continuously, like a radar or live dot.",
            component: .shape,
            triggers: [.loop],
            sourceFile: "Shape/PulseRings.swift",
            usage: #"""
            ZStack {
                PulseRings(color: .green, count: 3)
                    .frame(width: 120, height: 120)
                Circle().fill(.green).frame(width: 24, height: 24)
            }
            """#,
            prompt: #"""
            Create a SwiftUI PulseRings view (iOS 17+). Draw N stroked circles (default 3, 2 pt line) that each grow from 20% to 100% of the frame while fading from opacity 1 to 0 over a 2 s cycle, evenly phase-offset so a new ring is always emerging. Drive it with TimelineView(.animation) and compute each ring's progress from the timeline date (no @State or repeatForever), so it never drifts and stops when off screen. Hide it from accessibility.
            """#
        ) { PulseDemo() },

        MotionEffect(
            id: "burst",
            name: "Like Burst",
            summary: "Particles fly outward from the centre when a value changes.",
            component: .shape,
            triggers: [.tap, .change],
            sourceFile: "Shape/Burst.swift",
            usage: #"""
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .contentTransition(.symbolEffect(.replace))
                .burst(trigger: isLiked, color: .pink, isEnabled: isLiked)
            """#,
            prompt: #"""
            Create a SwiftUI .burst(trigger:) view modifier (iOS 17+) for "like" feedback. Every time the Equatable trigger changes (and isEnabled is true), spawn a burst in an overlay: 12 small circles (alternating 7 pt and 4 pt) placed evenly around a circle, which move outward from the centre to a ~36 pt radius while shrinking to 30% and fading out with easeOut over 0.6 s. Remove each burst after it finishes, allow overlapping bursts, and never intercept touches. Color, count and radius are parameters.
            """#
        ) { BurstDemo() },
    ]

    // MARK: - Background

    static let background: [MotionEffect] = [
        MotionEffect(
            id: "aurora",
            name: "Aurora",
            summary: "Soft, blurred colour blobs drift slowly behind your content.",
            component: .background,
            triggers: [.loop],
            sourceFile: "Background/AuroraBackground.swift",
            usage: #"""
            ZStack {
                AuroraBackground(colors: [.purple, .blue, .teal, .pink])
                    .ignoresSafeArea()
                Text("Welcome").font(.largeTitle.bold())
            }
            """#,
            prompt: #"""
            Create a SwiftUI AuroraBackground view (iOS 17+). On a dark base color, draw one large circle per palette color (default purple, blue, teal, pink; 80% opacity, diameter 70% of the larger side). Each circle drifts on its own Lissajous path, x = cos(t·0.6 + phase)·30% width and y = sin(t·0.8 + phase·1.3)·30% height, where phase differs per index. Drive time from TimelineView(.animation) scaled by a speed parameter, blur the whole group with a ~60 pt radius, clip to bounds and hide it from accessibility.
            """#
        ) { AuroraDemo() },
    ]

    // MARK: - Number

    static let number: [MotionEffect] = [
        MotionEffect(
            id: "rolling-number",
            name: "Rolling Number",
            summary: "Digits roll like an odometer when the value changes.",
            component: .number,
            triggers: [.change],
            sourceFile: "Number/RollingNumber.swift",
            usage: #"""
            RollingNumber(value: score)
                .font(.system(size: 48, weight: .bold, design: .rounded))
            """#,
            prompt: #"""
            Create a SwiftUI RollingNumber view (iOS 17+) that displays a number with odometer-style digit rolling. Render Text(value, format:) with monospacedDigit(), apply .contentTransition(.numericText(value:)) so digits roll up when the value increases and down when it decreases, and animate changes with .snappy. Provide initialisers for Int and for Double with a FloatingPointFormatStyle.
            """#
        ) { RollingNumberDemo() },
    ]
}
