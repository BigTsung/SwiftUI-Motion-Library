import SwiftUI
import MotionLibrary

/// Every effect in the library, in display order.
///
/// To add an effect: implement it in `Sources/MotionLibrary/<Component>/`,
/// add a demo view in `Demos.swift`, then append an entry here.
/// See CONTRIBUTING.md for the checklist.
public enum MotionCatalog {
    public static let all: [MotionEffect] = text + button + card + shape + background + number + particle

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
    ]
}
