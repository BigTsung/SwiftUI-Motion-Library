import SwiftUI
import MotionLibrary

/// Every effect in the library, in display order.
///
/// To add an effect: implement it in `Sources/MotionLibrary/<Component>/`,
/// add a demo view in `Demos.swift`, then append an entry here.
/// See CONTRIBUTING.md for the checklist.
public enum MotionCatalog {
    public static let all: [MotionEffect] = text + button + card + shape + background + number + particle + transition

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
            api: "TypewriterText(\"…\")",
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
            api: "ScrambleText(\"…\")",
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
            api: ".shimmer()",
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
        MotionEffect(
            id: "gradient-sweep",
            name: "Gradient Sweep",
            summary: "A multi-colour gradient flows through the letters forever.",
            component: .text,
            triggers: [.loop],
            sourceFile: "Text/GradientSweep.swift",
            api: ".gradientSweep()",
            usage: #"""
            Text("Motion Library")
                .font(.largeTitle.weight(.heavy))
                .gradientSweep()

            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .gradientSweep(colors: [.yellow, .orange, .pink], duration: 2)
            """#,
            prompt: #"""
            Create a SwiftUI .gradientSweep(colors:duration:) view modifier (iOS 17+) that paints a view's own pixels with a flowing multi-colour gradient. In an overlay, use a GeometryReader to draw a horizontal LinearGradient twice as wide as the view whose colours are the palette repeated twice plus the first colour again (so the right half matches the left half). Offset it from 0 to −width with a linear animation that repeats forever without autoreversing, so the loop is seamless. Mask the overlay with the original content so only glyphs or shapes are coloured, and disable hit testing. Default palette pink, orange, yellow, mint, cyan, purple over 3 s. With Reduce Motion on, show the gradient without moving it.
            """#
        ) { GradientSweepDemo() },

        MotionEffect(
            id: "blur-in",
            name: "Blur-in Words",
            summary: "Words come into focus one after another: fade, rise and un-blur.",
            component: .text,
            triggers: [.appear, .change],
            sourceFile: "Text/BlurInText.swift",
            api: "BlurInText(\"…\")",
            usage: #"""
            BlurInText("Design is how it works.")
                .font(.title.weight(.semibold))

            BlurInText("Letter by letter", by: .character, stagger: 0.03)
            """#,
            prompt: #"""
            Create a SwiftUI BlurInText view (iOS 17+) that reveals a string piece by piece, split by word (default) or by character. Lay the pieces out with a custom Layout that flows left to right, wraps to new lines and centres each line; the gap between words is about 0.28 × the line height. Each piece starts at opacity 0, blur radius 8 and 8 pt lower, and animates to opacity 1, no blur and no offset with easeOut(0.6 s), delayed by index × stagger (0.08 s default). Replay when the text changes by resetting a revealed flag and setting it again on the next run loop. Expose the whole string as one accessibility label. With Reduce Motion on, only fade.
            """#
        ) { BlurInDemo() },

        MotionEffect(
            id: "marquee",
            name: "Marquee",
            summary: "Text too long for its line scrolls sideways forever, with faded edges.",
            component: .text,
            triggers: [.loop],
            sourceFile: "Text/MarqueeText.swift",
            api: "MarqueeText(\"…\")",
            usage: #"""
            MarqueeText("Now playing: Midnight Drive — Neon Coast")
                .font(.headline)
                .frame(width: 200)

            MarqueeText(longTitle, speed: 60, gap: 24)
            """#,
            prompt: #"""
            Create a SwiftUI MarqueeText view (iOS 17+) for a single line of text. Measure the text's natural width (fixedSize text with a GeometryReader background) and the container width. If the text fits, show it still. If not, show two copies in an HStack separated by a gap (40 pt) and offset them left by (time × speed) modulo (textWidth + gap) using TimelineView(.animation), so the second copy takes the first copy's place and the loop is seamless. Speed defaults to 40 pt/s. Clip to the container and mask the edges with 16 pt linear fades. Reserve one line of height with a hidden copy of the text. Expose the full text to accessibility, and with Reduce Motion on, don't scroll.
            """#
        ) { MarqueeDemo() },

        MotionEffect(
            id: "wave-text",
            name: "Wave Text",
            summary: "Letters bob in a travelling wave, drawn with a TextRenderer.",
            component: .text,
            triggers: [.loop],
            requirement: .ios18,
            sourceFile: "Text/WaveText.swift",
            api: "WaveText(\"…\")",
            usage: #"""
            if #available(iOS 18, *) {
                WaveText("Making waves")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.blue)
            }
            """#,
            prompt: #"""
            Create a SwiftUI WaveText view for iOS 18+ (mark it @available(iOS 18, macOS 15, visionOS 2, *)) that makes each letter bob up and down in a travelling wave while keeping normal text layout. Implement a TextRenderer whose draw(layout:in:) walks every line, run and glyph, keeps a running glyph index, copies the GraphicsContext, translates it vertically by sin((index / wavelength − time × speed) × 2π) × amplitude, and draws the glyph. Set displayPadding to the amplitude above and below so nothing clips. Drive time from TimelineView(.animation) and apply the renderer with .textRenderer. Defaults: amplitude 5 pt, wavelength 8 letters, 1 wave per second. With Reduce Motion on, pause the timeline and use zero amplitude.
            """#
        ) { WaveTextDemo() },

        // MARK: v0.3

        MotionEffect(
            id: "count-up",
            name: "Count Up",
            summary: "A number counts up from zero, and from old to new value on change.",
            component: .text,
            triggers: [.appear, .change],
            sourceFile: "Text/CountUpText.swift",
            api: "CountUpText(value: …)",
            usage: #"""
            CountUpText(value: revenue, prefix: "$")
                .font(.largeTitle.bold())

            CountUpText(value: 98.6, fractionDigits: 1, suffix: "%", duration: 2)
            """#,
            prompt: #"""
            Create a SwiftUI CountUpText view (iOS 17+) with value, duration (1.4 s), fractionDigits (0), prefix and suffix. Keep a @State shown value starting at 0; on appear and whenever value changes, set shown = value inside withAnimation(.easeOut(duration:)). Render through a private view that conforms to both View and Animatable (animatableData = the number) so SwiftUI calls body on every frame with the interpolated value, and format it with value.formatted(.number.precision(.fractionLength(fractionDigits))) between prefix and suffix. Use .monospacedDigit() so the width doesn't jitter, and give it the final formatted value as its accessibility label. With Reduce Motion on, jump straight to the value.
            """#
        ) { CountUpDemo() },

        MotionEffect(
            id: "split-text",
            name: "Split Text",
            summary: "Letters rise into place one after another with a small overshoot.",
            component: .text,
            triggers: [.appear, .change],
            requirement: .ios18,
            sourceFile: "Text/SplitText.swift",
            api: "SplitText(\"…\")",
            usage: #"""
            if #available(iOS 18, *) {
                SplitText("Letters take the stage")
                    .font(.largeTitle.bold())
            }
            """#,
            prompt: #"""
            Create a SwiftUI SplitText view for iOS 18+ (mark it @available(iOS 18, macOS 15, visionOS 2, *)) with duration per letter (0.5 s), stagger (0.035 s) and distance (18 pt). Apply a TextRenderer that is also Animatable, with a progress value 0…1 as animatableData. In draw(layout:in:), count all glyphs, then for glyph i compute start = spread × i / (count − 1), where spread is the share of the total time taken by the delays, and local = clamp((progress − start) / (1 − spread), 0, 1). Copy the GraphicsContext, set opacity to min(1, local × 2), translate it down by (1 − backOut(local)) × distance (backOut: ease-out with ~1.7 overshoot) and draw the glyph. Set displayPadding at the bottom to distance. In .task(id: string), reset progress to 0 without animation, then animate it to 1 with linear timing over duration + stagger × (count − 1). With Reduce Motion on, use zero distance (a fade).
            """#
        ) { SplitTextDemo() },

        MotionEffect(
            id: "rotating-text",
            name: "Rotating Text",
            summary: "Words take turns: the current one slides up and out as the next rises in.",
            component: .text,
            triggers: [.loop],
            sourceFile: "Text/RotatingText.swift",
            api: "RotatingText([…])",
            usage: #"""
            HStack {
                Text("We")
                RotatingText(["design", "build", "ship"])
                    .foregroundStyle(.blue)
            }
            .font(.largeTitle.bold())
            """#,
            prompt: #"""
            Create a SwiftUI RotatingText view (iOS 17+) that cycles through an array of words every interval (2 s). Keep a @State index and show Text(words[index]).id(index) inside a ZStack with .fixedSize() and .clipped(). Give the text an asymmetric transition: insertion .move(edge: .bottom) combined with .opacity, removal .move(edge: .top) combined with .opacity. Drive it from .task with a loop of Task.sleep followed by withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { index += 1 }, so the width also springs to fit each word. Expose all words joined by commas as the accessibility label. With Reduce Motion on, use a plain opacity transition.
            """#
        ) { RotatingTextDemo() },

        MotionEffect(
            id: "glitch",
            name: "Glitch",
            summary: "Every few seconds the view tears: an RGB split, sliced rows and jitter.",
            component: .text,
            triggers: [.loop],
            sourceFile: "Text/Glitch.swift",
            api: ".glitch()",
            usage: #"""
            Text("SYSTEM FAILURE")
                .font(.title.monospaced().bold())
                .glitch()

            Image("logo")
                .glitch(intensity: 2, interval: 4)
            """#,
            prompt: #"""
            Create a SwiftUI .glitch(isActive:intensity:interval:) view modifier (iOS 17+) that works on any view. Use TimelineView(.animation(minimumInterval: 1/24)) and derive everything from the clock: glitch during the first 0.35 s of every interval (2 s); within that window pick new pseudo-random values 24 times a second from a cheap integer hash of (frame, salt). While glitching: (1) behind the content, draw two silhouettes of it, content.brightness(1).colorMultiply(.cyan) offset left and content.brightness(1).colorMultiply(.red) offset right by 2–6 pt × intensity, at 85 % opacity; (2) in an overlay, draw a copy of the content offset sideways by up to ±12 pt, masked to a horizontal strip at a random height (10–35 % of the view tall); (3) jitter the whole view by up to ±1.5 pt. Outside the window, show the content untouched. With Reduce Motion on, don't glitch at all.
            """#
        ) { GlitchDemo() },

        MotionEffect(
            id: "circular-text",
            name: "Circular Text",
            summary: "Text wrapped around a circle that slowly turns, like a rotating badge.",
            component: .text,
            triggers: [.loop],
            sourceFile: "Text/CircularText.swift",
            api: "CircularText(\"…\")",
            usage: #"""
            ZStack {
                CircularText("SWIFTUI • MOTION • LIBRARY • ", radius: 60)
                    .font(.caption.monospaced().bold())
                Image(systemName: "sparkles").font(.largeTitle)
            }
            """#,
            prompt: #"""
            Create a SwiftUI CircularText view (iOS 17+) with text, radius (60 pt) and speed (20° per second). Split the string into characters and place each one in a ZStack as Text(character).offset(y: −radius).rotationEffect(.degrees(index / count × 360)), so letters stand evenly spaced around the circle. Wrap the ZStack in TimelineView(.animation) and rotate it by time × speed degrees (modulo 360). Frame it to 2 × radius plus 12 pt padding. Use the full text as a single accessibility label. With Reduce Motion on (or speed 0), pause the timeline.
            """#
        ) { CircularTextDemo() },

        MotionEffect(
            id: "focus-text",
            name: "Focus Text",
            summary: "Focus hops from word to word: sharp and bracketed, the rest blurred.",
            component: .text,
            triggers: [.loop],
            sourceFile: "Text/FocusText.swift",
            api: "FocusText(\"…\")",
            usage: #"""
            FocusText("Motion made simple")
                .font(.title.bold())

            FocusText("Plan Build Ship", interval: 0.8, bracketColor: .pink)
            """#,
            prompt: #"""
            Create a SwiftUI FocusText view (iOS 17+) that splits a sentence into words in an HStack (10 pt spacing). A @State focus index advances every interval (1.2 s) in a .task loop with withAnimation(.spring(response: 0.45, dampingFraction: 0.8)). Unfocused words get blur radius 3 and opacity 0.55; the focused word is sharp. Behind the focused word only, draw four L-shaped corner brackets (Canvas, 2.5 pt round strokes, arms 8 pt, 2 pt outside the word's padded frame) and give them .matchedGeometryEffect(id: "focus", in: namespace) so the brackets glide and resize from word to word. Use the sentence as the accessibility label. With Reduce Motion on, use a short ease instead of the spring.
            """#
        ) { FocusTextDemo() },

        MotionEffect(
            id: "highlighter",
            name: "Highlighter",
            summary: "A marker pen swipes across the text, or underlines it, left to right.",
            component: .text,
            triggers: [.appear, .change],
            sourceFile: "Text/Highlighter.swift",
            api: ".highlighter()",
            usage: #"""
            Text("the important part")
                .highlighter()

            Text("Pricing")
                .highlighter(isActive: isSelected, color: .pink, style: .underline)
            """#,
            prompt: #"""
            Create a SwiftUI .highlighter(isActive:color:style:duration:) view modifier (iOS 17+) with two styles. In a background GeometryReader, draw a rounded rectangle 6 pt wider than the text: for .marker, 55 % of the text height, yellow at 45 % opacity, rotated −1.2° and sitting over the lower half; for .underline, a full-opacity capsule about 10 % of the height (at least 3 pt) at the baseline. Scale it horizontally from 0 to 1 with anchor .leading, animated with easeOut(0.6 s) on appear and whenever isActive changes, so it swipes on from the left and back off. Disable hit testing and hide it from accessibility. With Reduce Motion on, switch it without animation.
            """#
        ) { HighlighterDemo() },
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
            api: ".buttonStyle(.pressable)",
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
            api: ".ripple()",
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
            api: ".shake(trigger:)",
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
        MotionEffect(
            id: "magnetic",
            name: "Magnetic Button",
            summary: "The button drifts toward a nearby pointer or dragging finger, then springs home.",
            component: .button,
            triggers: [.hover, .drag],
            sourceFile: "Button/Magnetic.swift",
            api: ".magnetic()",
            usage: #"""
            Button("Get started") { }
                .buttonStyle(.borderedProminent)
                .magnetic()

            Image(systemName: "plus.circle.fill")
                .font(.system(size: 44))
                .magnetic(strength: 0.5, radius: 40)
            """#,
            prompt: #"""
            Create a SwiftUI .magnetic(strength:radius:) view modifier (iOS 17+) that pulls a view toward the pointer. Pad the view by `radius` (60 pt) to enlarge its tracking area, give it a rectangular contentShape, measure the padded size with a GeometryReader background, then remove the padding again with .padding(-radius). In onContinuousHover (pointer on iPad, Mac and visionOS) and in a simultaneous DragGesture(minimumDistance: 0) (touch), offset the original content by (location − centre) × strength (0.3) using an interactiveSpring(response 0.25, damping 0.7). When hover ends or the drag ends, spring back to zero with spring(response 0.45, damping 0.45) for a little overshoot. With Reduce Motion on, don't move.
            """#
        ) { MagneticDemo() },

        MotionEffect(
            id: "hold-to-confirm",
            name: "Hold to Confirm",
            summary: "Liquid fills the button while you hold; the action runs only when it's full.",
            component: .button,
            triggers: [.press],
            sourceFile: "Button/HoldToConfirmButton.swift",
            api: "HoldToConfirmButton(\"…\") { }",
            usage: #"""
            HoldToConfirmButton("Hold to delete") {
                deleteAccount()
            }

            HoldToConfirmButton(duration: 2, fillColor: .orange) {
                launch()
            } label: {
                Label("Hold to launch", systemImage: "flame")
            }
            """#,
            prompt: #"""
            Create a SwiftUI HoldToConfirmButton (iOS 17+) for destructive actions. A capsule with a 15% tint of fillColor (red) shows the label in fillColor. While pressed (onLongPressGesture(minimumDuration:perform:onPressingChanged:)), animate a progress value linearly from its current value to 1 over the remaining duration (1.2 s); releasing early animates it back to 0 with easeOut(0.35). Draw the liquid as a Shape filled from the bottom up to progress, with a sine-wave top edge (4 pt amplitude, phase driven by TimelineView) that flattens when empty or full. Mask a stack of the liquid plus a white copy of the label with the same shape, so the submerged part of the text turns white. On completion, run the action, swap the label for a checkmark with a spring, play a success haptic and reset after 1.2 s. Scale to 0.97 while pressing.
            """#
        ) { HoldToConfirmDemo() },

        MotionEffect(
            id: "status-button",
            name: "Loading → Success",
            summary: "The button morphs into a spinner, then a green checkmark or a red shake.",
            component: .button,
            triggers: [.tap, .change],
            sourceFile: "Button/StatusButton.swift",
            api: "StatusButton(\"…\", status:) { }",
            usage: #"""
            @State private var status = MotionButtonStatus.idle

            StatusButton("Pay now", status: status) {
                status = .loading
                Task {
                    status = await pay() ? .success : .failure
                    try? await Task.sleep(for: .seconds(1.5))
                    status = .idle
                }
            }
            """#,
            prompt: #"""
            Create a SwiftUI StatusButton (iOS 17+) driven by a status enum: idle, loading, success, failure. It is a 50 pt tall capsule Button. Idle shows the title at its natural width. For any other status the frame width animates to 50 pt, turning the capsule into a circle (spring response 0.45, damping 0.75), and the title shrinks and fades. Loading shows a white 70% arc spinning forever. Success turns the fill green and draws a white checkmark path with trim from 0 to 1 (easeOut 0.35 s, 0.15 s delay). Failure turns the fill red, scales in an xmark and shakes horizontally with a GeometryEffect (8 pt, three swings). Play success and error haptics with sensoryFeedback, disable the button when not idle, and expose the status as the accessibility value.
            """#
        ) { StatusButtonDemo() },

        MotionEffect(
            id: "glow-border",
            name: "Glow Border",
            summary: "A rainbow border runs around the view with a soft glow behind it.",
            component: .button,
            triggers: [.loop],
            sourceFile: "Button/GlowBorder.swift",
            api: ".glowBorder()",
            usage: #"""
            Text("Upgrade to Pro")
                .padding()
                .background(.black, in: RoundedRectangle(cornerRadius: 14))
                .glowBorder(cornerRadius: 14)

            CardView()
                .glowBorder(colors: [.orange, .yellow], cornerRadius: 24, lineWidth: 3)
            """#,
            prompt: #"""
            Create a SwiftUI .glowBorder(colors:cornerRadius:lineWidth:glowRadius:duration:) view modifier (iOS 17+). In a non-interactive overlay, use TimelineView(.animation) to compute a rotation angle of (time / duration) turns (3 s per turn). Build an AngularGradient from the palette plus its first colour again (pink, purple, blue, cyan, mint by default) starting at that angle. Stroke a continuous RoundedRectangle with it twice: once at 2× line width, blurred by glowRadius (8) at 80% opacity for the glow, and once crisp at lineWidth (2). With Reduce Motion on, pause the rotation.
            """#
        ) { GlowBorderDemo() },

        // MARK: v0.3

        MotionEffect(
            id: "shine",
            name: "Shine",
            summary: "A slanted glint of light sweeps across the button, on cue or on a beat.",
            component: .button,
            triggers: [.change, .loop],
            sourceFile: "Button/Shine.swift",
            api: ".shine(every:) / .shine(trigger:)",
            usage: #"""
            PremiumBadge()
                .shine(every: 3)

            Button("Upgrade") { purchases += 1 }
                .buttonStyle(.borderedProminent)
                .shine(trigger: purchases)
            """#,
            prompt: #"""
            Create two SwiftUI modifiers (iOS 17+): .shine(trigger:color:duration:) and .shine(every:color:duration:). Both overlay a "band": a horizontal LinearGradient clear → white 70 % → clear, 30 % of the view's width (at least 24 pt), twice the view's height, rotated 20°, whose x offset goes from −1.5 × band (fully off the left) at progress 0 to width + 1.5 × band (off the right) at progress 1. Mask the band with the content so only the view's own pixels shine, and disable hit testing. The trigger version runs progress 0 → 1 with keyframeAnimator(initialValue: 0, trigger:) and one CubicKeyframe over duration (0.75 s), so the band is hidden at rest. The looping version uses TimelineView(.animation) with progress = (time mod interval) / duration, clamped to 1. With Reduce Motion on, skip the band.
            """#
        ) { ShineDemo() },

        MotionEffect(
            id: "jelly",
            name: "Jelly",
            summary: "A rubbery squash-and-stretch wobble on every tap.",
            component: .button,
            triggers: [.tap, .change],
            sourceFile: "Button/Jelly.swift",
            api: ".jelly(trigger:)",
            usage: #"""
            Button("Boing") { taps += 1 }
                .buttonStyle(.borderedProminent)
                .jelly(trigger: taps)
            """#,
            prompt: #"""
            Create a SwiftUI .jelly(trigger:amount:) view modifier (iOS 17+) using keyframeAnimator(initialValue:trigger:) on a struct with x and y scale (both 1), applied with scaleEffect(x:y:). With a = amount (0.25): the x track goes 1 + a (0.1 s), 1 − 0.8a (0.12 s), 1 + 0.5a (0.12 s) with cubic keyframes, then a SpringKeyframe(.bouncy) back to 1 over 0.4 s; the y track does the opposite (1 − a, 1 + 0.8a, 1 − 0.5a, spring to 1), so the view squashes wide and flat, then stretches tall and thin, then settles. With Reduce Motion on, use a = 0.
            """#
        ) { JellyDemo() },

        MotionEffect(
            id: "click-spark",
            name: "Click Spark",
            summary: "Short spark lines shoot out from the exact point you tapped.",
            component: .button,
            triggers: [.tap],
            sourceFile: "Button/ClickSpark.swift",
            api: ".clickSpark()",
            usage: #"""
            Button("Launch") { }
                .buttonStyle(.borderedProminent)
                .clickSpark(color: .orange)
            """#,
            prompt: #"""
            Create a SwiftUI .clickSpark(color:count:radius:) view modifier (iOS 17+). Detect taps with .simultaneousGesture(SpatialTapGesture()) and append a spark (UUID + location) to a @State array, removing it 0.6 s later. In a hit-testing-disabled overlay, place each spark at its location: count (8) capsules 2.5 pt wide and 0.45 × radius tall, each rotated by index / count × 360°. On appear, animate with easeOut(0.45 s) from offset −0.3 × radius to −radius (outward), scaleEffect(y:) from 1 to 0.1 anchored at the top (so each line shrinks toward its outer tip) and opacity from 1 to 0. With Reduce Motion on, don't add sparks.
            """#
        ) { ClickSparkDemo() },

        MotionEffect(
            id: "like-button",
            name: "Like Button",
            summary: "The heart pops in as a ring bursts open and coloured dots fly out.",
            component: .button,
            triggers: [.tap],
            sourceFile: "Button/LikeButton.swift",
            api: "LikeButton(isLiked:)",
            usage: #"""
            LikeButton(isLiked: $post.isLiked)

            LikeButton(isLiked: $liked, size: 40, color: .red)
            """#,
            prompt: #"""
            Create a SwiftUI LikeButton (iOS 17+) bound to isLiked, with size (28 pt), color (pink) and dotColors. It's a plain Button showing Image(systemName: isLiked ? "heart.fill" : "heart"); tapping toggles and, on like, increments a counter used as a keyframeAnimator trigger over a struct {heart, ring, dots}. Tracks: heart drops to 0.2 instantly, holds 0.15 s, then springs to 1 with a bouncy overshoot; ring goes 0 → 1 over 0.3 s then back to 0; dots wait 0.15 s then go 0 → 1 over 0.55 s. Behind the heart draw (a) a circle strokeBorder in color whose diameter is 1.5 × size × ring and whose line width is 0.5 × size × (1 − ring), so it bursts open and thins out; (b) 7 pairs of small dots (0.16 × size) at angles i/7 × 360° ± 10°, at distance size × (0.6 + 0.55 × dots), scaling down to 10 % as they fly. Unliking only springs the heart back. Add a light haptic on like, and hide the burst for Reduce Motion.
            """#
        ) { LikeButtonDemo() },

        MotionEffect(
            id: "animated-symbol",
            name: "Animated Symbol",
            summary: "SF Symbols that keep moving: bounce on a beat, pulse, variable colour.",
            component: .button,
            triggers: [.loop],
            sourceFile: "Button/AnimatedSymbol.swift",
            api: "AnimatedSymbol(\"…\", style:)",
            usage: #"""
            AnimatedSymbol("bell.fill")                      // bounces every 1.5 s
            AnimatedSymbol("heart.fill", style: .pulse)
            AnimatedSymbol("wifi", style: .variableColor)
            AnimatedSymbol("mic.fill", style: .scaleUp, isActive: isRecording)
            """#,
            prompt: #"""
            Create a SwiftUI AnimatedSymbol view (iOS 17+) wrapping Image(systemName:) with a style enum: .bounce, .pulse, .variableColor and .scaleUp, plus isActive and interval (1.5 s). For .bounce, apply .symbolEffect(.bounce, value: beats) and increment beats in a .task(id: isActive) loop every interval. For the others, use the indefinite effects .symbolEffect(.pulse, isActive:), .symbolEffect(.variableColor.iterative.reversing, isActive:) and .symbolEffect(.scale.up, isActive:). The view inherits font and foregroundStyle like any Image. With Reduce Motion on, treat it as inactive.
            """#
        ) { AnimatedSymbolDemo() },

        MotionEffect(
            id: "liquid-toggle",
            name: "Liquid Toggle",
            summary: "A switch whose knob stretches like a drop of liquid as it slides.",
            component: .button,
            triggers: [.tap],
            sourceFile: "Button/LiquidToggleStyle.swift",
            api: ".toggleStyle(.liquid)",
            usage: #"""
            Toggle("Wi-Fi", isOn: $wifi)
                .toggleStyle(.liquid)

            Toggle("Dark mode", isOn: $dark)
                .toggleStyle(.liquid(tint: .purple))
            """#,
            prompt: #"""
            Create a SwiftUI LiquidToggleStyle (iOS 17+) with a tint (green) and static accessors .liquid and .liquid(tint:). makeBody puts the label, a Spacer and a 52 × 32 pt switch in an HStack. The switch is a plain Button that toggles configuration.isOn inside withAnimation(.spring(response: 0.35, dampingFraction: 0.7)); it shows a ZStack aligned .trailing when on and .leading when off, with a capsule track (tint when on, gray 35 % when off) and a white capsule knob (26 pt tall, 3 pt padding, small shadow). The knob's width runs a keyframeAnimator triggered by isOn: CubicKeyframe to 1.5 × 26 pt over 0.12 s, then SpringKeyframe(.bouncy) back to 26 over 0.35 s, so it stretches as it slides and snaps back round. Give it an "On"/"Off" accessibility value. With Reduce Motion on, don't stretch and use a short ease.
            """#
        ) { LiquidToggleDemo() },
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
            api: ".staggeredAppear(index:)",
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
            api: ".tiltOnDrag()",
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
            api: ".scrollReveal()",
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
        MotionEffect(
            id: "flip-card",
            name: "Flip Card",
            summary: "A two-sided card turns over in 3D with a spring.",
            component: .card,
            triggers: [.tap, .change],
            sourceFile: "Card/FlipCard.swift",
            api: "FlipCard(isFlipped:) { } back: { }",
            usage: #"""
            @State private var flipped = false

            FlipCard(isFlipped: flipped) {
                QuestionView()
            } back: {
                AnswerView()
            }
            .frame(width: 220, height: 300)
            .onTapGesture { flipped.toggle() }
            """#,
            prompt: #"""
            Create a SwiftUI FlipCard<Front, Back> view (iOS 17+) with isFlipped and axis (horizontal or vertical) parameters and front/back view builders. Stack both faces in a ZStack and give each an Animatable view modifier holding the animated angle (0 or 180°). The back face uses angle − 180 so it reads correctly once turned. Each face applies rotation3DEffect around the y axis (or x for vertical) with perspective 0.5 and sets opacity to 1 only while |faceAngle| < 90°, so the faces swap exactly at the halfway point and the back never shows mirrored. Animate isFlipped changes with spring(response 0.6, damping 0.75). Hide the hidden face from accessibility. With Reduce Motion on, cross-fade instead of rotating.
            """#
        ) { FlipCardDemo() },

        MotionEffect(
            id: "swipe-stack",
            name: "Swipe Card Stack",
            summary: "Tinder-style deck: drag the top card away and the pile moves up.",
            component: .card,
            triggers: [.drag],
            sourceFile: "Card/SwipeCardStack.swift",
            api: "SwipeCardStack(items) { item in }",
            usage: #"""
            SwipeCardStack(profiles) { profile, direction in
                direction == .right ? like(profile) : pass(profile)
            } card: { profile in
                ProfileCard(profile)
                    .frame(width: 300, height: 420)
            }
            """#,
            prompt: #"""
            Create a generic SwiftUI SwipeCardStack (iOS 17+) over a collection of Identifiable items with a card view builder and an onSwipe(item, direction) callback. Show the top 3 cards from the current position (looping by default). Cards behind are scaled down 5% per level and moved down 12 pt per level. The top card follows a DragGesture: offset by the translation, rotate by translation.width / 20 degrees around the bottom anchor, and overlay a green (right) or red (left) wash, masked by the card, whose opacity grows to 25% at the threshold. On release, if the predicted end translation passes 110 pt, fly the card 600 pt off in that direction with easeIn(0.25), then reset the drag without animation, advance the position with a spring so the pile moves up, and call onSwipe. Otherwise spring back. Add Swipe left and Swipe right accessibility actions.
            """#
        ) { SwipeStackDemo() },

        MotionEffect(
            id: "parallax-carousel",
            name: "Parallax Carousel",
            summary: "Paging cards whose images slide slower than the cards, for depth.",
            component: .card,
            triggers: [.scroll],
            sourceFile: "Card/ParallaxCarousel.swift",
            api: "ParallaxCarousel(items) { item in }",
            usage: #"""
            ParallaxCarousel(places) { place in
                Image(place.photo)
                    .resizable()
                    .scaledToFill()
            }
            .frame(height: 240)
            """#,
            prompt: #"""
            Create a generic SwiftUI ParallaxCarousel (iOS 17+) over Identifiable items with an optional selection binding. Use a horizontal ScrollView with a LazyHStack (14 pt spacing), .scrollTargetLayout(), .scrollTargetBehavior(.viewAligned), hidden indicators, .scrollPosition(id:anchor: .center), and horizontal contentMargins so each card (78% of the width) snaps to the centre with neighbours peeking. Draw each card's content wider than the card by the parallax factor (0.35), then use .visualEffect to read the card's frame in the .scrollView coordinate space and offset the content by −(distance of the card centre from the viewport centre) × parallax. Finally frame it to the card size and clip it with a continuous rounded rectangle (22 pt), so the image appears to move slower than its frame. With Reduce Motion on, set parallax to 0.
            """#
        ) { ParallaxDemo() },

        MotionEffect(
            id: "expandable-card",
            name: "Expandable Card",
            summary: "Tap the header and the card springs open, un-blurring its detail.",
            component: .card,
            triggers: [.tap],
            sourceFile: "Card/ExpandableCard.swift",
            api: "ExpandableCard(isExpanded:) { } detail: { }",
            usage: #"""
            @State private var isOpen = false

            ExpandableCard(isExpanded: $isOpen) {
                Text("Shipping").font(.headline)
            } detail: {
                Text("Arrives Thursday. Free returns within 30 days.")
            }
            """#,
            prompt: #"""
            Create a SwiftUI ExpandableCard<Header, Detail> (iOS 17+) bound to isExpanded. A VStack holds a plain-style Button containing the header, a spacer and a chevron.down that rotates −180° when open, then, if expanded, the detail view. Toggle inside withAnimation(.spring(response 0.45, damping 0.8)) so the card's height springs. Insert the detail with a combined transition of opacity, an 8 pt upward offset and a custom blur transition (radius 6 → 0). The background is a continuous rounded rectangle (16 pt) filled with the background style whose shadow deepens when open. Expose Expanded/Collapsed as the accessibility value. With Reduce Motion on, use a short ease and an opacity transition only.
            """#
        ) { ExpandableCardDemo() },

        // MARK: v0.3

        MotionEffect(
            id: "hero-expand",
            name: "Hero Expand",
            summary: "A thumbnail grows into a full detail card, morphing with matchedGeometryEffect.",
            component: .card,
            triggers: [.tap],
            sourceFile: "Card/HeroGrid.swift",
            api: "HeroGrid(items) { thumbnail } detail: { }",
            usage: #"""
            HeroGrid(photos, columns: 3) { photo in
                Image(photo.thumbnail).resizable().scaledToFill().frame(height: 90)
            } detail: { photo in
                PhotoDetail(photo)
            }
            """#,
            prompt: #"""
            Create a generic SwiftUI HeroGrid (iOS 17+) over Identifiable items with columns (3), spacing (10), cornerRadius (14) and two view builders: thumbnail and detail. Keep @State selected: Item.ID? and a @Namespace. In a ZStack, show a LazyVGrid of flexible columns; for each item, if it isn't selected show a plain Button with the thumbnail clipped to a continuous rounded rectangle and .matchedGeometryEffect(id: item.id, in: namespace), otherwise show the thumbnail .hidden() to keep the slot. Dim the grid to 30 % while something is selected. Above it, if selected, show the detail in a Button sized maxWidth/maxHeight .infinity, clipped the same way, with the same matchedGeometryEffect id and zIndex 1. Open with withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) and close by tapping the detail. Both views get an .opacity transition so their content cross-fades while the frame morphs. With Reduce Motion on, pass properties: [] to matchedGeometryEffect so it only cross-fades.
            """#
        ) { HeroGridDemo() },

        MotionEffect(
            id: "spotlight-card",
            name: "Spotlight Card",
            summary: "A soft glow follows the pointer across the card, like a torch.",
            component: .card,
            triggers: [.hover, .drag],
            sourceFile: "Card/Spotlight.swift",
            api: ".spotlight()",
            usage: #"""
            FeatureCard()
                .background(.black, in: RoundedRectangle(cornerRadius: 20))
                .spotlight()

            PricingCard()
                .spotlight(color: .purple.opacity(0.4), radius: 160)
            """#,
            prompt: #"""
            Create a SwiftUI .spotlight(color:radius:) view modifier (iOS 17+). Track the pointer with .onContinuousHover(coordinateSpace: .local) and a finger with a simultaneous DragGesture(minimumDistance: 0); store the location in @State (nil when the pointer leaves or the drag ends) and remember the last location so the glow can fade out where it was. In an overlay GeometryReader, draw a RadialGradient from color (white 35 %) to clear, centred at the location converted to a UnitPoint, endRadius = radius (120 pt), and mask it with the content so it only lights the card. Move with .interactiveSpring(response: 0.2, dampingFraction: 0.9) and fade out with easeOut(0.35 s). Disable hit testing on the glow. With Reduce Motion on, move the glow without animation.
            """#
        ) { SpotlightDemo() },

        MotionEffect(
            id: "dock",
            name: "Magnifying Dock",
            summary: "Icons swell as the pointer passes over them, like the macOS Dock.",
            component: .card,
            triggers: [.hover, .drag],
            sourceFile: "Card/MagnifyingDock.swift",
            api: "MagnifyingDock(items) { item in }",
            usage: #"""
            MagnifyingDock(apps) { app in
                Image(app.icon).resizable()
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            """#,
            prompt: #"""
            Create a generic SwiftUI MagnifyingDock (iOS 17+) over Identifiable items with size (40 pt), magnification (1.8), range (110 pt), spacing (8) and a content builder. Lay the items out in an HStack(alignment: .bottom) and frame each icon to size × scale(i). Put the HStack in a frame exactly as wide as the resting row (count × size + gaps) and size × magnification tall, aligned to the bottom, so the magnified row overflows it evenly; track the pointer x on that frame with .onContinuousHover and a simultaneous DragGesture(minimumDistance: 0). scale(i) = 1 + (magnification − 1) × cos(d / range × π/2) where d is the distance from the pointer to the icon's resting centre (i × (size + spacing) + size/2), or 1 beyond range. Animate pointer changes with .interactiveSpring(response: 0.2) and the release with .spring(response: 0.35, dampingFraction: 0.75). Add horizontal padding for the overflow. With Reduce Motion on, don't magnify.
            """#
        ) { DockDemo() },

        MotionEffect(
            id: "jiggle",
            name: "Jiggle",
            summary: "The home-screen edit-mode wiggle, each item slightly out of step.",
            component: .card,
            triggers: [.loop, .change],
            sourceFile: "Card/Jiggle.swift",
            api: ".jiggle(isActive:)",
            usage: #"""
            ForEach(apps) { app in
                AppIcon(app)
                    .jiggle(isActive: isEditing)
            }
            """#,
            prompt: #"""
            Create a SwiftUI .jiggle(isActive:angle:) view modifier (iOS 17+) that wiggles a view like an app icon in edit mode. Give each instance a random @State phase (0–1) and rate (0.9–1.1) so neighbours never move in lockstep. In TimelineView(.animation(paused: !isActive)), let t = (time × rate + phase) × 2π × 3.6, rotate by sin(t) × angle (2.5°) and offset y by cos(t/2) × 0.8 pt. When inactive, return to 0 with a 0.15 s ease. With Reduce Motion on, don't move.
            """#
        ) { JiggleDemo() },

        MotionEffect(
            id: "fan-stack",
            name: "Fan Stack",
            summary: "A pile of cards fans out like a hand of playing cards, and gathers back.",
            component: .card,
            triggers: [.tap, .change],
            sourceFile: "Card/FanStack.swift",
            api: "FanStack(items, isSpread:) { item in }",
            usage: #"""
            FanStack(cards, isSpread: isSpread) { card in
                CardView(card).frame(width: 80, height: 120)
            }
            .onTapGesture { isSpread.toggle() }
            """#,
            prompt: #"""
            Create a generic SwiftUI FanStack (iOS 17+) over Identifiable items with isSpread, angle (10°) and spacing (34 pt). Draw the cards in a ZStack, bottom first. For card i, let c = i − (count − 1)/2. Fanned: rotate by c × angle around the bottom anchor, offset x by c × spacing and y by c² × 4 pt so the outer cards dip along an arc. Stacked: rotate by c × 1.5° around the centre and offset y by −2 pt × i for a neat pile. Animate each card with .spring(response: 0.45, dampingFraction: 0.7).delay(i × 0.03) on isSpread so they follow each other. With Reduce Motion on, use a 0.25 s ease without the stagger.
            """#
        ) { FanStackDemo() },
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
            api: "PulseRings()",
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
            api: ".burst(trigger:)",
            usage: #"""
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .contentTransition(.symbolEffect(.replace))
                .burst(trigger: isLiked, color: .pink, isEnabled: isLiked)
            """#,
            prompt: #"""
            Create a SwiftUI .burst(trigger:) view modifier (iOS 17+) for "like" feedback. Every time the Equatable trigger changes (and isEnabled is true), spawn a burst in an overlay: 12 small circles (alternating 7 pt and 4 pt) placed evenly around a circle, which move outward from the centre to a ~36 pt radius while shrinking to 30% and fading out with easeOut over 0.6 s. Remove each burst after it finishes, allow overlapping bursts, and never intercept touches. Color, count and radius are parameters.
            """#
        ) { BurstDemo() },
        MotionEffect(
            id: "checkmark",
            name: "Checkmark Draw",
            summary: "A success mark draws itself: circle stroke, fill, then a popping check.",
            component: .shape,
            triggers: [.change],
            sourceFile: "Shape/AnimatedCheckmark.swift",
            api: "AnimatedCheckmark(isChecked:)",
            usage: #"""
            AnimatedCheckmark(isChecked: isDone)
                .frame(width: 80, height: 80)

            AnimatedCheckmark(isChecked: saved, color: .blue, lineWidth: 3)
            """#,
            prompt: #"""
            Create a SwiftUI AnimatedCheckmark view (iOS 17+) with isChecked, color (green) and lineWidth (4 at 60 pt, scaled with size). It is square. Layer three parts in a ZStack: a circle stroke trimmed from 0 to 1 and rotated −90° so it draws clockwise from the top (easeInOut 0.45 s); a filled circle that scales from 0.6 and fades in with a spring after 0.35 s; and a white checkmark path (short stroke down-right, long stroke up-right, round caps and joins) trimmed from 0 to 1 with easeOut 0.3 s after 0.55 s. Finish with a small bouncy scale pop at 0.75 s. Unchecking reverses everything without delays. With Reduce Motion on, replace the sequence with a 0.2 s fade.
            """#
        ) { CheckmarkDemo() },

        MotionEffect(
            id: "confetti",
            name: "Confetti",
            summary: "Confetti bursts out of the view, tumbles under gravity and fades.",
            component: .shape,
            triggers: [.tap, .change],
            sourceFile: "Shape/Confetti.swift",
            api: ".confetti(trigger:)",
            usage: #"""
            @State private var orders = 0

            Button("Complete order") { orders += 1 }
                .confetti(trigger: orders)

            Text("🎉 Level up!")
                .confetti(trigger: level, colors: [.yellow, .orange], count: 120)
            """#,
            prompt: #"""
            Create a SwiftUI .confetti(trigger:colors:count:spread:) view modifier (iOS 17+). Each change of the equatable trigger appends a burst with a start date and 80 random pieces, removed after 2.4 s. Each piece has a velocity fanned ±60° around straight up (speed up to 3.2 × spread), a spin rate, a wobble phase, a 5–9 × 8–14 pt size, a colour index and every fourth one is a circle. Draw all bursts in one Canvas inside TimelineView(.animation), in an overlay enlarged by .padding(−spread) (160 pt) so confetti flies beyond the view, with hit testing off. Position = origin + velocity × (1 − e^(−1.6t)) / 1.6 + ½ × gravity × t² (air drag plus gravity), rotate by spin × t, scale x by cos(wobble + 8t) to fake turning over, and fade out over the last 0.6 s. With Reduce Motion on, skip the burst.
            """#
        ) { ConfettiDemo() },

        MotionEffect(
            id: "loaders",
            name: "Loaders",
            summary: "Five looping activity indicators: spinner, dots, bars, orbit and pulse.",
            component: .shape,
            triggers: [.loop],
            sourceFile: "Shape/MotionLoader.swift",
            api: "MotionLoader(.spinner)",
            usage: #"""
            MotionLoader(.spinner)
                .frame(width: 32, height: 32)

            MotionLoader(.dots, color: .secondary)
                .frame(width: 44, height: 44)
            """#,
            prompt: #"""
            Create a SwiftUI MotionLoader view (iOS 17+) with a style enum (spinner, dots, bars, orbit, pulse), a color and a speed multiplier. It is square and drives everything from TimelineView(.animation) time, sizing parts relative to its side. Spinner: a round-capped arc whose trim length breathes between 15% and 75% while it rotates. Dots: three dots hopping up in sequence (max(0, sin(6t − i·0.9))) and brightening at the top. Bars: five capsules whose heights follow a sine wave offset per bar. Orbit: two dots circling each other, scaled and layered by a fake depth. Pulse: two rings expanding and fading in turn around a centre dot. Label it "Loading" for accessibility, and with Reduce Motion on, show a dot that slowly breathes in opacity.
            """#
        ) { LoaderDemo() },

        MotionEffect(
            id: "morphing-blob",
            name: "Morphing Blob",
            summary: "An organic, lava-lamp blob whose outline never stops changing.",
            component: .shape,
            triggers: [.loop],
            sourceFile: "Shape/MorphingBlob.swift",
            api: "MorphingBlob()",
            usage: #"""
            MorphingBlob(colors: [.purple, .pink, .orange])
                .frame(width: 200, height: 200)

            MorphingBlob(fill: Color.blue.opacity(0.3), points: 8, wobble: 0.1)
                .overlay(Image(systemName: "mic.fill"))
            """#,
            prompt: #"""
            Create a SwiftUI MorphingBlob view (iOS 17+) generic over a ShapeStyle fill, with a convenience initializer taking colours for a diagonal LinearGradient. Draw a custom Shape in TimelineView(.animation): place N control points (6) evenly around the centre, each at radius base × (1 + wobble × (0.6·sin(1.1t + 1.7i) + 0.4·sin(0.7t + 2.9i))), where base = half the side × (1 − wobble) and wobble is 0.18. Connect them into a smooth closed curve with a Catmull-Rom spline converted to cubic Béziers (control points p1 + (p2 − p0)/6 and p2 − (p3 − p1)/6). Keep a 1:1 aspect ratio and hide it from accessibility. With Reduce Motion on, freeze the shape.
            """#
        ) { BlobDemo() },

        // MARK: v0.3

        MotionEffect(
            id: "draw-on",
            name: "Draw On",
            summary: "Any Shape strokes itself on like a pen, and erases back.",
            component: .shape,
            triggers: [.appear, .change],
            sourceFile: "Shape/DrawOn.swift",
            api: "Shape.drawOn()",
            usage: #"""
            Circle()
                .drawOn()
                .frame(width: 80, height: 80)

            SignaturePath()
                .drawOn(isDrawn: signed, style: .blue, lineWidth: 3, duration: 1.6)
            """#,
            prompt: #"""
            Create a SwiftUI Shape extension drawOn(isDrawn:style:lineWidth:duration:) (iOS 17+) returning a DrawOnShape view. It strokes shape.trim(from: 0, to: progress) with the given ShapeStyle (accent colour), a StrokeStyle with lineWidth (3 pt), round caps and round joins, and pads by lineWidth / 2 so the stroke isn't clipped. Keep progress in @State; on appear and whenever isDrawn changes, animate it to 1 (draw) or 0 (erase) with easeInOut over duration (1.2 s). Works with any Shape, including custom paths, which are drawn in path order. With Reduce Motion on, use a 0.2 s ease.
            """#
        ) { DrawOnDemo() },

        MotionEffect(
            id: "progress-ring",
            name: "Progress Ring",
            summary: "A gradient ring springs to each value as the percentage rolls.",
            component: .shape,
            triggers: [.change],
            sourceFile: "Shape/ProgressRing.swift",
            api: "ProgressRing(progress:)",
            usage: #"""
            ProgressRing(progress: uploaded)
                .frame(width: 120, height: 120)

            ProgressRing(progress: steps / goal, colors: [.green, .mint]) {
                Image(systemName: "figure.walk").font(.title)
            }
            """#,
            prompt: #"""
            Create a SwiftUI ProgressRing (iOS 17+) with progress (0…1), lineWidth (12 pt), colors (cyan, blue, purple) and an optional label view builder (default: the percentage). In a ZStack, stroke a full Circle in secondary at 18 % opacity, then a Circle().trim(from: 0, to: progress) stroked with AngularGradient(colors:) over 0–360° and a round line cap, rotated −90° so it starts at twelve o'clock. Pad by lineWidth / 2. Animate progress changes with .spring(response: 0.6, dampingFraction: 0.75). The default label is the percentage as .title2.bold().monospacedDigit() with .contentTransition(.numericText(value:)), so the digits roll. Expose the percentage as the accessibility value. With Reduce Motion on, use a short ease.
            """#
        ) { ProgressRingDemo() },

        MotionEffect(
            id: "skeleton",
            name: "Skeleton",
            summary: "A shimmering placeholder of the view's own layout while it loads.",
            component: .shape,
            triggers: [.loop, .change],
            sourceFile: "Shape/Skeleton.swift",
            api: ".skeleton(isLoading:)",
            usage: #"""
            ArticleRow(article)
                .skeleton(isLoading: isLoading)
            """#,
            prompt: #"""
            Create a SwiftUI .skeleton(isLoading:) view modifier (iOS 17+). While loading, apply .redacted(reason: .placeholder) so text and images become grey blocks in the view's real layout, then the shimmer modifier (a white 80 % highlight band, 35 % of the width, sweeping left to right every 1.6 s, masked by the content), disable hit testing and hide the view from accessibility. When loading ends, remove both and animate with easeInOut(0.3 s) so the real content fades in. The shimmer pauses for Reduce Motion.
            """#
        ) { SkeletonDemo() },

        MotionEffect(
            id: "sliding-tabs",
            name: "Sliding Tabs",
            summary: "A segmented control whose pill or underline glides to the selection.",
            component: .shape,
            triggers: [.tap],
            sourceFile: "Shape/SlidingTabs.swift",
            api: "SlidingTabs([…], selection:)",
            usage: #"""
            SlidingTabs(["Day", "Week", "Month"], selection: $range)

            SlidingTabs(Category.allCases, selection: $category, indicator: .underline) { $0.title }
            """#,
            prompt: #"""
            Create a generic SwiftUI SlidingTabs control (iOS 17+) over Hashable options with a selection binding, an indicator style (.pill or .underline), a tint and a title closure (plus a convenience init for [String]). Show the options as plain Buttons in an HStack inside a 4 pt padded capsule tinted secondary at 12 % (pill style only). Behind the selected title only, draw the indicator — a capsule filled with the tint (title turns white), or a 3 pt capsule at the bottom inset 10 pt (title turns tint) — with .matchedGeometryEffect(id: "indicator", in: namespace), so it glides between options. Change the selection inside withAnimation(.spring(response: 0.35, dampingFraction: 0.8)), and add the .isSelected trait. With Reduce Motion on, use a 0.15 s ease.
            """#
        ) { SlidingTabsDemo() },
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
            api: "AuroraBackground()",
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

        // MARK: v0.3

        MotionEffect(
            id: "mesh-gradient",
            name: "Mesh Gradient",
            summary: "A 3×3 MeshGradient whose points drift so the colours flow like liquid.",
            component: .background,
            triggers: [.loop],
            requirement: .ios18,
            sourceFile: "Background/AnimatedMeshGradient.swift",
            api: "AnimatedMeshGradient()",
            usage: #"""
            if #available(iOS 18, *) {
                AnimatedMeshGradient()
                    .ignoresSafeArea()
            }
            """#,
            prompt: #"""
            Create a SwiftUI AnimatedMeshGradient view for iOS 18+ (mark it @available(iOS 18, macOS 15, visionOS 2, *)) with nine colours (indigo, purple, pink / blue, purple, orange / teal, mint, yellow by default; fewer are repeated) and a speed. Inside TimelineView(.animation), draw MeshGradient(width: 3, height: 3, points:colors:). Keep the four corners fixed; slide the four edge midpoints along their own edge by sin(t × 2π / period + offset) × 0.2, and move the centre point in both axes by 0.25, giving each a different period between 6 and 10 s so the motion never repeats visibly. Hide it from accessibility, and with Reduce Motion on, pause it.
            """#
        ) { MeshGradientDemo() },

        MotionEffect(
            id: "retro-grid",
            name: "Retro Grid",
            summary: "A synthwave floor: a perspective grid scrolling toward you.",
            component: .background,
            triggers: [.loop],
            sourceFile: "Background/RetroGrid.swift",
            api: "RetroGrid()",
            usage: #"""
            ZStack {
                Color.black
                RetroGrid(color: .pink)
                Text("NEON").font(.system(size: 60, weight: .black))
            }
            """#,
            prompt: #"""
            Create a SwiftUI RetroGrid view (iOS 17+) with color (pink), spacing (40 pt), speed (0.8 rows per second) and horizon (0.35 of the height). In a Canvas inside TimelineView(.animation): with top = height × horizon and depth = height − top, draw horizontal lines at y = top + depth / z for z = n + 1 − fract(time × speed), n = 0…39, so the bottom edge is z = 1, rows bunch up toward the horizon and every row moves toward the viewer; draw lines from the vanishing point (centre, top) to (centre + k × spacing, bottom) for enough k to cover the width. Stroke the path twice: 3 pt at 35 % opacity for a glow, then 1 pt solid. Mask the view with a vertical gradient that is clear down to the horizon and opaque 45 % lower, so lines fade into the distance. Hide from accessibility; Reduce Motion pauses it.
            """#
        ) { RetroGridDemo() },

        MotionEffect(
            id: "border-beam",
            name: "Border Beam",
            summary: "A short comet of light runs around the card's border forever.",
            component: .background,
            triggers: [.loop],
            sourceFile: "Background/BorderBeam.swift",
            api: ".borderBeam()",
            usage: #"""
            PlanCard()
                .background(.black, in: RoundedRectangle(cornerRadius: 20))
                .borderBeam(cornerRadius: 20)
            """#,
            prompt: #"""
            Create a SwiftUI .borderBeam(cornerRadius:colors:lineWidth:length:duration:) view modifier (iOS 17+). In an overlay TimelineView(.animation), compute head = fract(time / duration) (4 s per lap). Stroke RoundedRectangle(cornerRadius:, style: .continuous).trim(from: head − length, to: head) with a LinearGradient of the colours (orange, pink, purple), lineWidth 2 pt and round caps; when head − length is negative, also stroke trim(from: 1 + head − length, to: 1) so the beam wraps past the path's start seamlessly. Draw the beam twice, once blurred by 2 × lineWidth underneath for a glow. Pad by lineWidth / 2, disable hit testing and hide from accessibility. With Reduce Motion on, park the beam.
            """#
        ) { BorderBeamDemo() },

        MotionEffect(
            id: "waves",
            name: "Waves",
            summary: "Layered sine waves roll across the bottom, back layers slower and paler.",
            component: .background,
            triggers: [.loop],
            sourceFile: "Background/WaveBackground.swift",
            api: "WaveBackground()",
            usage: #"""
            ZStack(alignment: .top) {
                WaveBackground()
                    .ignoresSafeArea()
                Text("Ocean").font(.largeTitle.bold()).padding(.top, 80)
            }
            """#,
            prompt: #"""
            Create a SwiftUI WaveBackground view (iOS 17+) with colors (one per layer, back to front: cyan 35 %, blue 45 %, indigo 70 %), amplitude (12 pt) and speed. In a Canvas inside TimelineView(.animation), for each layer with depth d = layer / (count − 1): baseline at height × (0.45 + 0.2 d), wavelength width × (0.9 − 0.3 d), phase = time × (0.6 + 0.5 d), alternating direction per layer. Build a path from the bottom-left corner along y = baseline + sin(x / wavelength × 2π + phase + layer) × amplitude × (0.7 + 0.3 d) sampled every 4 pt, down to the bottom-right corner, close it and fill it with the layer's colour. Hide from accessibility; Reduce Motion pauses it.
            """#
        ) { WavesDemo() },

        MotionEffect(
            id: "grain",
            name: "Film Grain",
            summary: "Flickering film grain over any view, from a tiled noise texture.",
            component: .background,
            triggers: [.loop],
            sourceFile: "Background/Grain.swift",
            api: ".grain()",
            usage: #"""
            LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
                .grain()

            HeroImage()
                .grain(opacity: 0.2, isAnimated: false)
            """#,
            prompt: #"""
            Create a SwiftUI .grain(opacity:isAnimated:) view modifier (iOS 17+). Generate a 128 × 128 grey noise CGImage once (8-bit DeviceGray, random bytes from a seeded generator, no interpolation). In an overlay, show it with Image(decorative:scale: 2).resizable(resizingMode: .tile) in a frame 64 pt larger than the view in each direction, clipped, and shift it by a different offset (frame × 37 mod 64, frame × 53 mod 64) 12 times a second using TimelineView(.periodic(by: 1/12)), so the grain flickers like film. Use .blendMode(.overlay) at opacity (0.35), disable hit testing and hide it from accessibility. With Reduce Motion on (or isAnimated false), keep the grain still.
            """#
        ) { GrainDemo() },

        MotionEffect(
            id: "flashlight",
            name: "Flashlight",
            summary: "The view goes dark except a soft circle of light around the pointer.",
            component: .background,
            triggers: [.hover, .drag],
            sourceFile: "Background/Flashlight.swift",
            api: ".flashlight()",
            usage: #"""
            TreasureMap()
                .flashlight(radius: 100)
            """#,
            prompt: #"""
            Create a SwiftUI .flashlight(radius:darkness:) view modifier (iOS 17+). Track the pointer with .onContinuousHover(coordinateSpace: .local) and a finger with a simultaneous DragGesture(minimumDistance: 0), storing the location in @State (nil on exit) plus the last location. In an overlay GeometryReader, draw a RadialGradient from clear to black at darkness (0.85) opacity, centred on the location as a UnitPoint, from startRadius 0.55 × radius to endRadius radius (90 pt), so everything outside the circle is dark with a soft edge. Fade the whole overlay out when the pointer leaves (lights back on) with easeOut(0.4 s), and follow the pointer with .interactiveSpring(response: 0.18). Disable hit testing. With Reduce Motion on, move without animation.
            """#
        ) { FlashlightDemo() },
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
            api: "RollingNumber(value:)",
            usage: #"""
            RollingNumber(value: score)
                .font(.system(size: 48, weight: .bold, design: .rounded))
            """#,
            prompt: #"""
            Create a SwiftUI RollingNumber view (iOS 17+) that displays a number with odometer-style digit rolling. Render Text(value, format:) with monospacedDigit(), apply .contentTransition(.numericText(value:)) so digits roll up when the value increases and down when it decreases, and animate changes with .snappy. Provide initialisers for Int and for Double with a FloatingPointFormatStyle.
            """#
        ) { RollingNumberDemo() },
    ]

    // MARK: - Particle & 3D

    static let particle: [MotionEffect] = [        MotionEffect(
            id: "particle-field",
            name: "Particle Field",
            summary: "Drifting particles linked by faint lines, like a living constellation.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/ParticleField.swift",
            api: "ParticleField()",
            usage: #"""
            ZStack {
                Color.black.ignoresSafeArea()
                ParticleField(count: 60, color: .cyan)
                    .ignoresSafeArea()
                Text("Connected").font(.largeTitle.bold())
            }
            """#,
            prompt: #"""
            Create a SwiftUI ParticleField view (iOS 17+) with count (50), color, speed (14 pt/s) and linkDistance (70 pt). Generate each particle's traits once from a seeded SplitMix64 generator: start position (0…1 in each axis), direction, speed factor (0.4–1.2), radius (1–2.8 pt) and opacity (0.4–1). In TimelineView(.animation) with a Canvas, compute each position as start + direction × time × speed × factor, wrapped around the canvas edges, so there is no stored state. Stroke a 0.8 pt line between every pair closer than linkDistance with opacity 0.35 × (1 − distance / linkDistance), then fill each particle as a circle. Hide it from accessibility, and with Reduce Motion on, freeze time.
            """#
        ) { ParticleFieldDemo() },

        MotionEffect(
            id: "starfield",
            name: "Starfield",
            summary: "Stars stream out of the centre and stretch into streaks: warp speed.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/Starfield.swift",
            api: "Starfield()",
            usage: #"""
            Starfield()
                .background(.black)
                .ignoresSafeArea()

            Starfield(count: 300, speed: 1.5) // warp jump
            """#,
            prompt: #"""
            Create a SwiftUI Starfield view (iOS 17+) with count (200), speed (0.35 depth units per second) and color. Give each star a seeded random x and y in −1…1 and a depth in 0…1. In a Canvas inside TimelineView(.animation), compute z = 0.05 + 0.95 × fract(depth − time × speed), so stars approach the camera and wrap back to the far plane. Project with perspective: point = centre + (x, y) / z × 0.15 × half the larger side. Draw each star as a round-capped streak from its projection at a slightly larger z (z + min(0.08, speed × 0.05)) to its current projection, with opacity and line width growing as it gets closer. Hide it from accessibility, and with Reduce Motion on, freeze time.
            """#
        ) { StarfieldDemo() },

        MotionEffect(
            id: "cover-flow",
            name: "Cover Flow",
            summary: "Side items turn away in 3D, shrink and dim; the centre faces you.",
            component: .particle,
            triggers: [.scroll],
            sourceFile: "Particle/CoverFlow.swift",
            api: "CoverFlow(items) { item in }",
            usage: #"""
            CoverFlow(albums) { album in
                Image(album.artwork)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(height: 220)
            """#,
            prompt: #"""
            Create a generic SwiftUI CoverFlow carousel (iOS 17+) over Identifiable items with an optional selection binding, itemWidth (140), spacing (−10) and maxAngle (50°). Use a horizontal ScrollView + LazyHStack with .scrollTargetLayout(), .scrollTargetBehavior(.viewAligned), hidden indicators, .scrollPosition(id:anchor: .center) and contentMargins that centre the first and last items. In .visualEffect, read the item's frame in the .scrollView coordinate space, compute p = clamp((midX − viewport centre) / itemWidth, −1, 1) and apply rotation3DEffect of −p × maxAngle around the y axis (perspective 0.6), scale 1 − |p| × 0.18 and brightness −|p| × 0.25. Raise the selected item's zIndex. With Reduce Motion on, drop the rotation.
            """#
        ) { CoverFlowDemo() },

        MotionEffect(
            id: "float-3d",
            name: "Float 3D",
            summary: "The view hovers: a gentle bob, a slow 3D sway and a breathing shadow.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/Float3D.swift",
            api: ".float3D()",
            usage: #"""
            Image("product")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .float3D()

            BadgeView()
                .float3D(height: 6, angle: 8, period: 4, shadow: false)
            """#,
            prompt: #"""
            Create a SwiftUI .float3D(height:angle:period:shadow:) view modifier (iOS 17+). Inside TimelineView(.animation), let t = time × 2π / period (3 s) and lift = 0.5 + 0.5·sin t. Rotate the content in 3D by sin(t/2) × angle (12°) around the y axis and cos(0.7t) × angle/2 around the x axis (perspective 0.5), and move it up by height (10 pt) × lift. Behind it, at the bottom, draw a black ellipse 12 pt tall, 18 pt below, that gets lighter (opacity 0.25 − 0.1·lift), narrower (scale x 0.75 − 0.15·lift) and blurrier (6 + 4·lift) as the view rises. With Reduce Motion on, pause the timeline.
            """#
        ) { Float3DDemo() },

        // MARK: v0.3

        MotionEffect(
            id: "fireworks",
            name: "Fireworks",
            summary: "Rockets climb and burst into rings of falling, fading sparks.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/Fireworks.swift",
            api: "Fireworks()",
            usage: #"""
            ZStack {
                Color.black.ignoresSafeArea()
                Fireworks()
                    .ignoresSafeArea()
                Text("Happy New Year").font(.largeTitle.bold())
            }
            """#,
            prompt: #"""
            Create a SwiftUI Fireworks view (iOS 17+) with colors, interval (0.9 s between launches) and sparks (36 per burst), drawn statelessly in a Canvas inside TimelineView(.animation). Rocket k launches at k × interval; for every rocket younger than 0.8 s climb + 1.5 s fade, seed a SplitMix64 generator with k to pick x (15–85 % of the width), peak height (15–45 %), colour and reach (22–34 % of the smaller side). Climbing: ease-out from the bottom to the peak and draw a 14 pt trail. Bursting, with t = time since the burst / 1.5: place each spark at angle i / sparks × 2π (plus jitter), distance reach × (1 − (1 − min(1, 1.6 t))³) × random 0.75–1, add gravity fall t² × 0.6 × reach, draw a circle of radius 1.8 × (1 − 0.6 t) at opacity 1 − t, and add a white flash for the first 15 %. Hide from accessibility; with Reduce Motion on, freeze on a frame with a burst in bloom.
            """#
        ) { FireworksDemo() },

        MotionEffect(
            id: "snowfall",
            name: "Snowfall & Rain",
            summary: "Drifting, swaying snowflakes or fast slanted rain, with depth.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/Snowfall.swift",
            api: "Snowfall(.snow / .rain)",
            usage: #"""
            Snowfall()
                .background(.indigo)
                .ignoresSafeArea()

            Snowfall(.rain, count: 150, color: .white.opacity(0.8))
            """#,
            prompt: #"""
            Create a SwiftUI Snowfall view (iOS 17+) with a style (.snow or .rain), count (80), color and speed. Give each particle seeded random traits: start x and y (0–1), depth (0–1) and phase. In a Canvas inside TimelineView(.animation), compute positions as pure functions of time, wrapped around the view so nothing is stored. Snow: fall speed 18 + 30 × depth pt/s, horizontal sway sin(time × (0.8 + depth) + phase) × (6 + 10 × depth) plus a slow 4 pt/s drift, radius 1 + 2.4 × depth, opacity 0.35 + 0.6 × depth, so small flakes look far away. Rain: fall speed 380 + 320 × depth, a streak 8 + 14 × depth long slanted by 0.25, width 0.8 + 0.8 × depth, opacity 0.25 + 0.5 × depth. Hide from accessibility; Reduce Motion pauses it.
            """#
        ) { SnowfallDemo() },

        MotionEffect(
            id: "floating-reactions",
            name: "Floating Reactions",
            summary: "Live-stream style emoji float up, swaying, every time you react.",
            component: .particle,
            triggers: [.tap, .change],
            sourceFile: "Particle/FloatingReactions.swift",
            api: ".floatingReactions(trigger:)",
            usage: #"""
            LiveVideo()
                .floatingReactions(trigger: reactionCount)

            Button("❤️") { reactionCount += 1 }
            """#,
            prompt: #"""
            Create a SwiftUI .floatingReactions(trigger:emojis:height:) view modifier (iOS 17+). Every time trigger changes, append a reaction (UUID, a random emoji from the list, a random sway of ±8–18 pt and drift of ±20 pt) to a @State array and remove it 2.3 s later. In a bottom-aligned, hit-testing-disabled overlay, show each emoji (28 pt) with keyframeAnimator(initialValue:trigger:), triggered by a @State flag set in onAppear so it plays once, over {y, x, scale, opacity}: y goes to −height (160 pt) over 2.2 s; x weaves sway → −sway + drift → sway + drift → drift in four 0.55 s cubic keyframes; scale springs from 0.3 to 1.15 and settles at 1; opacity holds for 1.4 s then fades over 0.8 s. With Reduce Motion on, don't spawn reactions.
            """#
        ) { FloatingReactionsDemo() },

        MotionEffect(
            id: "warp-tunnel",
            name: "Warp Tunnel",
            summary: "Rings rush out of the vanishing point toward you: flying down a tunnel.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/WarpTunnel.swift",
            api: "WarpTunnel()",
            usage: #"""
            WarpTunnel()
                .background(.black)
                .ignoresSafeArea()

            WarpTunnel(colors: [.green, .mint], sides: 6) // hexagons
            """#,
            prompt: #"""
            Create a SwiftUI WarpTunnel view (iOS 17+) with rings (18), colors (cyan, blue, purple, pink), speed (1.2 rings per second) and sides (0 for circles, 3+ for polygons). In a Canvas inside TimelineView(.animation), for ring i let depth = 1 − (i + fract(time × speed)) / rings and skip depths below 0.02. Its radius is half the view's diagonal × 0.06 / depth (perspective), skipped once it's 1.5 × larger than that. Stroke a circle, or a polygon rotated by i × 0.12 + time × 0.1 rad, centred in the view, with opacity closeness² and line width 0.5 + 3 × closeness (closeness = 1 − depth), cycling colours by ring. Hide from accessibility; Reduce Motion pauses it.
            """#
        ) { WarpTunnelDemo() },

        MotionEffect(
            id: "holo-card",
            name: "Holographic Card",
            summary: "A trading card that tilts toward you with a rainbow foil and moving glare.",
            component: .particle,
            triggers: [.hover, .drag],
            sourceFile: "Particle/Holographic.swift",
            api: ".holographic()",
            usage: #"""
            Image("card-art")
                .resizable()
                .aspectRatio(5 / 7, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .holographic(cornerRadius: 16)
            """#,
            prompt: #"""
            Create a SwiftUI .holographic(cornerRadius:maxAngle:) view modifier (iOS 17+). Track the pointer with .onContinuousHover and a finger with a simultaneous DragGesture(minimumDistance: 0), normalising the location to p in −1…1 on both axes (nil when released). Overlay, clipped to a continuous rounded rectangle: (1) a rainbow LinearGradient (red → … → purple → red) from (−0.5 + 0.6 px, −0.5 + 0.3 py) to (1.5 + 0.6 px, 1.5 + 0.3 py) with .blendMode(.overlay), at 55 % opacity while touched and 15 % at rest; (2) a white 70 % → clear RadialGradient centred at (0.5 + 0.5 px, 0.5 + 0.5 py) with .blendMode(.softLight), visible only while touched. Tilt with rotation3DEffect: −py × maxAngle (14°) around x and px × maxAngle around y, perspective 0.6, and scale to 1.03 while touched. Follow with .interactiveSpring(response: 0.25) and release with .spring(response: 0.5, dampingFraction: 0.6). With Reduce Motion on, keep the foil and glare but don't tilt or scale.
            """#
        ) { HolographicDemo() },
    ]

    // MARK: - Transition

    static let transition: [MotionEffect] = [
        MotionEffect(
            id: "iris",
            name: "Iris",
            summary: "A circle opens from a point to reveal the view, like a camera iris.",
            component: .transition,
            triggers: [.appear],
            sourceFile: "Transition/MaskTransitions.swift",
            api: ".transition(.iris)",
            usage: #"""
            if showPhoto {
                PhotoView()
                    .transition(.iris)
            }

            DetailView()
                .transition(.iris(origin: .topTrailing))
            """#,
            prompt: #"""
            Create a custom SwiftUI Transition (iOS 17+, the Transition protocol) called IrisTransition with an origin UnitPoint (centre), exposed as .iris and .iris(origin:). In body(content:phase:), mask the content with a GeometryReader containing a Circle whose radius is the distance from the origin point to the furthest corner, positioned at the origin, with scaleEffect(phase.isIdentity ? 1 : 0.001, anchor: origin). The circle grows from the origin to cover the view on insertion and closes back on removal, timed by whatever animation drives the change, e.g. withAnimation(.easeInOut(duration: 0.6)). It only masks, so it needs no Reduce Motion fallback.
            """#
        ) { TransitionDemo(transition: .iris) },

        MotionEffect(
            id: "blinds",
            name: "Blinds",
            summary: "Horizontal slats open together to reveal the view, like Venetian blinds.",
            component: .transition,
            triggers: [.appear],
            sourceFile: "Transition/MaskTransitions.swift",
            api: ".transition(.blinds)",
            usage: #"""
            Banner()
                .transition(.blinds)

            Poster()
                .transition(.blinds(slats: 12))
            """#,
            prompt: #"""
            Create a custom SwiftUI Transition (iOS 17+) called BlindsTransition with a slats count (8), exposed as .blinds and .blinds(slats:). In body(content:phase:), mask the content with a VStack(spacing: 0) of slats Rectangles, each with scaleEffect(y: phase.isIdentity ? 1 : 0.001, anchor: .top), so every slat grows down from its top edge at the same time on insertion and folds back up on removal. It only masks, so it needs no Reduce Motion fallback.
            """#
        ) { TransitionDemo(transition: .blinds) },

        MotionEffect(
            id: "clock-wipe",
            name: "Clock Wipe",
            summary: "A wedge sweeps clockwise from twelve o'clock, like a clock hand.",
            component: .transition,
            triggers: [.appear],
            sourceFile: "Transition/MaskTransitions.swift",
            api: ".transition(.clockWipe)",
            usage: #"""
            Badge()
                .transition(.clockWipe)
            """#,
            prompt: #"""
            Create a custom SwiftUI Transition (iOS 17+) called ClockWipeTransition, exposed as .clockWipe. Mask the content with an animatable Shape whose animatableData is progress (0…1): it returns the full rect at 1, an empty path at 0, and otherwise a pie wedge from the centre with radius equal to the rect's diagonal, from −90° to −90° + 360° × progress (clockwise: false, which sweeps clockwise on screen in SwiftUI's y-down space). Pass progress 1 when phase.isIdentity and 0 otherwise, so the animation interpolates the angle. It only masks, so it needs no Reduce Motion fallback.
            """#
        ) { TransitionDemo(transition: .clockWipe, duration: 1) },

        MotionEffect(
            id: "dissolve",
            name: "Pixel Dissolve",
            summary: "The view appears and vanishes in square pixels, in random order.",
            component: .transition,
            triggers: [.appear],
            sourceFile: "Transition/MaskTransitions.swift",
            api: ".transition(.dissolve)",
            usage: #"""
            Avatar()
                .transition(.dissolve)

            Artwork()
                .transition(.dissolve(cellSize: 6))
            """#,
            prompt: #"""
            Create a custom SwiftUI Transition (iOS 17+) called DissolveTransition with a cellSize (10 pt), exposed as .dissolve and .dissolve(cellSize:). Mask the content with an animatable Shape whose animatableData is progress (0…1): divide the rect into a grid of cellSize squares, give each cell a stable pseudo-random threshold in 0…1 from an integer hash of (column, row), and add the cells whose threshold is below progress (outset by 0.25 pt so neighbours don't leave seams); return the full rect at 1 and an empty path at 0. Pass progress 1 when phase.isIdentity and 0 otherwise. It only masks, so it needs no Reduce Motion fallback.
            """#
        ) { TransitionDemo(transition: .dissolve, duration: 1) },

        MotionEffect(
            id: "poof",
            name: "Poof",
            summary: "The view puffs away like smoke: it swells and blurs out.",
            component: .transition,
            triggers: [.appear],
            sourceFile: "Transition/StyleTransitions.swift",
            api: ".transition(.poof)",
            usage: #"""
            ForEach(notes) { note in
                NoteRow(note)
                    .transition(.poof)
            }
            """#,
            prompt: #"""
            Create a custom SwiftUI Transition (iOS 17+) called PoofTransition, exposed as .poof. Return a small view that reads Reduce Motion and applies: scale 1.35 when phase == .didDisappear, 0.7 when .willAppear, 1 at identity; blur radius 14 when not identity, 0 at identity; opacity 0 when not identity. Removal swells and blurs away like smoke, insertion condenses in from a smaller blur. With Reduce Motion on, keep the scale at 1 (blur and fade only).
            """#
        ) { TransitionDemo(transition: .poof, duration: 0.5) },

        MotionEffect(
            id: "swoosh",
            name: "Swoosh",
            summary: "The view whooshes in leaning forward, with a motion blur.",
            component: .transition,
            triggers: [.appear],
            sourceFile: "Transition/StyleTransitions.swift",
            api: ".transition(.swoosh)",
            usage: #"""
            if let toast {
                ToastView(toast)
                    .transition(.swoosh)
            }
            """#,
            prompt: #"""
            Create a custom SwiftUI Transition (iOS 17+) called SwooshTransition, exposed as .swoosh. Use phase.value (−1 before insertion, 0 at rest, +1 after removal) as v and apply a GeometryEffect whose animatableData is v: a CGAffineTransform with c = −0.6 v (a horizontal skew) and tx = v × width − c × height / 2 (slide by the view's own width, skewing around the vertical centre). Add blur 6 × |v| and opacity 1 − |v|, so it whooshes in from the leading edge leaning into the motion and leaves to the trailing edge. With Reduce Motion on, skip the slide and skew (fade only).
            """#
        ) { TransitionDemo(transition: .swoosh, duration: 0.6) },

        MotionEffect(
            id: "film-exposure",
            name: "Film Exposure",
            summary: "The view develops like a photo, from over-exposed white to full colour.",
            component: .transition,
            triggers: [.appear],
            sourceFile: "Transition/StyleTransitions.swift",
            api: ".transition(.filmExposure)",
            usage: #"""
            AsyncImage(url: url) { image in
                image.resizable()
                    .transition(.filmExposure)
            } placeholder: {
                ProgressView()
            }
            """#,
            prompt: #"""
            Create a custom SwiftUI Transition (iOS 17+) called FilmExposureTransition, exposed as .filmExposure. When the phase isn't identity, apply brightness 0.9, saturation 0 and opacity 0; at identity, brightness 0, saturation 1 and opacity 1. Inserting the view develops it like a photo, from blown-out colourless white to full colour, and removing it fades it back out to white. Nothing moves, so it needs no Reduce Motion fallback.
            """#
        ) { TransitionDemo(transition: .filmExposure, duration: 1) },
    ]
}
