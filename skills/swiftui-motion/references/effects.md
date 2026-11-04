# Effect reference

Usage and implementation notes for every effect. Full source: https://raw.githubusercontent.com/BigTsung/SwiftUI-Motion-Library/main/llms-full.txt

## Typewriter

Characters appear one by one with a blinking cursor. Trigger: Appear / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Text/TypewriterText.swift.

```swift
TypewriterText("Hello, SwiftUI!", interval: .milliseconds(60))
    .font(.title.bold())
```

How it works: Create a SwiftUI "typewriter" text view (iOS 17+). It reveals a string one character at a time at a fixed interval (default 60 ms), followed by a cursor character "|" in the accent color that blinks every 0.5 s. Implementation: keep a @State visibleCount, render Text(String(text.prefix(visibleCount))) concatenated with the cursor Text, and drive it from .task(id: text) with Task.sleep so it restarts when the text changes and cancels when the view disappears. Use the full text as the accessibility label.

## Scramble / Decode

Random glyphs resolve into the real text from left to right. Trigger: Appear / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Text/ScrambleText.swift.

```swift
ScrambleText("ACCESS GRANTED", duration: 1.0)
    .font(.title.bold())
```

How it works: Create a SwiftUI "decode" text effect (iOS 17+). On appear, every character of the string is shown as a random glyph from a charset (A–Z, 0–9, #%&*), re-randomised every 30 ms. Over the given duration, characters lock into their real values from left to right until the full string is shown. Spaces never scramble. Use a monospaced font design so the width doesn't jitter, drive frames from .task(id: text) with Task.sleep, and set the real string as the accessibility label.

## Shimmer

A band of light sweeps across text or skeleton placeholders. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/Shimmer.swift.

```swift
Text("Loading…")
    .font(.title)
    .shimmer()

RoundedRectangle(cornerRadius: 8)
    .fill(.gray.opacity(0.3))
    .frame(height: 44)
    .shimmer(duration: 1.2)
```

How it works: Create a reusable SwiftUI .shimmer() view modifier (iOS 17+). A soft white highlight band (a horizontal LinearGradient clear → white 80% → clear, about 35% of the view width) moves from just off the left edge to just off the right edge, repeating forever with linear timing (~1.6 s). The band is placed in an overlay with a GeometryReader and masked by the original content so it only lights up the view's own pixels (text glyphs or skeleton shapes). It must not intercept touches and should accept isActive, duration, bandWidth and highlight color parameters.

## Gradient Sweep

A multi-colour gradient flows through the letters forever. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/GradientSweep.swift.

```swift
Text("Motion Library")
    .font(.largeTitle.weight(.heavy))
    .gradientSweep()

Image(systemName: "sparkles")
    .font(.system(size: 60))
    .gradientSweep(colors: [.yellow, .orange, .pink], duration: 2)
```

How it works: Create a SwiftUI .gradientSweep(colors:duration:) view modifier (iOS 17+) that paints a view's own pixels with a flowing multi-colour gradient. In an overlay, use a GeometryReader to draw a horizontal LinearGradient twice as wide as the view whose colours are the palette repeated twice plus the first colour again (so the right half matches the left half). Offset it from 0 to −width with a linear animation that repeats forever without autoreversing, so the loop is seamless. Mask the overlay with the original content so only glyphs or shapes are coloured, and disable hit testing. Default palette pink, orange, yellow, mint, cyan, purple over 3 s. With Reduce Motion on, show the gradient without moving it.

## Blur-in Words

Words come into focus one after another: fade, rise and un-blur. Trigger: Appear / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Text/BlurInText.swift.

```swift
BlurInText("Design is how it works.")
    .font(.title.weight(.semibold))

BlurInText("Letter by letter", by: .character, stagger: 0.03)
```

How it works: Create a SwiftUI BlurInText view (iOS 17+) that reveals a string piece by piece, split by word (default) or by character. Lay the pieces out with a custom Layout that flows left to right, wraps to new lines and centres each line; the gap between words is about 0.28 × the line height. Each piece starts at opacity 0, blur radius 8 and 8 pt lower, and animates to opacity 1, no blur and no offset with easeOut(0.6 s), delayed by index × stagger (0.08 s default). Replay when the text changes by resetting a revealed flag and setting it again on the next run loop. Expose the whole string as one accessibility label. With Reduce Motion on, only fade.

## Marquee

Text too long for its line scrolls sideways forever, with faded edges. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/MarqueeText.swift.

```swift
MarqueeText("Now playing: Midnight Drive — Neon Coast")
    .font(.headline)
    .frame(width: 200)

MarqueeText(longTitle, speed: 60, gap: 24)
```

How it works: Create a SwiftUI MarqueeText view (iOS 17+) for a single line of text. Measure the text's natural width (fixedSize text with a GeometryReader background) and the container width. If the text fits, show it still. If not, show two copies in an HStack separated by a gap (40 pt) and offset them left by (time × speed) modulo (textWidth + gap) using TimelineView(.animation), so the second copy takes the first copy's place and the loop is seamless. Speed defaults to 40 pt/s. Clip to the container and mask the edges with 16 pt linear fades. Reserve one line of height with a hidden copy of the text. Expose the full text to accessibility, and with Reduce Motion on, don't scroll.

## Wave Text

Letters bob in a travelling wave, drawn with a TextRenderer. Trigger: Loop. Requires iOS 18+. Files: Sources/MotionLibrary/Text/WaveText.swift.

```swift
if #available(iOS 18, *) {
    WaveText("Making waves")
        .font(.largeTitle.bold())
        .foregroundStyle(.blue)
}
```

How it works: Create a SwiftUI WaveText view for iOS 18+ (mark it @available(iOS 18, macOS 15, visionOS 2, *)) that makes each letter bob up and down in a travelling wave while keeping normal text layout. Implement a TextRenderer whose draw(layout:in:) walks every line, run and glyph, keeps a running glyph index, copies the GraphicsContext, translates it vertically by sin((index / wavelength − time × speed) × 2π) × amplitude, and draws the glyph. Set displayPadding to the amplitude above and below so nothing clips. Drive time from TimelineView(.animation) and apply the renderer with .textRenderer. Defaults: amplitude 5 pt, wavelength 8 letters, 1 wave per second. With Reduce Motion on, pause the timeline and use zero amplitude.

## Count Up

A number counts up from zero, and from old to new value on change. Trigger: Appear / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Text/CountUpText.swift.

```swift
CountUpText(value: revenue, prefix: "$")
    .font(.largeTitle.bold())

CountUpText(value: 98.6, fractionDigits: 1, suffix: "%", duration: 2)
```

How it works: Create a SwiftUI CountUpText view (iOS 17+) with value, duration (1.4 s), fractionDigits (0), prefix and suffix. Keep a @State shown value starting at 0; on appear and whenever value changes, set shown = value inside withAnimation(.easeOut(duration:)). Render through a private view that conforms to both View and Animatable (animatableData = the number) so SwiftUI calls body on every frame with the interpolated value, and format it with value.formatted(.number.precision(.fractionLength(fractionDigits))) between prefix and suffix. Use .monospacedDigit() so the width doesn't jitter, and give it the final formatted value as its accessibility label. With Reduce Motion on, jump straight to the value.

## Split Text

Letters rise into place one after another with a small overshoot. Trigger: Appear / Value change. Requires iOS 18+. Files: Sources/MotionLibrary/Text/SplitText.swift.

```swift
if #available(iOS 18, *) {
    SplitText("Letters take the stage")
        .font(.largeTitle.bold())
}
```

How it works: Create a SwiftUI SplitText view for iOS 18+ (mark it @available(iOS 18, macOS 15, visionOS 2, *)) with duration per letter (0.5 s), stagger (0.035 s) and distance (18 pt). Apply a TextRenderer that is also Animatable, with a progress value 0…1 as animatableData. In draw(layout:in:), count all glyphs, then for glyph i compute start = spread × i / (count − 1), where spread is the share of the total time taken by the delays, and local = clamp((progress − start) / (1 − spread), 0, 1). Copy the GraphicsContext, set opacity to min(1, local × 2), translate it down by (1 − backOut(local)) × distance (backOut: ease-out with ~1.7 overshoot) and draw the glyph. Set displayPadding at the bottom to distance. In .task(id: string), reset progress to 0 without animation, then animate it to 1 with linear timing over duration + stagger × (count − 1). With Reduce Motion on, use zero distance (a fade).

## Rotating Text

Words take turns: the current one slides up and out as the next rises in. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/RotatingText.swift.

```swift
HStack {
    Text("We")
    RotatingText(["design", "build", "ship"])
        .foregroundStyle(.blue)
}
.font(.largeTitle.bold())
```

How it works: Create a SwiftUI RotatingText view (iOS 17+) that cycles through an array of words every interval (2 s). Keep a @State index and show Text(words[index]).id(index) inside a ZStack with .fixedSize() and .clipped(). Give the text an asymmetric transition: insertion .move(edge: .bottom) combined with .opacity, removal .move(edge: .top) combined with .opacity. Drive it from .task with a loop of Task.sleep followed by withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { index += 1 }, so the width also springs to fit each word. Expose all words joined by commas as the accessibility label. With Reduce Motion on, use a plain opacity transition.

## Glitch

Every few seconds the view tears: an RGB split, sliced rows and jitter. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/Glitch.swift.

```swift
Text("SYSTEM FAILURE")
    .font(.title.monospaced().bold())
    .glitch()

Image("logo")
    .glitch(intensity: 2, interval: 4)
```

How it works: Create a SwiftUI .glitch(isActive:intensity:interval:) view modifier (iOS 17+) that works on any view. Use TimelineView(.animation(minimumInterval: 1/24)) and derive everything from the clock: glitch during the first 0.35 s of every interval (2 s); within that window pick new pseudo-random values 24 times a second from a cheap integer hash of (frame, salt). While glitching: (1) behind the content, draw two silhouettes of it, content.brightness(1).colorMultiply(.cyan) offset left and content.brightness(1).colorMultiply(.red) offset right by 2–6 pt × intensity, at 85 % opacity; (2) in an overlay, draw a copy of the content offset sideways by up to ±12 pt, masked to a horizontal strip at a random height (10–35 % of the view tall); (3) jitter the whole view by up to ±1.5 pt. Outside the window, show the content untouched. With Reduce Motion on, don't glitch at all.

## Circular Text

Text wrapped around a circle that slowly turns, like a rotating badge. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/CircularText.swift.

```swift
ZStack {
    CircularText("SWIFTUI • MOTION • LIBRARY • ", radius: 60)
        .font(.caption.monospaced().bold())
    Image(systemName: "sparkles").font(.largeTitle)
}
```

How it works: Create a SwiftUI CircularText view (iOS 17+) with text, radius (60 pt) and speed (20° per second). Split the string into characters and place each one in a ZStack as Text(character).offset(y: −radius).rotationEffect(.degrees(index / count × 360)), so letters stand evenly spaced around the circle. Wrap the ZStack in TimelineView(.animation) and rotate it by time × speed degrees (modulo 360). Frame it to 2 × radius plus 12 pt padding. Use the full text as a single accessibility label. With Reduce Motion on (or speed 0), pause the timeline.

## Focus Text

Focus hops from word to word: sharp and bracketed, the rest blurred. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/FocusText.swift.

```swift
FocusText("Motion made simple")
    .font(.title.bold())

FocusText("Plan Build Ship", interval: 0.8, bracketColor: .pink)
```

How it works: Create a SwiftUI FocusText view (iOS 17+) that splits a sentence into words in an HStack (10 pt spacing). A @State focus index advances every interval (1.2 s) in a .task loop with withAnimation(.spring(response: 0.45, dampingFraction: 0.8)). Unfocused words get blur radius 3 and opacity 0.55; the focused word is sharp. Behind the focused word only, draw four L-shaped corner brackets (Canvas, 2.5 pt round strokes, arms 8 pt, 2 pt outside the word's padded frame) and give them .matchedGeometryEffect(id: "focus", in: namespace) so the brackets glide and resize from word to word. Use the sentence as the accessibility label. With Reduce Motion on, use a short ease instead of the spring.

## Highlighter

A marker pen swipes across the text, or underlines it, left to right. Trigger: Appear / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Text/Highlighter.swift.

```swift
Text("the important part")
    .highlighter()

Text("Pricing")
    .highlighter(isActive: isSelected, color: .pink, style: .underline)
```

How it works: Create a SwiftUI .highlighter(isActive:color:style:duration:) view modifier (iOS 17+) with two styles. In a background GeometryReader, draw a rounded rectangle 6 pt wider than the text: for .marker, 55 % of the text height, yellow at 45 % opacity, rotated −1.2° and sitting over the lower half; for .underline, a full-opacity capsule about 10 % of the height (at least 3 pt) at the baseline. Scale it horizontally from 0 to 1 with anchor .leading, animated with easeOut(0.6 s) on appear and whenever isActive changes, so it swipes on from the left and back off. Disable hit testing and hide it from accessibility. With Reduce Motion on, switch it without animation.

## Morphing Text

Words melt into each other with a gooey, liquid morph. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/MorphingText.swift.

```swift
MorphingText(["Design", "Build", "Ship"])
    .font(.system(size: 44, weight: .black, design: .rounded))
```

How it works: Create a SwiftUI MorphingText(_ words:interval:morphDuration:color:) view (iOS 17+) that cycles through words with a gooey morph. Size it with hidden copies of every word in a ZStack and draw in an overlay Canvas padded out by 12 pt. In TimelineView(.animation), word index = Int(time / interval) % count; the morph runs over the last morphDuration (0.9 s) of each interval (2.2 s) with smoothstep progress p. In the Canvas, add .alphaThreshold(min: 0.3, color: color) then .blur(radius: 1.5), and inside drawLayer draw the outgoing word (resolved symbol, tagged by index) with its own .blur(radius: 6 × p) and opacity min(1, 2(1 − p)), and the incoming word with blur 6 × (1 − p) and opacity min(1, 2p), both centred; keeping both opaque through the middle stops the blob thinning out below the threshold. The threshold turns the overlapping blurry glyphs into one liquid shape. With Reduce Motion on, cross-fade plain Text views on a TimelineView(.periodic). Set the accessibility label to the words.

## Neon Flicker

A glowing neon tube that stutters on and glitches now and then. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/NeonFlicker.swift.

```swift
Text("OPEN")
    .font(.system(size: 48, weight: .bold, design: .rounded))
    .neon(color: .pink)
```

How it works: Create a SwiftUI .neon(color:flicker:) view modifier (iOS 17+) for text or symbols on a dark background. Draw the content white when lit (or the colour at 55 % opacity when it drops out) and stack three shadows in the colour: radius 2 (opacity = level), 8 (0.9 × level) and 18 (0.7 × level), with overall opacity 0.35 + 0.65 × level. With flicker on, drive level from TimelineView(.animation) over a 6 s cycle: a stuttering switch-on with dips to 0.1 (0–0.08 s), 0.2 (0.14–0.18 s), 0.15 (0.26–0.30 s) and 0.5 (0.38–0.40 s), a glitch at 4.20–4.45 s (0.3, 0.15, 0.6), otherwise a faint hum of 0.94 + 0.06 × sin(time × 40). With Reduce Motion on, keep a steady glow with no flicker.

## Karaoke Text

A line fills with colour left to right as progress goes from 0 to 1. Trigger: Value change / Scroll. Requires iOS 17+. Files: Sources/MotionLibrary/Text/KaraokeText.swift.

```swift
KaraokeText("Never gonna stop the music", progress: playback, highlight: .pink)
    .font(.title2.bold())
```

How it works: Create a SwiftUI KaraokeText(_:progress:highlight:base:feather:) view (iOS 17+): a single-line Text in the base colour (secondary at 50 %) with an overlay of the same Text in the highlight colour, masked (alignment .leading) by an HStack in a GeometryReader: a Rectangle of width max(0, (width + feather) × progress − feather) followed by a LinearGradient black → clear of width feather (14 pt), so progress 0 shows nothing, 1 shows everything and the leading edge is soft. progress is clamped to 0…1 and changes to it animate because the frame width animates. Hide the overlay from accessibility.

## Weight Wave

Letters swell from thin to black and back in a travelling wave. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/WeightWaveText.swift.

```swift
WeightWaveText("Variable weight")
    .font(.system(size: 36, design: .rounded))
```

How it works: Create a SwiftUI WeightWaveText(_:speed:wavelength:) view (iOS 17+) that lays the characters out in an HStack(spacing: 0) inside TimelineView(.animation). Each character gets .fontWeight from the nine weights ultraLight…black, indexed by level = (sin(2π × (index / wavelength − time × speed)) + 1) / 2 (wavelength 8 letters, speed 0.6 waves/s), so a swell of bold travels through the word. The font comes from the environment. With Reduce Motion on, pause the timeline and use .regular. Combine into one accessibility element labelled with the string.

## Exploding Text

Letters blast apart spinning and spring back into place. Trigger: Value change / Tap. Requires iOS 18+. Files: Sources/MotionLibrary/Text/ExplodingText.swift.

```swift
ExplodingText("Kaboom!", isExploded: exploded)
    .font(.system(size: 44, weight: .heavy, design: .rounded))
    .onTapGesture { exploded.toggle() }
```

How it works: Create a SwiftUI ExplodingText(_:isExploded:distance:) view (iOS 18+) using a TextRenderer that is Animatable over progress (0 = assembled, 1 = scattered). Its displayPadding is distance on every side (60 pt). In draw(layout:in:), for each glyph (counted across lines and runs) take three stable pseudo-random values r0, r1, r2 from a hash of its index; translate by (cos, sin)(r0 × 2π) × distance × (0.5 + 0.5 × r1) × progress, rotate around the glyph's typographic-bounds centre by (r2 − 0.5) × 540° × progress, and set opacity 1 − 0.7 × progress. Animate with .easeOut(0.45 s) when exploding and .spring(duration: 0.8, bounce: 0.35) when reassembling. With Reduce Motion on, use distance 0 (just a fade) and a 0.3 s ease. Keep the string as the accessibility label.

## Liquid Fill Text

A wavy water line rises inside the letters as progress grows. Trigger: Value change / Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Text/LiquidFillText.swift.

```swift
LiquidFillText("\(Int(level * 100))%", progress: level, color: .cyan)
    .font(.system(size: 64, weight: .black, design: .rounded))
```

How it works: Create a SwiftUI LiquidFillText(_:progress:color:waveHeight:) view (iOS 17+). Draw the Text in the colour at 15 % opacity as an empty glass, then overlay a TimelineView(.animation) with a ZStack of two wave shapes, masked by the same Text: a back wave in the colour at 45 % (phase = time × 2.2 + 1.3, amplitude 0.8 × waveHeight) and a front wave in the full colour (phase = time × 3, amplitude waveHeight, default 6 pt). The wave Shape has level, phase and amplitude, animates level, and fills everything below y = baseline + amplitude × sin(x / width × 3π + phase). A line of text has descender room below the glyphs and space above the caps, so fill between bottom = maxY − 0.2 × height + 2 × amplitude and top = minY + 0.12 × height − 2 × amplitude: baseline = bottom − (bottom − top) × level, so 0 is empty and 1 full. Clamp progress to 0…1 and animate level changes with .spring(duration: 0.9, bounce: 0.25). With Reduce Motion on, pause the timeline (the level still animates). Hide the overlay from accessibility; the label is the text.

## Pressable

Button squashes and darkens on press, then springs back with a light haptic. Trigger: Press. Requires iOS 17+. Files: Sources/MotionLibrary/Button/PressableButtonStyle.swift, Sources/MotionLibrary/Support/Haptics.swift.

```swift
Button("Continue") { }
    .buttonStyle(.pressable)

Button("Big squish") { }
    .buttonStyle(.pressable(scale: 0.85))
```

How it works: Create a SwiftUI ButtonStyle called PressableButtonStyle (iOS 17+). While pressed, the label scales to 0.94 and its brightness drops slightly (-0.06); on release it springs back using .spring(response: 0.3, dampingFraction: 0.6). Fire a light impact haptic with .sensoryFeedback only when the press begins. Expose it as .buttonStyle(.pressable) and .buttonStyle(.pressable(scale:haptics:)) via a static extension on ButtonStyle.

## Tap Ripple

A circular ripple expands from the exact tap location. Trigger: Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Button/Ripple.swift.

```swift
Text("Tap")
    .frame(width: 200, height: 60)
    .background(.indigo, in: RoundedRectangle(cornerRadius: 12))
    .ripple(color: .white, cornerRadius: 12)
```

How it works: Create a SwiftUI .ripple() view modifier (iOS 17+) that shows a Material-style ripple. Use a simultaneous SpatialTapGesture so it doesn't block the view's own button action. Each tap appends a ripple at the tap location; each ripple is a translucent circle (white, 35% opacity) sized to 2× the view's diagonal that scales from ~0 to 1 while fading to 0 with easeOut over 0.7 s, then is removed. Ripples are drawn in an overlay clipped to a rounded rectangle with a configurable corner radius and never intercept touches. Multiple quick taps should produce overlapping ripples.

## Error Shake

Horizontal "no" shake for wrong input, triggered by a value change. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Button/Shake.swift.

```swift
@State private var attempts = 0

SecureField("Password", text: $password)
    .shake(trigger: attempts)
    .sensoryFeedback(.error, trigger: attempts)

// On a failed login:
attempts += 1
```

How it works: Create a SwiftUI .shake(trigger:) view modifier (iOS 17+) for error feedback. Every time the Equatable trigger changes, the view shakes horizontally using keyframeAnimator on an x offset: -10, +10, -7, +7, -3 points (≈0.07 s each, cubic keyframes) and then settles back to 0 with a bouncy SpringKeyframe. Amplitude should be configurable. Pair it with .sensoryFeedback(.error, trigger:) for haptics.

## Magnetic Button

The button drifts toward a nearby pointer or dragging finger, then springs home. Trigger: Hover / Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Button/Magnetic.swift.

```swift
Button("Get started") { }
    .buttonStyle(.borderedProminent)
    .magnetic()

Image(systemName: "plus.circle.fill")
    .font(.system(size: 44))
    .magnetic(strength: 0.5, radius: 40)
```

How it works: Create a SwiftUI .magnetic(strength:radius:) view modifier (iOS 17+) that pulls a view toward the pointer. Pad the view by `radius` (60 pt) to enlarge its tracking area, give it a rectangular contentShape, measure the padded size with a GeometryReader background, then remove the padding again with .padding(-radius). In onContinuousHover (pointer on iPad, Mac and visionOS) and in a simultaneous DragGesture(minimumDistance: 0) (touch), offset the original content by (location − centre) × strength (0.3) using an interactiveSpring(response 0.25, damping 0.7). When hover ends or the drag ends, spring back to zero with spring(response 0.45, damping 0.45) for a little overshoot. With Reduce Motion on, don't move.

## Hold to Confirm

Liquid fills the button while you hold; the action runs only when it's full. Trigger: Press. Requires iOS 17+. Files: Sources/MotionLibrary/Button/HoldToConfirmButton.swift, Sources/MotionLibrary/Support/Haptics.swift.

```swift
HoldToConfirmButton("Hold to delete") {
    deleteAccount()
}

HoldToConfirmButton(duration: 2, fillColor: .orange) {
    launch()
} label: {
    Label("Hold to launch", systemImage: "flame")
}
```

How it works: Create a SwiftUI HoldToConfirmButton (iOS 17+) for destructive actions. A capsule with a 15% tint of fillColor (red) shows the label in fillColor. While pressed (onLongPressGesture(minimumDuration:perform:onPressingChanged:)), animate a progress value linearly from its current value to 1 over the remaining duration (1.2 s); releasing early animates it back to 0 with easeOut(0.35). Draw the liquid as a Shape filled from the bottom up to progress, with a sine-wave top edge (4 pt amplitude, phase driven by TimelineView) that flattens when empty or full. Mask a stack of the liquid plus a white copy of the label with the same shape, so the submerged part of the text turns white. On completion, run the action, swap the label for a checkmark with a spring, play a success haptic and reset after 1.2 s. Scale to 0.97 while pressing.

## Loading → Success

The button morphs into a spinner, then a green checkmark or a red shake. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Button/StatusButton.swift, Sources/MotionLibrary/Support/CheckmarkShape.swift, Sources/MotionLibrary/Support/Haptics.swift.

```swift
@State private var status = MotionButtonStatus.idle

StatusButton("Pay now", status: status) {
    status = .loading
    Task {
        status = await pay() ? .success : .failure
        try? await Task.sleep(for: .seconds(1.5))
        status = .idle
    }
}
```

How it works: Create a SwiftUI StatusButton (iOS 17+) driven by a status enum: idle, loading, success, failure. It is a 50 pt tall capsule Button. Idle shows the title at its natural width. For any other status the frame width animates to 50 pt, turning the capsule into a circle (spring response 0.45, damping 0.75), and the title shrinks and fades. Loading shows a white 70% arc spinning forever. Success turns the fill green and draws a white checkmark path with trim from 0 to 1 (easeOut 0.35 s, 0.15 s delay). Failure turns the fill red, scales in an xmark and shakes horizontally with a GeometryEffect (8 pt, three swings). Play success and error haptics with sensoryFeedback, disable the button when not idle, and expose the status as the accessibility value.

## Glow Border

A rainbow border runs around the view with a soft glow behind it. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Button/GlowBorder.swift.

```swift
Text("Upgrade to Pro")
    .padding()
    .background(.black, in: RoundedRectangle(cornerRadius: 14))
    .glowBorder(cornerRadius: 14)

CardView()
    .glowBorder(colors: [.orange, .yellow], cornerRadius: 24, lineWidth: 3)
```

How it works: Create a SwiftUI .glowBorder(colors:cornerRadius:lineWidth:glowRadius:duration:) view modifier (iOS 17+). In a non-interactive overlay, use TimelineView(.animation) to compute a rotation angle of (time / duration) turns (3 s per turn). Build an AngularGradient from the palette plus its first colour again (pink, purple, blue, cyan, mint by default) starting at that angle. Stroke a continuous RoundedRectangle with it twice: once at 2× line width, blurred by glowRadius (8) at 80% opacity for the glow, and once crisp at lineWidth (2). With Reduce Motion on, pause the rotation.

## Shine

A slanted glint of light sweeps across the button, on cue or on a beat. Trigger: Value change / Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Button/Shine.swift.

```swift
PremiumBadge()
    .shine(every: 3)

Button("Upgrade") { purchases += 1 }
    .buttonStyle(.borderedProminent)
    .shine(trigger: purchases)
```

How it works: Create two SwiftUI modifiers (iOS 17+): .shine(trigger:color:duration:) and .shine(every:color:duration:). Both overlay a "band": a horizontal LinearGradient clear → white 70 % → clear, 30 % of the view's width (at least 24 pt), twice the view's height, rotated 20°, whose x offset goes from −1.5 × band (fully off the left) at progress 0 to width + 1.5 × band (off the right) at progress 1. Mask the band with the content so only the view's own pixels shine, and disable hit testing. The trigger version runs progress 0 → 1 with keyframeAnimator(initialValue: 0, trigger:) and one CubicKeyframe over duration (0.75 s), so the band is hidden at rest. The looping version uses TimelineView(.animation) with progress = (time mod interval) / duration, clamped to 1. With Reduce Motion on, skip the band.

## Jelly

A rubbery squash-and-stretch wobble on every tap. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Button/Jelly.swift.

```swift
Button("Boing") { taps += 1 }
    .buttonStyle(.borderedProminent)
    .jelly(trigger: taps)
```

How it works: Create a SwiftUI .jelly(trigger:amount:) view modifier (iOS 17+) using keyframeAnimator(initialValue:trigger:) on a struct with x and y scale (both 1), applied with scaleEffect(x:y:). With a = amount (0.25): the x track goes 1 + a (0.1 s), 1 − 0.8a (0.12 s), 1 + 0.5a (0.12 s) with cubic keyframes, then a SpringKeyframe(.bouncy) back to 1 over 0.4 s; the y track does the opposite (1 − a, 1 + 0.8a, 1 − 0.5a, spring to 1), so the view squashes wide and flat, then stretches tall and thin, then settles. With Reduce Motion on, use a = 0.

## Click Spark

Short spark lines shoot out from the exact point you tapped. Trigger: Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Button/ClickSpark.swift.

```swift
Button("Launch") { }
    .buttonStyle(.borderedProminent)
    .clickSpark(color: .orange)
```

How it works: Create a SwiftUI .clickSpark(color:count:radius:) view modifier (iOS 17+). Detect taps with .simultaneousGesture(SpatialTapGesture()) and append a spark (UUID + location) to a @State array, removing it 0.6 s later. In a hit-testing-disabled overlay, place each spark at its location: count (8) capsules 2.5 pt wide and 0.45 × radius tall, each rotated by index / count × 360°. On appear, animate with easeOut(0.45 s) from offset −0.3 × radius to −radius (outward), scaleEffect(y:) from 1 to 0.1 anchored at the top (so each line shrinks toward its outer tip) and opacity from 1 to 0. With Reduce Motion on, don't add sparks.

## Like Button

The heart pops in as a ring bursts open and coloured dots fly out. Trigger: Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Button/LikeButton.swift, Sources/MotionLibrary/Support/Haptics.swift.

```swift
LikeButton(isLiked: $post.isLiked)

LikeButton(isLiked: $liked, size: 40, color: .red)
```

How it works: Create a SwiftUI LikeButton (iOS 17+) bound to isLiked, with size (28 pt), color (pink) and dotColors. It's a plain Button showing Image(systemName: isLiked ? "heart.fill" : "heart"); tapping toggles and, on like, increments a counter used as a keyframeAnimator trigger over a struct {heart, ring, dots}. Tracks: heart drops to 0.2 instantly, holds 0.15 s, then springs to 1 with a bouncy overshoot; ring goes 0 → 1 over 0.3 s then back to 0; dots wait 0.15 s then go 0 → 1 over 0.55 s. Behind the heart draw (a) a circle strokeBorder in color whose diameter is 1.5 × size × ring and whose line width is 0.5 × size × (1 − ring), so it bursts open and thins out; (b) 7 pairs of small dots (0.16 × size) at angles i/7 × 360° ± 10°, at distance size × (0.6 + 0.55 × dots), scaling down to 10 % as they fly. Unliking only springs the heart back. Add a light haptic on like, and hide the burst for Reduce Motion.

## Animated Symbol

SF Symbols that keep moving: bounce on a beat, pulse, variable colour. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Button/AnimatedSymbol.swift.

```swift
AnimatedSymbol("bell.fill")                      // bounces every 1.5 s
AnimatedSymbol("heart.fill", style: .pulse)
AnimatedSymbol("wifi", style: .variableColor)
AnimatedSymbol("mic.fill", style: .scaleUp, isActive: isRecording)
```

How it works: Create a SwiftUI AnimatedSymbol view (iOS 17+) wrapping Image(systemName:) with a style enum: .bounce, .pulse, .variableColor and .scaleUp, plus isActive and interval (1.5 s). For .bounce, apply .symbolEffect(.bounce, value: beats) and increment beats in a .task(id: isActive) loop every interval. For the others, use the indefinite effects .symbolEffect(.pulse, isActive:), .symbolEffect(.variableColor.iterative.reversing, isActive:) and .symbolEffect(.scale.up, isActive:). The view inherits font and foregroundStyle like any Image. With Reduce Motion on, treat it as inactive.

## Liquid Toggle

A switch whose knob stretches like a drop of liquid as it slides. Trigger: Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Button/LiquidToggleStyle.swift.

```swift
Toggle("Wi-Fi", isOn: $wifi)
    .toggleStyle(.liquid)

Toggle("Dark mode", isOn: $dark)
    .toggleStyle(.liquid(tint: .purple))
```

How it works: Create a SwiftUI LiquidToggleStyle (iOS 17+) with a tint (green) and static accessors .liquid and .liquid(tint:). makeBody puts the label, a Spacer and a 52 × 32 pt switch in an HStack. The switch is a plain Button that toggles configuration.isOn inside withAnimation(.spring(response: 0.35, dampingFraction: 0.7)); it shows a ZStack aligned .trailing when on and .leading when off, with a capsule track (tint when on, gray 35 % when off) and a white capsule knob (26 pt tall, 3 pt padding, small shadow). The knob's width runs a keyframeAnimator triggered by isOn: CubicKeyframe to 1.5 × 26 pt over 0.12 s, then SpringKeyframe(.bouncy) back to 26 over 0.35 s, so it stretches as it slides and snaps back round. Give it an "On"/"Off" accessibility value. With Reduce Motion on, don't stretch and use a short ease.

## Gooey Menu

A round button splits into a fan of buttons like a drop of liquid. Trigger: Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Button/GooeyMenu.swift.

```swift
GooeyMenu(symbols: ["camera.fill", "photo.fill", "mic.fill"], color: .indigo) { index in
    attach(index)
}
```

How it works: Create a SwiftUI GooeyMenu(symbols:color:distance:action:) view (iOS 17+). Frame: width 2 × distance + 60, height distance + 66 (distance 76). Behind the buttons, a Canvas adds .alphaThreshold(min: 0.5, color: color) and .blur(radius: 7) and, in drawLayer, draws resolved symbols at the main button's centre (bottom centre, 8 pt up): a 56 pt Circle (tag −1) and one 44 pt Circle per item (tags 0…n−1) offset to its fan position, so the circles fuse like liquid while they separate. Item i of n sits at angle π + π × (i + 1) / (n + 1) on a half-circle of radius distance above the button, or at the centre when closed. Each item animates with .spring(duration: 0.55, bounce: 0.35) delayed 0.04 s × its order (reversed when closing). On top of the canvas, place real Buttons with white SF Symbols at the same offsets (opacity 0 and no hit testing when closed) and the main button with a "plus" that rotates 45° when open. Tapping an item calls action(index) and closes the menu. With Reduce Motion on, hide the goo, draw plain circles and fade items in place.

## Slide to Confirm

Drag the knob all the way across to run the action; let go early and it springs back. Trigger: Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Button/SlideToConfirm.swift, Sources/MotionLibrary/Support/Haptics.swift.

```swift
SlideToConfirm("Slide to pay", color: .green) {
    pay()
}
.frame(width: 280)
```

How it works: Create a SwiftUI SlideToConfirm(_ title:color:resetAfter:action:) control (iOS 17+), 56 pt tall. In a GeometryReader ZStack(alignment: .leading): a Capsule track (secondary 15 %), the title (headline, secondary) whose opacity is 1 − progress × 1.6, a Capsule fill of width offset + knob + 8 in the colour at 35 %, and a 48 pt knob Circle (inset 4 pt) with a white "chevron.right.2" (or "checkmark" once confirmed, using contentTransition(.symbolEffect(.replace))) and a coloured shadow. A DragGesture on the knob sets offset = clamp(translation.width, 0, maxOffset). On release past 85 % of maxOffset: snap to the end with a 0.3 s spring, mark confirmed, call action and play a success haptic; then after resetAfter (1.5 s, or never if nil) spring back. Otherwise spring back with .spring(duration: 0.45, bounce: 0.35). Expose it to accessibility as a button whose action confirms.

## Download Button

A capsule shrinks into a progress ring, then pops into a checkmark. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Button/DownloadButton.swift, Sources/MotionLibrary/Support/Haptics.swift.

```swift
DownloadButton(progress: download.progress) {
    download.start()
}
```

How it works: Create a SwiftUI DownloadButton(_ title:progress:color:action:) (iOS 17+) with three phases from progress: nil = idle, 0..<1 = loading, ≥ 1 = done. It's a ZStack whose frame is 150 × 44 when idle and 44 × 44 otherwise, over a Capsule filled with the colour (idle), secondary 12 % (loading) or green (done). Idle shows a white Label(title, systemImage: "arrow.down") with a scale 0.8 + opacity transition; loading shows a Circle trimmed to progress, stroked 4 pt with round caps, rotated −90°, padded 3 pt, and a small "stop.fill"; done shows a white "checkmark" with a scale-from-0.2 + opacity transition. Animate phase changes with .spring(duration: 0.5, bounce: 0.35) so the capsule visibly shrinks into the ring, and play a success haptic when it finishes. The action only runs from the idle phase. With Reduce Motion on, use a 0.25 s ease instead of the spring.

## Star Rating

Stars fill one after another with a springy pop and a burst of sparks. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Button/StarRating.swift, Sources/MotionLibrary/Support/Haptics.swift.

```swift
StarRating(rating: $rating)
```

How it works: Create a SwiftUI StarRating(rating: Binding<Int>, maximum:color:size:) control (iOS 17+): an HStack (spacing size × 0.25) of SF Symbols "star.fill" (filled, yellow) or "star" (secondary 50 %), size 28 pt. Tapping star i sets rating = i. Each filled star runs keyframeAnimator(initialValue: 1, trigger: rating) on its scale: hold 1 for (i − 1) × 0.06 s, SpringKeyframe to 1.4 (0.15 s, .snappy), then to 1 (0.4 s, .bouncy), so they pop in sequence. Behind the tapped star, eight 4 pt dots at 45° steps fly out from size × 0.3 to size × 0.95 over 0.45 s while fading (after the same delay). Play a light haptic on change. Make the whole control one adjustable accessibility element ("Rating", "3 of 5"). With Reduce Motion on, skip the pops and sparks.

## Bouncy Tab Bar

A pill glides to the selected tab and its icon squashes and hops. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Button/BouncyTabBar.swift, Sources/MotionLibrary/Support/Haptics.swift.

```swift
BouncyTabBar(selection: $tab, items: [
    .init("house.fill", "Home"),
    .init("magnifyingglass", "Search"),
    .init("person.fill", "Profile"),
])
```

How it works: Create a SwiftUI BouncyTabBar(selection: Binding<Int>, items:color:) (iOS 17+) where each item is an SF Symbol and a title. Lay the tabs out in an HStack (spacing 4, padding 6) on a .regularMaterial Capsule with a soft shadow. Each tab is a plain Button with a VStack of the 18 pt semibold symbol and a caption2 title, tinted with the colour when selected (secondary otherwise), and a Capsule at 15 % of the colour behind the selected tab, shared with matchedGeometryEffect so it glides; selection changes use .spring(duration: 0.4, bounce: 0.3). The selected icon runs keyframeAnimator(trigger: selection), anchored at the bottom: scaleX 1.25 → 0.9 → spring 1, scaleY 0.75 → 1.12 → spring 1, y 0 → −7 → spring 0 (0.08 s, 0.14 s, 0.3 s .bouncy). Play a light haptic. With Reduce Motion on, skip the hop.

## Pull Cord

A lamp cord toggle: pull the knob down, it clicks and springs back swinging. Trigger: Drag / Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Button/PullCord.swift, Sources/MotionLibrary/Support/Haptics.swift.

```swift
HStack(alignment: .top) {
    Image(systemName: lightsOn ? "lightbulb.max.fill" : "lightbulb")
    PullCord(isOn: $lightsOn)
}
```

How it works: Create a SwiftUI PullCord(isOn:length:color:) toggle (iOS 17+). A VStack(spacing: 0) of a 2 pt wide Rectangle (height length + stretch, default length 70) and a 16 × 26 Capsule knob, yellow with a yellow shadow (radius 8) when on. Rotate the whole cord with .rotationEffect(swing, anchor: .top) inside a 60 pt wide frame with room below to stretch. A DragGesture(minimumDistance: 0) sets stretch = 1.6c × (1 − e^(−pull / 1.6c)) with c = 0.45 × length (rubber-band resistance) and swing = −translation.width / 6 clamped to ±18°. On release, toggle when stretch passed c or the drag was a tap (moved < 4 pt), play a light haptic, then spring stretch back to 0 with .spring(duration: 0.55, bounce: 0.6) and swing back with .spring(duration: 0.9, bounce: 0.7). With Reduce Motion on, no swing and an ease-out return. Make it one accessibility element with the button trait, value On/Off and an action that toggles.

## Staggered Entrance

List items fade and rise into place one after another. Trigger: Appear. Requires iOS 17+. Files: Sources/MotionLibrary/Card/StaggeredAppear.swift.

```swift
ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
    CardView(item)
        .staggeredAppear(index: index)
}
```

How it works: Create a SwiftUI .staggeredAppear(index:) view modifier (iOS 17+) for list and grid entrances. Each item starts at opacity 0, offset 24 pt down and scale 0.96, then on appear animates to its resting state with .spring(response: 0.5, dampingFraction: 0.8), delayed by index × 0.08 s so the items cascade in. Delay per item and travel distance are configurable.

## 3D Tilt

Card tilts in 3D toward the finger with a moving glare, then springs flat. Trigger: Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Card/Tilt.swift.

```swift
CardView()
    .tiltOnDrag(maxAngle: 15, cornerRadius: 20)
```

How it works: Create a SwiftUI .tiltOnDrag() view modifier (iOS 17+). While the user drags on the view, convert the drag translation into a normalised -1…1 value per axis (120 pt = full tilt) and apply two rotation3DEffects (x axis from vertical drag, y axis from horizontal drag) up to a max angle of ~12°, plus a 1.03 scale. Overlay a white glare gradient whose start/end points follow the tilt and which is only visible while dragging, clipped to the card's corner radius. Use .interactiveSpring while dragging and a bouncy spring back to flat on release.

## Scroll Reveal

Rows scale up and come into focus as they enter the visible area. Trigger: Scroll. Requires iOS 17+. Files: Sources/MotionLibrary/Card/ScrollReveal.swift.

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            Row(item).scrollReveal()
        }
    }
}
```

How it works: Create a SwiftUI .scrollReveal() view modifier (iOS 17+) using scrollTransition(.interactive). When an item is fully inside the scroll view (phase.isIdentity) it is at full opacity, scale 1 and no blur; as it moves toward the top or bottom edge it interpolates to opacity 0.3, scale 0.85 and a 2 pt blur. Axis, minimum scale, minimum opacity and blur amount should be parameters.

## Flip Card

A two-sided card turns over in 3D with a spring. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Card/FlipCard.swift.

```swift
@State private var flipped = false

FlipCard(isFlipped: flipped) {
    QuestionView()
} back: {
    AnswerView()
}
.frame(width: 220, height: 300)
.onTapGesture { flipped.toggle() }
```

How it works: Create a SwiftUI FlipCard<Front, Back> view (iOS 17+) with isFlipped and axis (horizontal or vertical) parameters and front/back view builders. Stack both faces in a ZStack and give each an Animatable view modifier holding the animated angle (0 or 180°). The back face uses angle − 180 so it reads correctly once turned. Each face applies rotation3DEffect around the y axis (or x for vertical) with perspective 0.5 and sets opacity to 1 only while |faceAngle| < 90°, so the faces swap exactly at the halfway point and the back never shows mirrored. Animate isFlipped changes with spring(response 0.6, damping 0.75). Hide the hidden face from accessibility. With Reduce Motion on, cross-fade instead of rotating.

## Swipe Card Stack

Tinder-style deck: drag the top card away and the pile moves up. Trigger: Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Card/SwipeCardStack.swift.

```swift
SwipeCardStack(profiles) { profile, direction in
    direction == .right ? like(profile) : pass(profile)
} card: { profile in
    ProfileCard(profile)
        .frame(width: 300, height: 420)
}
```

How it works: Create a generic SwiftUI SwipeCardStack (iOS 17+) over a collection of Identifiable items with a card view builder and an onSwipe(item, direction) callback. Show the top 3 cards from the current position (looping by default). Cards behind are scaled down 5% per level and moved down 12 pt per level. The top card follows a DragGesture: offset by the translation, rotate by translation.width / 20 degrees around the bottom anchor, and overlay a green (right) or red (left) wash, masked by the card, whose opacity grows to 25% at the threshold. On release, if the predicted end translation passes 110 pt, fly the card 600 pt off in that direction with easeIn(0.25), then reset the drag without animation, advance the position with a spring so the pile moves up, and call onSwipe. Otherwise spring back. Add Swipe left and Swipe right accessibility actions.

## Parallax Carousel

Paging cards whose images slide slower than the cards, for depth. Trigger: Scroll. Requires iOS 17+. Files: Sources/MotionLibrary/Card/ParallaxCarousel.swift.

```swift
ParallaxCarousel(places) { place in
    Image(place.photo)
        .resizable()
        .scaledToFill()
}
.frame(height: 240)
```

How it works: Create a generic SwiftUI ParallaxCarousel (iOS 17+) over Identifiable items with an optional selection binding. Use a horizontal ScrollView with a LazyHStack (14 pt spacing), .scrollTargetLayout(), .scrollTargetBehavior(.viewAligned), hidden indicators, .scrollPosition(id:anchor: .center), and horizontal contentMargins so each card (78% of the width) snaps to the centre with neighbours peeking. Draw each card's content wider than the card by the parallax factor (0.35), then use .visualEffect to read the card's frame in the .scrollView coordinate space and offset the content by −(distance of the card centre from the viewport centre) × parallax. Finally frame it to the card size and clip it with a continuous rounded rectangle (22 pt), so the image appears to move slower than its frame. With Reduce Motion on, set parallax to 0.

## Expandable Card

Tap the header and the card springs open, un-blurring its detail. Trigger: Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Card/ExpandableCard.swift.

```swift
@State private var isOpen = false

ExpandableCard(isExpanded: $isOpen) {
    Text("Shipping").font(.headline)
} detail: {
    Text("Arrives Thursday. Free returns within 30 days.")
}
```

How it works: Create a SwiftUI ExpandableCard<Header, Detail> (iOS 17+) bound to isExpanded. A VStack holds a plain-style Button containing the header, a spacer and a chevron.down that rotates −180° when open, then, if expanded, the detail view. Toggle inside withAnimation(.spring(response 0.45, damping 0.8)) so the card's height springs. Insert the detail with a combined transition of opacity, an 8 pt upward offset and a custom blur transition (radius 6 → 0). The background is a continuous rounded rectangle (16 pt) filled with the background style whose shadow deepens when open. Expose Expanded/Collapsed as the accessibility value. With Reduce Motion on, use a short ease and an opacity transition only.

## Hero Expand

A thumbnail grows into a full detail card, morphing with matchedGeometryEffect. Trigger: Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Card/HeroGrid.swift.

```swift
HeroGrid(photos, columns: 3) { photo in
    Image(photo.thumbnail).resizable().scaledToFill().frame(height: 90)
} detail: { photo in
    PhotoDetail(photo)
}
```

How it works: Create a generic SwiftUI HeroGrid (iOS 17+) over Identifiable items with columns (3), spacing (10), cornerRadius (14) and two view builders: thumbnail and detail. Keep @State selected: Item.ID? and a @Namespace. In a ZStack, show a LazyVGrid of flexible columns; for each item, if it isn't selected show a plain Button with the thumbnail clipped to a continuous rounded rectangle and .matchedGeometryEffect(id: item.id, in: namespace), otherwise show the thumbnail .hidden() to keep the slot. Dim the grid to 30 % while something is selected. Above it, if selected, show the detail in a Button sized maxWidth/maxHeight .infinity, clipped the same way, with the same matchedGeometryEffect id and zIndex 1. Open with withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) and close by tapping the detail. Both views get an .opacity transition so their content cross-fades while the frame morphs. With Reduce Motion on, pass properties: [] to matchedGeometryEffect so it only cross-fades.

## Spotlight Card

A soft glow follows the pointer across the card, like a torch. Trigger: Hover / Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Card/Spotlight.swift.

```swift
FeatureCard()
    .background(.black, in: RoundedRectangle(cornerRadius: 20))
    .spotlight()

PricingCard()
    .spotlight(color: .purple.opacity(0.4), radius: 160)
```

How it works: Create a SwiftUI .spotlight(color:radius:) view modifier (iOS 17+). Track the pointer with .onContinuousHover(coordinateSpace: .local) and a finger with a simultaneous DragGesture(minimumDistance: 0); store the location in @State (nil when the pointer leaves or the drag ends) and remember the last location so the glow can fade out where it was. In an overlay GeometryReader, draw a RadialGradient from color (white 35 %) to clear, centred at the location converted to a UnitPoint, endRadius = radius (120 pt), and mask it with the content so it only lights the card. Move with .interactiveSpring(response: 0.2, dampingFraction: 0.9) and fade out with easeOut(0.35 s). Disable hit testing on the glow. With Reduce Motion on, move the glow without animation.

## Magnifying Dock

Icons swell as the pointer passes over them, like the macOS Dock. Trigger: Hover / Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Card/MagnifyingDock.swift.

```swift
MagnifyingDock(apps) { app in
    Image(app.icon).resizable()
}
.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
```

How it works: Create a generic SwiftUI MagnifyingDock (iOS 17+) over Identifiable items with size (40 pt), magnification (1.8), range (110 pt), spacing (8) and a content builder. Lay the items out in an HStack(alignment: .bottom) and frame each icon to size × scale(i). Put the HStack in a frame exactly as wide as the resting row (count × size + gaps) and size × magnification tall, aligned to the bottom, so the magnified row overflows it evenly; track the pointer x on that frame with .onContinuousHover and a simultaneous DragGesture(minimumDistance: 0). scale(i) = 1 + (magnification − 1) × cos(d / range × π/2) where d is the distance from the pointer to the icon's resting centre (i × (size + spacing) + size/2), or 1 beyond range. Animate pointer changes with .interactiveSpring(response: 0.2) and the release with .spring(response: 0.35, dampingFraction: 0.75). Add horizontal padding for the overflow. With Reduce Motion on, don't magnify.

## Jiggle

The home-screen edit-mode wiggle, each item slightly out of step. Trigger: Loop / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Card/Jiggle.swift.

```swift
ForEach(apps) { app in
    AppIcon(app)
        .jiggle(isActive: isEditing)
}
```

How it works: Create a SwiftUI .jiggle(isActive:angle:) view modifier (iOS 17+) that wiggles a view like an app icon in edit mode. Give each instance a random @State phase (0–1) and rate (0.9–1.1) so neighbours never move in lockstep. In TimelineView(.animation(paused: !isActive)), let t = (time × rate + phase) × 2π × 3.6, rotate by sin(t) × angle (2.5°) and offset y by cos(t/2) × 0.8 pt. When inactive, return to 0 with a 0.15 s ease. With Reduce Motion on, don't move.

## Fan Stack

A pile of cards fans out like a hand of playing cards, and gathers back. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Card/FanStack.swift.

```swift
FanStack(cards, isSpread: isSpread) { card in
    CardView(card).frame(width: 80, height: 120)
}
.onTapGesture { isSpread.toggle() }
```

How it works: Create a generic SwiftUI FanStack (iOS 17+) over Identifiable items with isSpread, angle (10°) and spacing (34 pt). Draw the cards in a ZStack, bottom first. For card i, let c = i − (count − 1)/2. Fanned: rotate by c × angle around the bottom anchor, offset x by c × spacing and y by c² × 4 pt so the outer cards dip along an arc. Stacked: rotate by c × 1.5° around the centre and offset y by −2 pt × i for a neat pile. Animate each card with .spring(response: 0.45, dampingFraction: 0.7).delay(i × 0.03) on isSpread so they follow each other. With Reduce Motion on, use a 0.25 s ease without the stagger.

## Scratch Card

Rub away a scratch-off cover to reveal what's underneath. Trigger: Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Card/ScratchCard.swift.

```swift
PrizeView()
    .scratchToReveal(Color.gray) {
        didReveal = true
    }
```

How it works: Create a SwiftUI .scratchToReveal(_ cover:lineWidth:threshold:onReveal:) view modifier (iOS 17+). Overlay a Rectangle filled with the cover style (with a faint "hand.draw.fill" hint until the first stroke) and mask it with a compositingGroup of a full Rectangle plus a stroked Path of every finger stroke (lineWidth 34, round caps and joins) using .blendMode(.destinationOut), so strokes punch holes in the cover. A DragGesture(minimumDistance: 0) starts a new stroke when translation is zero and appends locations otherwise. Track coverage on a 12 × 12 grid: mark every cell within lineWidth / 2 of each point; once 55 % of cells are marked, fade the cover out over 0.4 s, disable its hit testing and call onReveal once. Give the view a new .id to reset it. Accessibility: a button whose action reveals.

## Stacking Cards

Cards stick at the top while scrolling and shrink as the next one covers them. Trigger: Scroll. Requires iOS 17+. Files: Sources/MotionLibrary/Card/StackingCards.swift.

```swift
ScrollView {
    VStack(spacing: 16) {
        ForEach(cards) { card in
            CardView(card).stackingCard()
        }
    }
}
```

How it works: Create a SwiftUI .stackingCard(top:scale:) view modifier (iOS 17+) for cards in a VStack inside a vertical ScrollView, built with visualEffect so it needs no layout passes. From proxy.frame(in: .scrollView): overshoot = max(0, top − minY) (top 16 pt), covered = min(1, overshoot / height), gone = clamp(overshoot / height − 1, 0, 1). Apply offset(y: overshoot) so the card sticks at the top, scaleEffect(1 − (1 − scale) × covered, anchor: .top) with scale 0.88, brightness(−0.25 × covered) and opacity(1 − gone). Later cards naturally draw on top in the VStack, so they slide over the pinned ones like a wallet. With Reduce Motion on, skip the scaling.

## Deck Shuffle

A deck splits in two, mixes, and springs back into a messy stack. Trigger: Value change / Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Card/DeckShuffle.swift.

```swift
DeckShuffle(cards, trigger: shuffles) { card in
    CardFace(card)
}
.onTapGesture { shuffles += 1 }
```

How it works: Create a generic SwiftUI DeckShuffle(_ items:trigger:spread:content:) view (iOS 17+) for Identifiable items. Keep the order as @State [ID]. Draw the cards in a ZStack with zIndex = stack position, offset y = −2 pt × position and a small hand-made tilt per position (0, −2.5, 2, −1, 3, −2, 1.5, −3°). When trigger changes: animate isSplit = true with .easeOut(0.28 s), which moves even positions to x −spread (70 pt) rotated −8° and odd ones to +spread rotated +8°; after 0.3 s, in one .spring(duration: 0.55, bounce: 0.3) animation, shuffle the order and set isSplit = false, so cards change sides and visibly cross over as they come together. With Reduce Motion on, just re-order with a 0.3 s ease.

## Looping Carousel

A paging carousel that wraps around forever, with peeking neighbours. Trigger: Drag / Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Card/LoopingCarousel.swift.

```swift
LoopingCarousel(banners, autoplay: 3) { banner in
    BannerCard(banner)
}
.frame(height: 200)
```

How it works: Create a SwiftUI LoopingCarousel(_ items:spacing:peek:autoplay:content:) view (iOS 17+). Inside a horizontal ScrollView, a LazyHStack(spacing: 12) lays the items out three times (index 0..<3n, item = items[index % n]), each .containerRelativeFrame(.horizontal) with .scrollTransition(.interactive) scaling to 1 − |phase| × 0.12 and fading to 1 − |phase| × 0.4, and .id(index). Use .scrollTargetLayout(), .scrollTargetBehavior(.viewAligned), .contentMargins(.horizontal, peek + spacing) (peek 36 pt) and .scrollPosition(id:), starting at n (the middle copy). In .task(id: position), wait 0.45 s for scrolling to settle; if the position is outside the middle copy, jump to n + position % n inside a transaction with animations disabled, which looks identical. For autoplay, loop: sleep autoplay seconds, then position += 1 with .spring(duration: 0.6, bounce: 0.15). With Reduce Motion on, skip the scaling.

## Drag to Dismiss

Fling a card away; it flies off with your throw or springs back. Trigger: Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Card/DragToDismiss.swift.

```swift
if showPhoto {
    PhotoView()
        .dragToDismiss(isPresented: $showPhoto)
}
```

How it works: Create a SwiftUI .dragToDismiss(isPresented:threshold:) view modifier (iOS 17+). While dragging, offset the view by the translation, scale it to 1 − min(0.2, distance / 1200) and rotate it by translation.width / 25 degrees. On release, if the drag distance exceeds threshold (120 pt) or the predicted end translation exceeds 2.5 × threshold, fly it off along the predicted direction normalised to 700 pt with .easeOut(0.3 s) while fading out, then set isPresented = false and reset the offset without animation. Otherwise spring back with .spring(duration: 0.45, bounce: 0.4). Add an accessibility action "Dismiss". With Reduce Motion on, skip the scale and rotation.

## Shrinking Header

The header sticks to the top and shrinks as content scrolls under it. Trigger: Scroll. Requires iOS 17+. Files: Sources/MotionLibrary/Card/ScrollHeaders.swift.

```swift
ScrollView {
    VStack(spacing: 0) {
        ProfileHeader().shrinkingHeader()
        ForEach(posts) { PostRow($0) }
    }
}
```

How it works: Create a SwiftUI .shrinkingHeader(minScale:) view modifier (iOS 17+) for the first view in a vertical ScrollView, built with visualEffect. From proxy.frame(in: .scrollView): scrolled = max(0, −minY), progress = min(1, scrolled / (height × (1 − minScale))). Apply scaleEffect(1 − (1 − minScale) × progress, anchor: .top) with minScale 0.6 first, then offset(y: scrolled) so it stays pinned at the top (offset first and the scale would shrink the offset too, letting the header drift away), and give the view .zIndex(1) so the content scrolls underneath it. With Reduce Motion on, pin it without scaling.

## Stretchy Header

A header image stretches when pulled down and drifts with parallax when scrolled. Trigger: Scroll. Requires iOS 17+. Files: Sources/MotionLibrary/Card/ScrollHeaders.swift.

```swift
ScrollView {
    Image("cover")
        .resizable()
        .scaledToFill()
        .frame(height: 260)
        .clipped()
        .stretchyHeader()
    ArticleBody()
}
```

How it works: Create a SwiftUI .stretchyHeader(parallax:) view modifier (iOS 17+) for a header image at the top of a vertical ScrollView, built with visualEffect. From proxy.frame(in: .scrollView): when pulled past the top (minY > 0), scaleEffect(1 + minY / height, anchor: .bottom) so it grows upward to fill the gap; when scrolled up (minY < 0), offset(y: minY × −parallax) with parallax 0.5 so it moves at half speed. With Reduce Motion on, skip the parallax.

## Island Pill

A black pill springs open into a card and back, its contents blurring across. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Card/IslandPill.swift.

```swift
IslandPill(isExpanded: showsPlayer) {
    Image(systemName: "waveform")
} expanded: {
    NowPlayingView()
}
.onTapGesture { showsPlayer.toggle() }
```

How it works: Create a SwiftUI IslandPill(isExpanded:compactSize:expandedSize:color:compact:expanded:) view (iOS 17+): a black shape that morphs between a pill (default 126 × 37, corner radius half its height) and a card (default 340 × 160, corner radius min(44, height / 2)), using a continuous RoundedRectangle as background and clip shape. Inside, a ZStack holds both contents: the compact one fades out while blurring to 8 pt and scaling to 1.6; the expanded one fades in from blur 10 pt and scale 0.6 (anchored top). Force the dark colour scheme inside. Animate every change of isExpanded with .spring(duration: 0.5, bounce: 0.32). With Reduce Motion on, skip the blur and scale and use .easeInOut(duration: 0.25).

## Hover Lift

Cards rise, grow and lean towards the pointer on iPad and Mac. Trigger: Hover. Requires iOS 17+. Files: Sources/MotionLibrary/Card/HoverLift.swift.

```swift
LazyVGrid(columns: columns) {
    ForEach(projects) { project in
        ProjectCard(project)
            .hoverLift()
    }
}
```

How it works: Create a SwiftUI .hoverLift(scale:tilt:cornerRadius:) view modifier (iOS 17+) for pointer hover on iPad and Mac. Track the pointer with .onContinuousHover(coordinateSpace: .local) and the view size with a background GeometryReader. While hovered, scale to 1.05, offset y −4 and deepen the shadow (black 22 %, radius 18, y 12; at rest 8 %, radius 6, y 3), all with .spring(duration: 0.35, bounce: 0.3). Lean towards the pointer: with lean = location / size × 2 − 1, apply rotation3DEffect(tilt × lean.x around y) and (−tilt × lean.y around x), tilt 6°, perspective 0.6, animated with .interactiveSpring(duration: 0.25). With Reduce Motion on, don't move or scale; brighten by 0.05 instead. Add isActive (default false) to lift the view without a pointer too, for the focused or selected card. On visionOS, where apps can't see the gaze, use .contentShape(.hoverEffect, RoundedRectangle(cornerRadius:)) and the system .hoverEffect().

## Marquee Wall

A tilted wall of cards, columns scrolling endlessly up and down. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Card/MarqueeWall.swift.

```swift
MarqueeWall(count: shots.count, columns: 4) { index in
    Image(shots[index]).resizable().scaledToFill()
}
.frame(height: 320)
.clipped()
```

How it works: Create a SwiftUI MarqueeWall(count:columns:itemSize:spacing:speed:angle:content:) view (iOS 17+), the scrolling showcase wall from landing pages. Each of the columns (default 4) shows perColumn = max(3, ceil(count / columns)) items twice in a VStack, cards of itemSize (110 × 140) with 14 pt continuous corners and 12 pt spacing, so the loop height is perColumn × (height + spacing). In TimelineView(.animation), distance = (time × speed × (1 + 0.15 × (column % 3))) mod loopHeight (speed 24 pt/s); even columns offset by −distance (moving up), odd ones by distance − loopHeight (moving down). Lay the columns in an HStack, rotate the whole thing by −14° and let the caller clip it. Disable hit testing. With Reduce Motion on, pause the timeline.

## Photo Develop

The view develops like an instant photo, from murky dark to full colour. Trigger: Appear / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Card/PhotoDevelop.swift.

```swift
Image("snapshot")
    .resizable()
    .scaledToFill()
    .frame(width: 200, height: 200)
    .photoDevelop(trigger: shotCount)
```

How it works: Create a SwiftUI .photoDevelop(trigger:duration:) view modifier (iOS 17+) that develops the view like an instant photo on appear and whenever trigger changes. Reset progress to 0 without animation, then animate it to 1 with .easeOut(duration: 3.5). Apply the look in an Animatable modifier so each quality keeps its own pace: light = min(1, 1.6p), colour = max(0, (p − 0.25) / 0.75), focus = min(1, 1.3p); .saturation(colour), .contrast(0.55 + 0.45 × light), .brightness(−0.45 × (1 − light)), .blur(radius: 5 × (1 − focus)), and an overlay LinearGradient from blue-grey (0.2, 0.25, 0.35) to brown (0.35, 0.25, 0.18) with opacity 0.75 × (1 − colour) and .blendMode(.multiply). With Reduce Motion on, develop over 0.4 s.

## Pulse Rings

Concentric rings expand and fade continuously, like a radar or live dot. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/PulseRings.swift.

```swift
ZStack {
    PulseRings(color: .green, count: 3)
        .frame(width: 120, height: 120)
    Circle().fill(.green).frame(width: 24, height: 24)
}
```

How it works: Create a SwiftUI PulseRings view (iOS 17+). Draw N stroked circles (default 3, 2 pt line) that each grow from 20% to 100% of the frame while fading from opacity 1 to 0 over a 2 s cycle, evenly phase-offset so a new ring is always emerging. Drive it with TimelineView(.animation) and compute each ring's progress from the timeline date (no @State or repeatForever), so it never drifts and stops when off screen. Hide it from accessibility.

## Like Burst

Particles fly outward from the centre when a value changes. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/Burst.swift.

```swift
Image(systemName: isLiked ? "heart.fill" : "heart")
    .contentTransition(.symbolEffect(.replace))
    .burst(trigger: isLiked, color: .pink, isEnabled: isLiked)
```

How it works: Create a SwiftUI .burst(trigger:) view modifier (iOS 17+) for "like" feedback. Every time the Equatable trigger changes (and isEnabled is true), spawn a burst in an overlay: 12 small circles (alternating 7 pt and 4 pt) placed evenly around a circle, which move outward from the centre to a ~36 pt radius while shrinking to 30% and fading out with easeOut over 0.6 s. Remove each burst after it finishes, allow overlapping bursts, and never intercept touches. Color, count and radius are parameters.

## Checkmark Draw

A success mark draws itself: circle stroke, fill, then a popping check. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/AnimatedCheckmark.swift, Sources/MotionLibrary/Support/CheckmarkShape.swift.

```swift
AnimatedCheckmark(isChecked: isDone)
    .frame(width: 80, height: 80)

AnimatedCheckmark(isChecked: saved, color: .blue, lineWidth: 3)
```

How it works: Create a SwiftUI AnimatedCheckmark view (iOS 17+) with isChecked, color (green) and lineWidth (4 at 60 pt, scaled with size). It is square. Layer three parts in a ZStack: a circle stroke trimmed from 0 to 1 and rotated −90° so it draws clockwise from the top (easeInOut 0.45 s); a filled circle that scales from 0.6 and fades in with a spring after 0.35 s; and a white checkmark path (short stroke down-right, long stroke up-right, round caps and joins) trimmed from 0 to 1 with easeOut 0.3 s after 0.55 s. Finish with a small bouncy scale pop at 0.75 s. Unchecking reverses everything without delays. With Reduce Motion on, replace the sequence with a 0.2 s fade.

## Confetti

Confetti bursts out of the view, tumbles under gravity and fades. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/Confetti.swift.

```swift
@State private var orders = 0

Button("Complete order") { orders += 1 }
    .confetti(trigger: orders)

Text("🎉 Level up!")
    .confetti(trigger: level, colors: [.yellow, .orange], count: 120)
```

How it works: Create a SwiftUI .confetti(trigger:colors:count:spread:) view modifier (iOS 17+). Each change of the equatable trigger appends a burst with a start date and 80 random pieces, removed after 2.4 s. Each piece has a velocity fanned ±60° around straight up (speed up to 3.2 × spread), a spin rate, a wobble phase, a 5–9 × 8–14 pt size, a colour index and every fourth one is a circle. Draw all bursts in one Canvas inside TimelineView(.animation), in an overlay enlarged by .padding(−spread) (160 pt) so confetti flies beyond the view, with hit testing off. Position = origin + velocity × (1 − e^(−1.6t)) / 1.6 + ½ × gravity × t² (air drag plus gravity), rotate by spin × t, scale x by cos(wobble + 8t) to fake turning over, and fade out over the last 0.6 s. With Reduce Motion on, skip the burst.

## Loaders

Five looping activity indicators: spinner, dots, bars, orbit and pulse. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/MotionLoader.swift.

```swift
MotionLoader(.spinner)
    .frame(width: 32, height: 32)

MotionLoader(.dots, color: .secondary)
    .frame(width: 44, height: 44)
```

How it works: Create a SwiftUI MotionLoader view (iOS 17+) with a style enum (spinner, dots, bars, orbit, pulse), a color and a speed multiplier. It is square and drives everything from TimelineView(.animation) time, sizing parts relative to its side. Spinner: a round-capped arc whose trim length breathes between 15% and 75% while it rotates. Dots: three dots hopping up in sequence (max(0, sin(6t − i·0.9))) and brightening at the top. Bars: five capsules whose heights follow a sine wave offset per bar. Orbit: two dots circling each other, scaled and layered by a fake depth. Pulse: two rings expanding and fading in turn around a centre dot. Label it "Loading" for accessibility, and with Reduce Motion on, show a dot that slowly breathes in opacity.

## Morphing Blob

An organic, lava-lamp blob whose outline never stops changing. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/MorphingBlob.swift.

```swift
MorphingBlob(colors: [.purple, .pink, .orange])
    .frame(width: 200, height: 200)

MorphingBlob(fill: Color.blue.opacity(0.3), points: 8, wobble: 0.1)
    .overlay(Image(systemName: "mic.fill"))
```

How it works: Create a SwiftUI MorphingBlob view (iOS 17+) generic over a ShapeStyle fill, with a convenience initializer taking colours for a diagonal LinearGradient. Draw a custom Shape in TimelineView(.animation): place N control points (6) evenly around the centre, each at radius base × (1 + wobble × (0.6·sin(1.1t + 1.7i) + 0.4·sin(0.7t + 2.9i))), where base = half the side × (1 − wobble) and wobble is 0.18. Connect them into a smooth closed curve with a Catmull-Rom spline converted to cubic Béziers (control points p1 + (p2 − p0)/6 and p2 − (p3 − p1)/6). Keep a 1:1 aspect ratio and hide it from accessibility. With Reduce Motion on, freeze the shape.

## Draw On

Any Shape strokes itself on like a pen, and erases back. Trigger: Appear / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/DrawOn.swift.

```swift
Circle()
    .drawOn()
    .frame(width: 80, height: 80)

SignaturePath()
    .drawOn(isDrawn: signed, style: .blue, lineWidth: 3, duration: 1.6)
```

How it works: Create a SwiftUI Shape extension drawOn(isDrawn:style:lineWidth:duration:) (iOS 17+) returning a DrawOnShape view. It strokes shape.trim(from: 0, to: progress) with the given ShapeStyle (accent colour), a StrokeStyle with lineWidth (3 pt), round caps and round joins, and pads by lineWidth / 2 so the stroke isn't clipped. Keep progress in @State; on appear and whenever isDrawn changes, animate it to 1 (draw) or 0 (erase) with easeInOut over duration (1.2 s). Works with any Shape, including custom paths, which are drawn in path order. With Reduce Motion on, use a 0.2 s ease.

## Progress Ring

A gradient ring springs to each value as the percentage rolls. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/ProgressRing.swift.

```swift
ProgressRing(progress: uploaded)
    .frame(width: 120, height: 120)

ProgressRing(progress: steps / goal, colors: [.green, .mint]) {
    Image(systemName: "figure.walk").font(.title)
}
```

How it works: Create a SwiftUI ProgressRing (iOS 17+) with progress (0…1), lineWidth (12 pt), colors (cyan, blue, purple) and an optional label view builder (default: the percentage). In a ZStack, stroke a full Circle in secondary at 18 % opacity, then a Circle().trim(from: 0, to: progress) stroked with AngularGradient(colors:) over 0–360° and a round line cap, rotated −90° so it starts at twelve o'clock. Pad by lineWidth / 2. Animate progress changes with .spring(response: 0.6, dampingFraction: 0.75). The default label is the percentage as .title2.bold().monospacedDigit() with .contentTransition(.numericText(value:)), so the digits roll. Expose the percentage as the accessibility value. With Reduce Motion on, use a short ease.

## Skeleton

A shimmering placeholder of the view's own layout while it loads. Trigger: Loop / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/Skeleton.swift, Sources/MotionLibrary/Text/Shimmer.swift.

```swift
ArticleRow(article)
    .skeleton(isLoading: isLoading)
```

How it works: Create a SwiftUI .skeleton(isLoading:) view modifier (iOS 17+). While loading, apply .redacted(reason: .placeholder) so text and images become grey blocks in the view's real layout, then the shimmer modifier (a white 80 % highlight band, 35 % of the width, sweeping left to right every 1.6 s, masked by the content), disable hit testing and hide the view from accessibility. When loading ends, remove both and animate with easeInOut(0.3 s) so the real content fades in. The shimmer pauses for Reduce Motion.

## Sliding Tabs

A segmented control whose pill or underline glides to the selection. Trigger: Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/SlidingTabs.swift.

```swift
SlidingTabs(["Day", "Week", "Month"], selection: $range)

SlidingTabs(Category.allCases, selection: $category, indicator: .underline) { $0.title }
```

How it works: Create a generic SwiftUI SlidingTabs control (iOS 17+) over Hashable options with a selection binding, an indicator style (.pill or .underline), a tint and a title closure (plus a convenience init for [String]). Show the options as plain Buttons in an HStack inside a 4 pt padded capsule tinted secondary at 12 % (pill style only). Behind the selected title only, draw the indicator — a capsule filled with the tint (title turns white), or a 3 pt capsule at the bottom inset 10 pt (title turns tint) — with .matchedGeometryEffect(id: "indicator", in: namespace), so it glides between options. Change the selection inside withAnimation(.spring(response: 0.35, dampingFraction: 0.8)), and add the .isSelected trait. With Reduce Motion on, use a 0.15 s ease.

## Reading Progress

A bar along the top fills as you scroll through the content. Trigger: Scroll. Requires iOS 17+. Files: Sources/MotionLibrary/Shape/ReadingProgress.swift.

```swift
ReadingProgressScrollView(color: .pink) {
    ArticleBody()
}
```

How it works: Create a SwiftUI ReadingProgressScrollView(color:height:content:) (iOS 17+): a vertical ScrollView whose content gets a top overlay holding a Color.clear layer with a Capsule (4 pt tall, the colour, a soft glow shadow) at its top-leading edge. Drive the layer with visualEffect, not state or a PreferenceKey (preferences don't reliably leave an iOS scroll view): frame = proxy.frame(in: .scrollView), viewport = proxy.bounds(of: .scrollView)?.size, progress = clamp(−frame.minY / (frame.height − viewport.height), 0, 1); scaleEffect(x: viewport.width × progress / frame.width, anchor: .topLeading), then offset(x: −frame.minX, y: −frame.minY) to pin it to the top. Disable hit testing.

## Aurora

Soft, blurred colour blobs drift slowly behind your content. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/AuroraBackground.swift.

```swift
ZStack {
    AuroraBackground(colors: [.purple, .blue, .teal, .pink])
        .ignoresSafeArea()
    Text("Welcome").font(.largeTitle.bold())
}
```

How it works: Create a SwiftUI AuroraBackground view (iOS 17+). On a dark base color, draw one large circle per palette color (default purple, blue, teal, pink; 80% opacity, diameter 70% of the larger side). Each circle drifts on its own Lissajous path, x = cos(t·0.6 + phase)·30% width and y = sin(t·0.8 + phase·1.3)·30% height, where phase differs per index. Drive time from TimelineView(.animation) scaled by a speed parameter, blur the whole group with a ~60 pt radius, clip to bounds and hide it from accessibility.

## Mesh Gradient

A 3×3 MeshGradient whose points drift so the colours flow like liquid. Trigger: Loop. Requires iOS 18+. Files: Sources/MotionLibrary/Background/AnimatedMeshGradient.swift.

```swift
if #available(iOS 18, *) {
    AnimatedMeshGradient()
        .ignoresSafeArea()
}
```

How it works: Create a SwiftUI AnimatedMeshGradient view for iOS 18+ (mark it @available(iOS 18, macOS 15, visionOS 2, *)) with nine colours (indigo, purple, pink / blue, purple, orange / teal, mint, yellow by default; fewer are repeated) and a speed. Inside TimelineView(.animation), draw MeshGradient(width: 3, height: 3, points:colors:). Keep the four corners fixed; slide the four edge midpoints along their own edge by sin(t × 2π / period + offset) × 0.2, and move the centre point in both axes by 0.25, giving each a different period between 6 and 10 s so the motion never repeats visibly. Hide it from accessibility, and with Reduce Motion on, pause it.

## Retro Grid

A synthwave floor: a perspective grid scrolling toward you. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/RetroGrid.swift.

```swift
ZStack {
    Color.black
    RetroGrid(color: .pink)
    Text("NEON").font(.system(size: 60, weight: .black))
}
```

How it works: Create a SwiftUI RetroGrid view (iOS 17+) with color (pink), spacing (40 pt), speed (0.8 rows per second) and horizon (0.35 of the height). In a Canvas inside TimelineView(.animation): with top = height × horizon and depth = height − top, draw horizontal lines at y = top + depth / z for z = n + 1 − fract(time × speed), n = 0…39, so the bottom edge is z = 1, rows bunch up toward the horizon and every row moves toward the viewer; draw lines from the vanishing point (centre, top) to (centre + k × spacing, bottom) for enough k to cover the width. Stroke the path twice: 3 pt at 35 % opacity for a glow, then 1 pt solid. Mask the view with a vertical gradient that is clear down to the horizon and opaque 45 % lower, so lines fade into the distance. Hide from accessibility; Reduce Motion pauses it.

## Border Beam

A short comet of light runs around the card's border forever. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/BorderBeam.swift.

```swift
PlanCard()
    .background(.black, in: RoundedRectangle(cornerRadius: 20))
    .borderBeam(cornerRadius: 20)
```

How it works: Create a SwiftUI .borderBeam(cornerRadius:colors:lineWidth:length:duration:) view modifier (iOS 17+). In an overlay TimelineView(.animation), compute head = fract(time / duration) (4 s per lap). Stroke RoundedRectangle(cornerRadius:, style: .continuous).trim(from: head − length, to: head) with a LinearGradient of the colours (orange, pink, purple), lineWidth 2 pt and round caps; when head − length is negative, also stroke trim(from: 1 + head − length, to: 1) so the beam wraps past the path's start seamlessly. Draw the beam twice, once blurred by 2 × lineWidth underneath for a glow. Pad by lineWidth / 2, disable hit testing and hide from accessibility. With Reduce Motion on, park the beam.

## Waves

Layered sine waves roll across the bottom, back layers slower and paler. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/WaveBackground.swift.

```swift
ZStack(alignment: .top) {
    WaveBackground()
        .ignoresSafeArea()
    Text("Ocean").font(.largeTitle.bold()).padding(.top, 80)
}
```

How it works: Create a SwiftUI WaveBackground view (iOS 17+) with colors (one per layer, back to front: cyan 35 %, blue 45 %, indigo 70 %), amplitude (12 pt) and speed. In a Canvas inside TimelineView(.animation), for each layer with depth d = layer / (count − 1): baseline at height × (0.45 + 0.2 d), wavelength width × (0.9 − 0.3 d), phase = time × (0.6 + 0.5 d), alternating direction per layer. Build a path from the bottom-left corner along y = baseline + sin(x / wavelength × 2π + phase + layer) × amplitude × (0.7 + 0.3 d) sampled every 4 pt, down to the bottom-right corner, close it and fill it with the layer's colour. Hide from accessibility; Reduce Motion pauses it.

## Film Grain

Flickering film grain over any view, from a tiled noise texture. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/Grain.swift, Sources/MotionLibrary/Support/SeededRandom.swift.

```swift
LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
    .grain()

HeroImage()
    .grain(opacity: 0.2, isAnimated: false)
```

How it works: Create a SwiftUI .grain(opacity:isAnimated:) view modifier (iOS 17+). Generate a 128 × 128 grey noise CGImage once (8-bit DeviceGray, random bytes from a seeded generator, no interpolation). In an overlay, show it with Image(decorative:scale: 2).resizable(resizingMode: .tile) in a frame 64 pt larger than the view in each direction, clipped, and shift it by a different offset (frame × 37 mod 64, frame × 53 mod 64) 12 times a second using TimelineView(.periodic(by: 1/12)), so the grain flickers like film. Use .blendMode(.overlay) at opacity (0.35), disable hit testing and hide it from accessibility. With Reduce Motion on (or isAnimated false), keep the grain still.

## Flashlight

The view goes dark except a soft circle of light around the pointer. Trigger: Hover / Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Background/Flashlight.swift.

```swift
TreasureMap()
    .flashlight(radius: 100)
```

How it works: Create a SwiftUI .flashlight(radius:darkness:) view modifier (iOS 17+). Track the pointer with .onContinuousHover(coordinateSpace: .local) and a finger with a simultaneous DragGesture(minimumDistance: 0), storing the location in @State (nil on exit) plus the last location. In an overlay GeometryReader, draw a RadialGradient from clear to black at darkness (0.85) opacity, centred on the location as a UnitPoint, from startRadius 0.55 × radius to endRadius radius (90 pt), so everything outside the circle is dark with a soft edge. Fade the whole overlay out when the pointer leaves (lights back on) with easeOut(0.4 s), and follow the pointer with .interactiveSpring(response: 0.18). Disable hit testing. With Reduce Motion on, move without animation.

## Lava Lamp

Soft blobs drift up and down, stretching and merging like hot wax. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/LavaLamp.swift.

```swift
LavaLamp(colors: [.yellow, .orange, .pink])
    .ignoresSafeArea()
```

How it works: Create a SwiftUI LavaLamp(colors:background:blobs:speed:) view (iOS 17+). In TimelineView(.animation), fill a vertical LinearGradient of the colours, masked by a Canvas that adds .alphaThreshold(min: 0.5, color: .black) then .blur(radius: 7 % of the smaller side), and in drawLayer fills 7 black ellipses: blob i (seed = i × 1.618) at x = width × (0.2 + 0.6 × (0.5 + 0.5 sin(seed × 3.1 + t × 0.13))), y = height × (0.5 + 0.48 sin(t × (0.18 + 0.05 × (i % 3)) + seed × 2.3)), radius = min side × (0.11 + 0.07 × (0.5 + 0.5 sin(seed × 5.7))), stretched vertically by 1 + 0.25 |cos(t × 0.2 + seed × 2.3)|, plus wide pools of wax at the bottom and top. The threshold fuses the blurred blobs into liquid shapes (metaballs). Put the background colour (deep purple) behind. With Reduce Motion on, show one still frame.

## Matrix Rain

Columns of glyphs rain down with bright heads and fading trails. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/MatrixRain.swift.

```swift
MatrixRain(color: .green)
    .background(.black)
    .ignoresSafeArea()
```

How it works: Create a SwiftUI MatrixRain(color:fontSize:speed:) view (iOS 17+) drawn in a Canvas inside TimelineView(.animation). Resolve every glyph (half-width katakana plus digits, monospaced, 14 pt) once per frame in the trail colour and in white. Columns are fontSize × 0.9 wide, rows fontSize × 1.1 tall. For each column, a stable random seed sets the trail length (8–22), the speed (6–16 rows/s) and a phase; the head row = (time × speed + seed × 97) mod (rows + length). Draw the head white at full opacity and each trail cell below it with opacity 0.85 × (1 − offset / length), picking the glyph from a hash of (column, row, floor(time × (2 + seed × 4))) so characters flicker. With Reduce Motion on, show one still frame.

## Interactive Dot Grid

A grid of dots scatters away from your finger and eases back. Trigger: Drag / Hover / Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/InteractiveDotGrid.swift.

```swift
InteractiveDotGrid(spacing: 18)
    .ignoresSafeArea()
```

How it works: Create a SwiftUI InteractiveDotGrid(spacing:color:highlight:radius:) view (iOS 17+). Track the pointer from a DragGesture(minimumDistance: 0) and onContinuousHover (nil when released). In a Canvas inside TimelineView(.animation), smooth the pointer and a 0…1 strength each frame with exponential easing (k = 1 − e^(−14 dt) while active, strength decays with e^(−6 dt) after release) in a plain reference-type model. Draw a centred grid of dots every spacing points (18 pt): within radius (70 pt) of the pointer, near = (1 − d / radius)² × strength; push the dot away by near × spacing × 1.6, grow it by 2 × near and tint it with the highlight colour above 0.15. At rest, a faint wave sin((column + row) × 0.45 − time × 2) varies the radius by 0.5 pt. With Reduce Motion on, keep the highlight but don't move dots or run the wave.

## Meteors

Meteors streak across a starry sky with glowing heads and fading tails. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/Meteors.swift.

```swift
Meteors(count: 10)
    .background(Color(red: 0.03, green: 0.04, blue: 0.12))
    .ignoresSafeArea()
```

How it works: Create a SwiftUI Meteors(count:angle:color:showsStars:) view (iOS 17+) drawn in a Canvas inside TimelineView(.animation). Scatter 60 faint static stars (0.4–1.2 pt, 25–65 % opacity) from a stable hash. Each meteor i has a flight time of 1.6–3.8 s and a pause of 0.5–3 s; when in flight, its head moves from a start point spread along the top edge and the side it comes from along the direction (angle 135° in y-down coordinates, so they travel down and to the left) by (width + height) × 1.2 × progress. Stroke its 50–110 pt tail from the tail point to the head with a linear gradient clear → 90 % colour, 1.5 pt wide, round caps, and draw a 5 pt head with a 2 pt blur. With Reduce Motion on, draw the stars only.

## Flow Field

Generative curves follow a shifting vector field with dashes flowing along them. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/FlowField.swift.

```swift
FlowField(colors: [.cyan, .blue, .purple, .pink])
    .background(Color(white: 0.06))
    .ignoresSafeArea()
```

How it works: Create a SwiftUI FlowField(lines:colors:speed:) view (iOS 17+) drawn in a Canvas inside TimelineView(.animation). Define a flow angle field(x, y, t) = (sin(x × 0.012 + t) × cos(y × 0.014 − 0.7t) + sin((x + y) × 0.007 + 0.5t)) × π, with coordinates scaled so the smaller side maps to about 220 units and t = time × 0.25. For each of 140 lines, start at a stable random point and integrate 22 steps of 3.2 pt along the field into a Path. Stroke it in a colour picked from the list at 18 % opacity, then again at 85 % with a dash [5, 40] and dashPhase −((time × 30 + random × 45) mod 45), so short dashes travel along the curves (wrap the phase: a huge dash phase makes Core Graphics hang). With Reduce Motion on, show one still frame.

## Network

Drifting points link up with lines when close, and gather at your finger. Trigger: Loop / Hover / Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Background/NetworkBackground.swift.

```swift
NetworkBackground(color: .cyan)
    .background(.black)
    .ignoresSafeArea()
```

How it works: Create a SwiftUI NetworkBackground(count:linkDistance:color:interactive:) view (iOS 17+): a plexus of drifting points. In TimelineView(.animation) + Canvas, point i starts at a hashed position, moves at 6–20 pt/s in a hashed direction, and wraps around the edges with 20 pt of slack. Join every pair closer than linkDistance (70 pt) with a line of opacity 0.55 × (1 − d / linkDistance) and width 0.6 + 0.6 × that strength, then draw each point as a 3.6 pt dot. Track the pointer with onContinuousHover and a DragGesture(minimumDistance: 0); points within 110 pt are pulled towards it by (1 − d / 110) × 0.45 of the gap, so the web gathers under the finger. With Reduce Motion on, pause the timeline. Hide it from accessibility.

## Topographic Lines

Contour lines of a shifting landscape flow like a living map. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Background/TopographicLines.swift.

```swift
TopographicLines(color: .green)
    .background(Color(white: 0.06))
```

How it works: Create a SwiftUI TopographicLines(levels:scale:color:speed:) view (iOS 17+). In TimelineView(.animation(minimumInterval: 1/30)) + Canvas, sample a height field on an 8 pt grid: h = 0.65 × noise(x + t, y − 0.6t) + 0.35 × noise(2.1x − 0.8t, 2.1y + 7), with x, y in units of scale (90 pt), t = time × speed (0.12), and noise a smoothstep-interpolated value noise from an integer hash. For each of levels (14) thresholds spread over 0.18…0.82, trace the contour with marching squares (16 cases, edge crossings linearly interpolated, saddles drawn as two segments) into one Path and stroke it: every fifth line at 1.4 pt and 85 % opacity, the others 0.7 pt at 45 %. With Reduce Motion on, pause the timeline.

## Day & Night Sky

A sky runs from starry night through dawn, noon and sunset, sun and moon arcing over. Trigger: Loop / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Background/DayNightSky.swift.

```swift
DayNightSky()                // loops a day every 16 s
    .ignoresSafeArea()

DayNightSky(time: hour / 24) // follows the time of day
```

How it works: Create a SwiftUI DayNightSky(time:cycle:) view (iOS 17+). time is 0…1 (0 midnight, 0.25 sunrise, 0.5 noon, 0.75 sunset); nil loops it with TimelineView every cycle (16 s). Draw an Animatable scene in a Canvas: a vertical gradient whose top and horizon colours are interpolated between stops (night navy, deep purple dawn, pink-orange sunrise horizon, bright blue noon, golden afternoon, orange sunset horizon under violet, dusk). Fade in 50 hashed stars near night, twinkling. Put the sun and moon on opposite sides of an arc: x = mid − cos(angle) × 0.45w, y = horizon − sin(angle) × 0.75h, sun angle = (t − 0.25) × 2π, each with a blurred halo; the sun turns orange near the horizon. Finish with a band of dark hills tinted from the sky colour. Animate a fixed time with .easeInOut(duration: 1.2). With Reduce Motion on, hold at early evening (0.7).

## Rolling Number

Digits roll like an odometer when the value changes. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Number/RollingNumber.swift.

```swift
RollingNumber(value: score)
    .font(.system(size: 48, weight: .bold, design: .rounded))
```

How it works: Create a SwiftUI RollingNumber view (iOS 17+) that displays a number with odometer-style digit rolling. Render Text(value, format:) with monospacedDigit(), apply .contentTransition(.numericText(value:)) so digits roll up when the value increases and down when it decreases, and animate changes with .snappy. Provide initialisers for Int and for Double with a FloatingPointFormatStyle.

## Split-Flap Display

Characters flip through the alphabet like an airport departures board. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Number/SplitFlap.swift.

```swift
SplitFlapText(departure.time)   // "12:45"
```

How it works: Create a SwiftUI SplitFlapText(_ text:size:tile:ink:) view (iOS 17+), upper-casing the text, with one flap cell per character in an HStack. Each cell is size × 0.78 wide and size × 1.3 tall (size 36), drawn from four halves of a monospaced bold character on a rounded dark tile, each half clipped to the top or bottom half: static top = next character, static bottom = current, a top flap showing current rotated with rotation3DEffect about the x axis anchored at .bottom, and a bottom flap showing next anchored at .top; a thin dark line covers the seam. When the target changes, after a 0.05 s × index delay, step through the characters of the board alphabet " A…Z0…9:.-/" from current towards the target (at most the last 6 steps); each step folds the top flap 0 → −90° (.easeIn, 0.07 s), then the bottom flap 90° → 0 (.easeOut, 0.07 s), then commits next as current and resets the angles without animation. With Reduce Motion on, change instantly.

## Slot Machine

Number reels spin with motion blur and land one after another. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Number/SlotMachineNumber.swift.

```swift
SlotMachineNumber(value: score, digits: 3)
```

How it works: Create a SwiftUI SlotMachineNumber(value:digits:size:) view (iOS 17+) that zero-pads the value and shows one reel per digit. A reel is a VStack of 40 rows (row % 10, heavy rounded monospaced digits, size × 1.25 tall) offset by −index × rowHeight and clipped to one row, on a rounded secondary-12 % tile with a top/bottom shading gradient like a drum. When its digit changes from old to new: jump (no animation) to index old, set a blur of size × 0.06, and animate index to 30 + new with .timingCurve(0.3, 0, 0.2, 1.08) over 0.9 s + 0.25 s × reel order, so reels land left to right with a small overshoot; ease the blur off over the last 30 %, and on completion jump back to index new without animation. With Reduce Motion on, animate straight to the new digit in 0.3 s.

## Price Ticker

Digits roll to the new price as the background flashes green or red. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Number/PriceTicker.swift.

```swift
PriceTicker(value: stock.price)
    .font(.title2.bold())
```

How it works: Create a SwiftUI PriceTicker(value:fractionDigits:prefix:) view (iOS 17+): an HStack of a 10 pt "arrowtriangle.up.fill" / "arrowtriangle.down.fill" (hidden when flat) and the prefix + value formatted with fractionDigits decimals, monospacedDigit, with .contentTransition(.numericText(value:)) and .snappy(0.35 s) animation so digits roll. On change, record the direction (green up, red down) for the arrow and text colour, and bump a counter that drives keyframeAnimator on a rounded background in that colour: opacity 0 → 0.3 (0.05 s) → 0 (0.9 s), a quick flash. With Reduce Motion on, skip the roll animation and the flash.

## Animated Chart

Bars grow up one after another; a line draws itself left to right. Trigger: Appear / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Number/AnimatedChart.swift.

```swift
GrowingBarChart(values: weekly)
    .frame(height: 120)

DrawingLineChart(values: trend, color: .pink)
    .frame(height: 120)
```

How it works: Create two SwiftUI chart views without Swift Charts (iOS 17+). GrowingBarChart(values:color:spacing:): in a GeometryReader, an HStack(alignment: .bottom) of bars with top-rounded UnevenRoundedRectangles filled with the colour's gradient, bar width = width / (n + (n − 1) × spacing) with spacing 0.35; heights are 0 until onAppear sets grown, then height × value / max with .spring(duration: 0.6, bounce: 0.3) delayed 0.06 s × index, and springing to new heights when values change. DrawingLineChart(values:color:duration:): map values into the rect (5–6 pt inset), smooth with midpoint quadratic curves, stroke it 3 pt with round caps trimmed to progress, fill the closed area under it with a colour 35 % → clear gradient at opacity progress, and pop a 9 pt dot with a white ring onto the last point with a bouncy spring once progress reaches 1. In .task(id: values), reset progress to 0 without animation and animate to 1 with .easeInOut(1.2 s). With Reduce Motion on, use short eases.

## Needle Gauge

A speedometer needle swings to the value, overshoots and settles. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Number/NeedleGauge.swift.

```swift
NeedleGauge(value: cpuLoad)
    .frame(width: 200, height: 200)
```

How it works: Create a SwiftUI NeedleGauge(value:colors:label:) view (iOS 17+), value 0…1, square. Draw a 240° arc (from 150° to 30° clockwise, radius 42 % of the side, line width 8 %, round caps): a secondary-15 % track, and on top an animatable arc Shape trimmed to the value and stroked with an AngularGradient of green, yellow, red over the same angles. Add 11 tick capsules (longer every fifth) rotated from −120° to +120°, a primary-coloured needle capsule rotated −120° + 240° × value, and a hub circle. Animate the needle with .spring(duration: 0.9, bounce: 0.45) so it overshoots and settles. Below the hub, show the label or the percentage with .contentTransition(.numericText). With Reduce Motion on, use a 0.3 s ease.

## Contribution Grid

Activity squares pop in column by column, shaded by how busy each day was. Trigger: Appear / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Number/ContributionGrid.swift.

```swift
ContributionGrid(values: commitsPerDay, color: .green)
```

How it works: Create a SwiftUI ContributionGrid(values:rows:color:cellSize:spacing:) view (iOS 17+) like a contributions calendar: values fill columns of rows (7) top to bottom, left to right, as 11 pt squares with 3 pt gaps and corner radius 0.22 × size. Shade each square by its share of the largest value, rounded up to quarters: 0 is secondary at 15 %, otherwise the colour at 0.25 + 0.75 × level. On appear, scale each square from 0.2 and fade it in with .spring(duration: 0.4, bounce: 0.45) delayed by 0.035 s per column + 0.02 s per row, so it sweeps in diagonally; changes of shade use the same staggered spring. With Reduce Motion on, no scaling and a plain 0.3 s ease. Make it one accessibility element whose value is "N of M days active".

## Analog Clock

A clock with a sweeping second hand; set a time and the hands spring to it. Trigger: Loop / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Number/AnalogClock.swift.

```swift
AnalogClock()                       // live
    .frame(width: 160, height: 160)

AnalogClock(date: meeting, accent: .pink)
```

How it works: Create a SwiftUI AnalogClock(date:color:accent:timeZone:) view (iOS 17+) drawn in a Canvas at a 1:1 aspect ratio. Convert the date to local seconds = timeIntervalSinceReferenceDate + the zone's offset, so the hands only ever move forward. Face: a ring at 25 % opacity and 60 ticks (every fifth 2.5 pt and longer). Hands from s = seconds mod 43 200: hour angle s / 43 200 × 2π (length 0.5r, width 4.5 % of the side), minute (s mod 3600) / 3600 × 2π (0.75r, 3 %), second (s mod 60) / 60 × 2π in the accent colour with a short tail and a centre dot. With no date, update from TimelineView(.animation) so the second hand sweeps; with a date, make the face Animatable on seconds and animate changes with .spring(duration: 0.9, bounce: 0.3) so the hands turn forward to the new time. With Reduce Motion on, tick once per second with TimelineView(.periodic). Label it "Clock" with the time as its value.

## Particle Field

Drifting particles linked by faint lines, like a living constellation. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/ParticleField.swift, Sources/MotionLibrary/Support/SeededRandom.swift.

```swift
ZStack {
    Color.black.ignoresSafeArea()
    ParticleField(count: 60, color: .cyan)
        .ignoresSafeArea()
    Text("Connected").font(.largeTitle.bold())
}
```

How it works: Create a SwiftUI ParticleField view (iOS 17+) with count (50), color, speed (14 pt/s) and linkDistance (70 pt). Generate each particle's traits once from a seeded SplitMix64 generator: start position (0…1 in each axis), direction, speed factor (0.4–1.2), radius (1–2.8 pt) and opacity (0.4–1). In TimelineView(.animation) with a Canvas, compute each position as start + direction × time × speed × factor, wrapped around the canvas edges, so there is no stored state. Stroke a 0.8 pt line between every pair closer than linkDistance with opacity 0.35 × (1 − distance / linkDistance), then fill each particle as a circle. Hide it from accessibility, and with Reduce Motion on, freeze time.

## Starfield

Stars stream out of the centre and stretch into streaks: warp speed. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/Starfield.swift, Sources/MotionLibrary/Support/SeededRandom.swift.

```swift
Starfield()
    .background(.black)
    .ignoresSafeArea()

Starfield(count: 300, speed: 1.5) // warp jump
```

How it works: Create a SwiftUI Starfield view (iOS 17+) with count (200), speed (0.35 depth units per second) and color. Give each star a seeded random x and y in −1…1 and a depth in 0…1. In a Canvas inside TimelineView(.animation), compute z = 0.05 + 0.95 × fract(depth − time × speed), so stars approach the camera and wrap back to the far plane. Project with perspective: point = centre + (x, y) / z × 0.15 × half the larger side. Draw each star as a round-capped streak from its projection at a slightly larger z (z + min(0.08, speed × 0.05)) to its current projection, with opacity and line width growing as it gets closer. Hide it from accessibility, and with Reduce Motion on, freeze time.

## Cover Flow

Side items turn away in 3D, shrink and dim; the centre faces you. Trigger: Scroll. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/CoverFlow.swift.

```swift
CoverFlow(albums) { album in
    Image(album.artwork)
        .resizable()
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
}
.frame(height: 220)
```

How it works: Create a generic SwiftUI CoverFlow carousel (iOS 17+) over Identifiable items with an optional selection binding, itemWidth (140), spacing (−10) and maxAngle (50°). Use a horizontal ScrollView + LazyHStack with .scrollTargetLayout(), .scrollTargetBehavior(.viewAligned), hidden indicators, .scrollPosition(id:anchor: .center) and contentMargins that centre the first and last items. In .visualEffect, read the item's frame in the .scrollView coordinate space, compute p = clamp((midX − viewport centre) / itemWidth, −1, 1) and apply rotation3DEffect of −p × maxAngle around the y axis (perspective 0.6), scale 1 − |p| × 0.18 and brightness −|p| × 0.25. Raise the selected item's zIndex. With Reduce Motion on, drop the rotation.

## Float 3D

The view hovers: a gentle bob, a slow 3D sway and a breathing shadow. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/Float3D.swift.

```swift
Image("product")
    .resizable()
    .scaledToFit()
    .frame(width: 180)
    .float3D()

BadgeView()
    .float3D(height: 6, angle: 8, period: 4, shadow: false)
```

How it works: Create a SwiftUI .float3D(height:angle:period:shadow:) view modifier (iOS 17+). Inside TimelineView(.animation), let t = time × 2π / period (3 s) and lift = 0.5 + 0.5·sin t. Rotate the content in 3D by sin(t/2) × angle (12°) around the y axis and cos(0.7t) × angle/2 around the x axis (perspective 0.5), and move it up by height (10 pt) × lift. Behind it, at the bottom, draw a black ellipse 12 pt tall, 18 pt below, that gets lighter (opacity 0.25 − 0.1·lift), narrower (scale x 0.75 − 0.15·lift) and blurrier (6 + 4·lift) as the view rises. With Reduce Motion on, pause the timeline.

## Fireworks

Rockets climb and burst into rings of falling, fading sparks. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/Fireworks.swift, Sources/MotionLibrary/Support/SeededRandom.swift.

```swift
ZStack {
    Color.black.ignoresSafeArea()
    Fireworks()
        .ignoresSafeArea()
    Text("Happy New Year").font(.largeTitle.bold())
}
```

How it works: Create a SwiftUI Fireworks view (iOS 17+) with colors, interval (0.9 s between launches) and sparks (36 per burst), drawn statelessly in a Canvas inside TimelineView(.animation). Rocket k launches at k × interval; for every rocket younger than 0.8 s climb + 1.5 s fade, seed a SplitMix64 generator with k to pick x (15–85 % of the width), peak height (15–45 %), colour and reach (22–34 % of the smaller side). Climbing: ease-out from the bottom to the peak and draw a 14 pt trail. Bursting, with t = time since the burst / 1.5: place each spark at angle i / sparks × 2π (plus jitter), distance reach × (1 − (1 − min(1, 1.6 t))³) × random 0.75–1, add gravity fall t² × 0.6 × reach, draw a circle of radius 1.8 × (1 − 0.6 t) at opacity 1 − t, and add a white flash for the first 15 %. Hide from accessibility; with Reduce Motion on, freeze on a frame with a burst in bloom.

## Snowfall & Rain

Drifting, swaying snowflakes or fast slanted rain, with depth. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/Snowfall.swift, Sources/MotionLibrary/Support/SeededRandom.swift.

```swift
Snowfall()
    .background(.indigo)
    .ignoresSafeArea()

Snowfall(.rain, count: 150, color: .white.opacity(0.8))
```

How it works: Create a SwiftUI Snowfall view (iOS 17+) with a style (.snow or .rain), count (80), color and speed. Give each particle seeded random traits: start x and y (0–1), depth (0–1) and phase. In a Canvas inside TimelineView(.animation), compute positions as pure functions of time, wrapped around the view so nothing is stored. Snow: fall speed 18 + 30 × depth pt/s, horizontal sway sin(time × (0.8 + depth) + phase) × (6 + 10 × depth) plus a slow 4 pt/s drift, radius 1 + 2.4 × depth, opacity 0.35 + 0.6 × depth, so small flakes look far away. Rain: fall speed 380 + 320 × depth, a streak 8 + 14 × depth long slanted by 0.25, width 0.8 + 0.8 × depth, opacity 0.25 + 0.5 × depth. Hide from accessibility; Reduce Motion pauses it.

## Floating Reactions

Live-stream style emoji float up, swaying, every time you react. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/FloatingReactions.swift.

```swift
LiveVideo()
    .floatingReactions(trigger: reactionCount)

Button("❤️") { reactionCount += 1 }
```

How it works: Create a SwiftUI .floatingReactions(trigger:emojis:height:) view modifier (iOS 17+). Every time trigger changes, append a reaction (UUID, a random emoji from the list, a random sway of ±8–18 pt and drift of ±20 pt) to a @State array and remove it 2.3 s later. In a bottom-aligned, hit-testing-disabled overlay, show each emoji (28 pt) with keyframeAnimator(initialValue:trigger:), triggered by a @State flag set in onAppear so it plays once, over {y, x, scale, opacity}: y goes to −height (160 pt) over 2.2 s; x weaves sway → −sway + drift → sway + drift → drift in four 0.55 s cubic keyframes; scale springs from 0.3 to 1.15 and settles at 1; opacity holds for 1.4 s then fades over 0.8 s. With Reduce Motion on, don't spawn reactions.

## Warp Tunnel

Rings rush out of the vanishing point toward you: flying down a tunnel. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/WarpTunnel.swift.

```swift
WarpTunnel()
    .background(.black)
    .ignoresSafeArea()

WarpTunnel(colors: [.green, .mint], sides: 6) // hexagons
```

How it works: Create a SwiftUI WarpTunnel view (iOS 17+) with rings (18), colors (cyan, blue, purple, pink), speed (1.2 rings per second) and sides (0 for circles, 3+ for polygons). In a Canvas inside TimelineView(.animation), for ring i let depth = 1 − (i + fract(time × speed)) / rings and skip depths below 0.02. Its radius is half the view's diagonal × 0.06 / depth (perspective), skipped once it's 1.5 × larger than that. Stroke a circle, or a polygon rotated by i × 0.12 + time × 0.1 rad, centred in the view, with opacity closeness² and line width 0.5 + 3 × closeness (closeness = 1 − depth), cycling colours by ring. Hide from accessibility; Reduce Motion pauses it.

## Holographic Card

A trading card that tilts toward you with a rainbow foil and moving glare. Trigger: Hover / Drag. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/Holographic.swift.

```swift
Image("card-art")
    .resizable()
    .aspectRatio(5 / 7, contentMode: .fit)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .holographic(cornerRadius: 16)
```

How it works: Create a SwiftUI .holographic(cornerRadius:maxAngle:) view modifier (iOS 17+). Track the pointer with .onContinuousHover and a finger with a simultaneous DragGesture(minimumDistance: 0), normalising the location to p in −1…1 on both axes (nil when released). Overlay, clipped to a continuous rounded rectangle: (1) a rainbow LinearGradient (red → … → purple → red) from (−0.5 + 0.6 px, −0.5 + 0.3 py) to (1.5 + 0.6 px, 1.5 + 0.3 py) with .blendMode(.overlay), at 55 % opacity while touched and 15 % at rest; (2) a white 70 % → clear RadialGradient centred at (0.5 + 0.5 px, 0.5 + 0.5 py) with .blendMode(.softLight), visible only while touched. Tilt with rotation3DEffect: −py × maxAngle (14°) around x and px × maxAngle around y, perspective 0.6, and scale to 1.03 while touched. Follow with .interactiveSpring(response: 0.25) and release with .spring(response: 0.5, dampingFraction: 0.6). With Reduce Motion on, keep the foil and glare but don't tilt or scale.

## Physics Emoji

Emoji tumble in with gravity, bounce off each other and pile up. Trigger: Value change / Tap. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/PhysicsEmoji.swift.

```swift
PhysicsEmoji(trigger: drops)
    .frame(height: 300)
    .onTapGesture { drops += 1 }
```

How it works: Create a SwiftUI PhysicsEmoji(trigger:emojis:batch:size:) view (iOS 17+) with a tiny physics world in a plain reference type stepped from a Canvas inside TimelineView(.animation). Each change of trigger drops batch (6) bodies of radius size / 2 (30 pt emoji) at random x above the top with small random velocities and spin; keep at most 36, removing the oldest. Each frame (dt capped at 1/30 s, two substeps): add gravity 1400 pt/s², integrate, bounce off the floor with restitution 0.45 (stopping tiny bounces below 30 pt/s), damp sideways speed by 0.9 and make spin follow rolling speed (vx / r), bounce off the side walls, then resolve circle–circle overlaps by pushing pairs apart along the normal and exchanging the normal impulse −(1 + e) × relative / 2. Decay spin by 0.97 per frame. Draw each emoji (resolved once per frame) translated and rotated. Disable hit testing and hide from accessibility. With Reduce Motion on, place new emoji directly on the floor without falling.

## Shatter

The view breaks into triangular shards that fly, spin and fall away. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/Shatter.swift.

```swift
if !isBroken {
    GlassPane()
        .transition(.shatter)
}
```

How it works: Create a SwiftUI ShatterTransition (iOS 17+, Transition) with a static .shatter accessor. Build shards in unit coordinates from a 4 × 3 grid whose interior points are jittered by ±30 % of a cell, splitting each cell into two triangles along alternating diagonals. Removal applies an Animatable ViewModifier with progress 0 → 1 that renders the plain content at 0 (so an intact view isn't drawn once per shard) and otherwise a ZStack of the content masked by each triangle Shape (with a 0.8 pt stroke bleed to hide seams), rotated around its centroid by (r − 0.5) × 220° × p, offset along the centre-to-centroid direction by 110 pt × (0.6 + 0.6r) × p horizontally and 0.6 × 110 × p plus a falling 0.9 × 110 × p² vertically, with opacity 1 − p². Insertion just scales up from 0.9 and fades in. Read Reduce Motion in an inner View (Transition structs can't hold @Environment) and then use distance and spin 0 so shards only fade.

## 3D Cube

Views swap by turning a cube: one face folds away as the next rotates in. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/CubeTransition.swift.

```swift
ZStack {
    PageView(page)
        .id(page)
        .transition(.cube)
}
.clipped()
```

How it works: Create a SwiftUI CubeTransition (iOS 17+, Transition) with .cube and .cube(edge:) accessors. Map the phase to a position: willAppear = +1 (waiting on the trailing side), identity = 0, didDisappear = −1 (flip the signs for edge .leading). Inside visualEffect (to read the view's width), apply offset(x: width × position) and rotation3DEffect(90° × position, axis y, anchor .leading when position > 0 else .trailing, perspective 0.5). Halfway through, the outgoing face's trailing edge and the incoming face's leading edge meet in the middle like two faces of a cube. Read Reduce Motion in an inner View and cross-fade instead.

## Dot Globe

A globe of evenly spread dots spins on a tilted axis, with pulsing cities. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/DotGlobe.swift.

```swift
DotGlobe(dots: 700, color: .cyan)
    .frame(width: 260, height: 260)
```

How it works: Create a SwiftUI DotGlobe(dots:color:accent:speed:) view (iOS 17+), square, drawn in a Canvas inside TimelineView(.animation). Place 700 points on a unit sphere with the Fibonacci method (y = 1 − 2(i + 0.5)/n, ring = √(1 − y²), θ = golden angle × i + time × 0.6), tilt them 0.35 rad around the x axis, and project orthographically onto a circle of radius 45 % of the side. With depth = (z + 1) / 2, draw each dot with radius (0.6 + 1.2 × depth) and opacity 0.12 + 0.88 × depth², so the back is faint. Every 61st dot is a "city" in the accent colour (on the front half) whose radius pulses with sin(time × 3 + i). Add a faint 15 % rim circle. With Reduce Motion on, don't rotate.

## Bubbles

Soap bubbles rise and wobble with rainbow rims and glossy highlights. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/Bubbles.swift.

```swift
Bubbles(count: 18)
    .background(LinearGradient(colors: [.blue.opacity(0.5), .indigo], startPoint: .top, endPoint: .bottom))
```

How it works: Create a SwiftUI Bubbles(count:color:speed:) view (iOS 17+) drawn in a Canvas inside TimelineView(.animation). Each of 18 bubbles has a stable random radius (6–22 pt), rise time (4–8 s), phase and x; progress = ((time + phase) / duration) mod 1 moves it from below the bottom to above the top while x wobbles by 14 pt × sin(time × (1 + r) + i). Fade in over the first ~17 % and out over the last 20 %. Fill each with a radial gradient (2 % → 12 % → 35 % of the tint, transparent centre), stroke a 1 pt rim with a diagonal pink → tint → purple gradient, and add a small white oval highlight at the top-left. With Reduce Motion on, show one still frame.

## Fireflies

Glowing fireflies drift lazily and blink on their own rhythms. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/Fireflies.swift.

```swift
Fireflies(count: 24)
    .background(Color(red: 0.02, green: 0.06, blue: 0.05))
```

How it works: Create a SwiftUI Fireflies(count:color:speed:) view (iOS 17+) drawn in a Canvas inside TimelineView(.animation). Each firefly has three stable random values a, b, c; its position is the view centre plus two layered sines per axis (x: 0.38 sin(t(0.13 + 0.12a) + 20a) + 0.1 sin(t(0.5 + 0.3b) + 9b); y: 0.36 sin(t(0.11 + 0.1b) + 17b) + 0.1 cos(t(0.45 + 0.3c) + 5c), as fractions of the size), giving slow wandering loops. Its blink = (0.5 + 0.5 sin(t(0.8 + 1.6c) + 30a))³. Draw a glow circle 8 × r wide in a context with .blur(radius: 6) at opacity 0.25 + 0.75 × blink, then a white core of radius r (1.6–2.8 pt) at 0.35 + 0.65 × blink. Warm yellow by default. With Reduce Motion on, freeze positions but keep the blinking.

## Flock

Little arrows swim together like birds or fish, and chase your finger. Trigger: Loop / Drag / Hover. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/Flock.swift.

```swift
Flock(count: 60, color: .white)
    .background(.indigo.gradient)
```

How it works: Create a SwiftUI Flock(count:color:speed:) view (iOS 17+) that simulates boids. Keep the boids (position, velocity) in a reference-type model stored in @State and advance it from a Canvas inside TimelineView(.animation), with dt = time since the last frame capped at 1/20 s. For each boid, look at neighbours within 46 pt: steer 5 % towards their average velocity, 1.2 % towards their centre, and away from any closer than 16 pt by 0.14 × the overlap. If there's a target (from onContinuousHover or a DragGesture(minimumDistance: 0)), add 2 % of the gap to it. Push back by 9 within 24 pt of an edge. Clamp speed between 0.6 and 1.3 × cruise (90 pt/s, 1.5× when chasing). Draw each boid as a small arrowhead path rotated to atan2 of its velocity. With Reduce Motion on, freeze them. Hide it from accessibility.

## Ink Trail

The pointer or finger leaves puffs of ink that swell, drift up and fade. Trigger: Drag / Hover. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/InkTrail.swift.

```swift
Color.black
    .inkTrail(color: .purple)
```

How it works: Create a SwiftUI .inkTrail(color:lifetime:size:) view modifier (iOS 17+). Record puffs (point, time, random seed) from onContinuousHover and a simultaneous DragGesture(minimumDistance: 0), skipping points closer than 0.18 × size to the last one within 50 ms and dropping puffs older than lifetime (1.2 s). Draw them in an overlay Canvas inside TimelineView(.animation) with a blur of 0.35 × size: at age a (0…1) a puff has radius size × (0.35 + 0.9a) (size 26 pt), rises 34a pt, sways sideways by sin(seed × 9 + 3a) × 14a pt, and has opacity 0.85 × (1 − a)². Disable hit testing on the overlay. With Reduce Motion on, record nothing.

## Rain on Glass

Raindrops cling to a window while bigger drops slide down in fits and starts. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/RainOnGlass.swift.

```swift
Image("city-night")
    .blur(radius: 6)
    .overlay(RainOnGlass())
```

How it works: Create a SwiftUI RainOnGlass(drops:tint:) overlay (iOS 17+) in TimelineView(.animation) + Canvas. Scatter one static bead per 900 pt² at hashed positions with radius 0.8–2.6 pt. Each of the sliding drops (9) has a cycle of 3.5–7.5 s; its progress l through the cycle becomes stick-slip motion with five steps, (floor(5l) + frac(5l)³) / 5, carrying it from a hashed start near the top past the bottom edge, with a 3 pt sideways wobble and radius 3.2–5.8 pt, stretched 1.25× vertically. Behind it, leave a trail of tiny beads every 9 pt with hashed jitter. Draw every drop like a tiny lens: an ellipse filled with a diagonal gradient (tint 35 % → tint 5 % → black 35 %) plus a bright fleck at the top-left. Disable hit testing. With Reduce Motion on, pause the timeline.

## Orbits

Planets circle a glowing star on tilted orbits, passing behind it and in front. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionLibrary/Particle/Orbits.swift.

```swift
Orbits(colors: [.orange, .cyan, .pink])
    .frame(width: 240, height: 160)
```

How it works: Create a SwiftUI Orbits(colors:tilt:centerColor:) view (iOS 17+) in TimelineView(.animation) + Canvas. Each colour is a planet on its own orbit, radius spread from 0.38 to 1 × the largest radius that fits (an ellipse squashed vertically by tilt, 0.38). Period = 2.4 × (2r / maxR)^1.5 s so inner planets move faster; angle = time / period × 2π + 2.1 × index; position = centre + (cos a × r, sin a × r × tilt); depth = sin a. Stroke each orbit at white 14 %. Draw the planets with depth < 0 first, then the star (a 20 pt circle over a 32 pt blurred halo at 70 %), then the ones in front, so they pass behind and in front of it. Scale planets by 0.75 + 0.25 × (depth + 1) / 2 and dim the far ones. With Reduce Motion on, pause the timeline.

## Iris

A circle opens from a point to reveal the view, like a camera iris. Trigger: Appear. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/MaskTransitions.swift.

```swift
if showPhoto {
    PhotoView()
        .transition(.iris)
}

DetailView()
    .transition(.iris(origin: .topTrailing))
```

How it works: Create a custom SwiftUI Transition (iOS 17+, the Transition protocol) called IrisTransition with an origin UnitPoint (centre), exposed as .iris and .iris(origin:). In body(content:phase:), mask the content with a GeometryReader containing a Circle whose radius is the distance from the origin point to the furthest corner, positioned at the origin, with scaleEffect(phase.isIdentity ? 1 : 0.001, anchor: origin). The circle grows from the origin to cover the view on insertion and closes back on removal, timed by whatever animation drives the change, e.g. withAnimation(.easeInOut(duration: 0.6)). It only masks, so it needs no Reduce Motion fallback.

## Blinds

Horizontal slats open together to reveal the view, like Venetian blinds. Trigger: Appear. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/MaskTransitions.swift.

```swift
Banner()
    .transition(.blinds)

Poster()
    .transition(.blinds(slats: 12))
```

How it works: Create a custom SwiftUI Transition (iOS 17+) called BlindsTransition with a slats count (8), exposed as .blinds and .blinds(slats:). In body(content:phase:), mask the content with a VStack(spacing: 0) of slats Rectangles, each with scaleEffect(y: phase.isIdentity ? 1 : 0.001, anchor: .top), so every slat grows down from its top edge at the same time on insertion and folds back up on removal. It only masks, so it needs no Reduce Motion fallback.

## Clock Wipe

A wedge sweeps clockwise from twelve o'clock, like a clock hand. Trigger: Appear. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/MaskTransitions.swift.

```swift
Badge()
    .transition(.clockWipe)
```

How it works: Create a custom SwiftUI Transition (iOS 17+) called ClockWipeTransition, exposed as .clockWipe. Mask the content with an animatable Shape whose animatableData is progress (0…1): it returns the full rect at 1, an empty path at 0, and otherwise a pie wedge from the centre with radius equal to the rect's diagonal, from −90° to −90° + 360° × progress (clockwise: false, which sweeps clockwise on screen in SwiftUI's y-down space). Pass progress 1 when phase.isIdentity and 0 otherwise, so the animation interpolates the angle. It only masks, so it needs no Reduce Motion fallback.

## Pixel Dissolve

The view appears and vanishes in square pixels, in random order. Trigger: Appear. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/MaskTransitions.swift.

```swift
Avatar()
    .transition(.dissolve)

Artwork()
    .transition(.dissolve(cellSize: 6))
```

How it works: Create a custom SwiftUI Transition (iOS 17+) called DissolveTransition with a cellSize (10 pt), exposed as .dissolve and .dissolve(cellSize:). Mask the content with an animatable Shape whose animatableData is progress (0…1): divide the rect into a grid of cellSize squares, give each cell a stable pseudo-random threshold in 0…1 from an integer hash of (column, row), and add the cells whose threshold is below progress (outset by 0.25 pt so neighbours don't leave seams); return the full rect at 1 and an empty path at 0. Pass progress 1 when phase.isIdentity and 0 otherwise. It only masks, so it needs no Reduce Motion fallback.

## Poof

The view puffs away like smoke: it swells and blurs out. Trigger: Appear. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/StyleTransitions.swift.

```swift
ForEach(notes) { note in
    NoteRow(note)
        .transition(.poof)
}
```

How it works: Create a custom SwiftUI Transition (iOS 17+) called PoofTransition, exposed as .poof. Return a small view that reads Reduce Motion and applies: scale 1.35 when phase == .didDisappear, 0.7 when .willAppear, 1 at identity; blur radius 14 when not identity, 0 at identity; opacity 0 when not identity. Removal swells and blurs away like smoke, insertion condenses in from a smaller blur. With Reduce Motion on, keep the scale at 1 (blur and fade only).

## Swoosh

The view whooshes in leaning forward, with a motion blur. Trigger: Appear. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/StyleTransitions.swift.

```swift
if let toast {
    ToastView(toast)
        .transition(.swoosh)
}
```

How it works: Create a custom SwiftUI Transition (iOS 17+) called SwooshTransition, exposed as .swoosh. Use phase.value (−1 before insertion, 0 at rest, +1 after removal) as v and apply a GeometryEffect whose animatableData is v: a CGAffineTransform with c = −0.6 v (a horizontal skew) and tx = v × width − c × height / 2 (slide by the view's own width, skewing around the vertical centre). Add blur 6 × |v| and opacity 1 − |v|, so it whooshes in from the leading edge leaning into the motion and leaves to the trailing edge. With Reduce Motion on, skip the slide and skew (fade only).

## Film Exposure

The view develops like a photo, from over-exposed white to full colour. Trigger: Appear. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/StyleTransitions.swift.

```swift
AsyncImage(url: url) { image in
    image.resizable()
        .transition(.filmExposure)
} placeholder: {
    ProgressView()
}
```

How it works: Create a custom SwiftUI Transition (iOS 17+) called FilmExposureTransition, exposed as .filmExposure. When the phase isn't identity, apply brightness 0.9, saturation 0 and opacity 0; at identity, brightness 0, saturation 1 and opacity 1. Inserting the view develops it like a photo, from blown-out colourless white to full colour, and removing it fades it back out to white. Nothing moves, so it needs no Reduce Motion fallback.

## Circular Reveal

New content spreads out in a circle from where you tapped. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/CircularReveal.swift.

```swift
CircularReveal(value: isDark, origin: tapPoint) { dark in
    ThemePreview(dark: dark)
}
```

How it works: Create a generic SwiftUI CircularReveal(value:origin:duration:content:) view (iOS 17+) where origin is a UnitPoint. Keep @State shown (initially value), incoming (optional) and progress. When value changes: if a reveal is in flight, commit it; set incoming = new and progress = 0 without animation, then animate progress to 1 with .easeInOut(0.7 s) and, on completion, set shown = new and incoming = nil without animation. Render ZStack { content(shown); content(incoming) masked by an animatable circle Shape centred at origin whose radius is progress × the distance to the furthest corner }, with hit testing off on the incoming layer. To start at a tap, convert the location with UnitPoint(x: x / width, y: y / height). With Reduce Motion on, cross-fade the incoming layer instead of growing the circle.

## Liquid Swipe

The next page pours in from the edge behind a bulging liquid wave. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/LiquidSwipe.swift.

```swift
ZStack {
    OnboardingPage(page)
        .id(page)
        .transition(.liquidSwipe)
}
```

How it works: Create a SwiftUI LiquidSwipeTransition (iOS 17+, Transition) with a .liquidSwipe accessor. Mask the content with an animatable Shape whose progress is 0 on willAppear and 1 otherwise: at progress p it covers the view from the trailing edge to edge = maxX − (width + a) × p, where the bulge a = 0.35 × width × sin(πp); the leading boundary is straight except for a wave from midY − 0.45h to midY + 0.45h drawn with two cubic curves that bulge out to edge − a at midY. Darken the outgoing view with brightness −0.15 and give the incoming view zIndex 1 so it draws on top. Read Reduce Motion in an inner View and use no bulge.

## Page Turn

The old page swings away like a book page, revealing the next one. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/PageTurn.swift.

```swift
ZStack {
    ChapterView(chapter)
        .id(chapter)
        .transition(.pageTurn)
}
```

How it works: Create a SwiftUI PageTurnTransition (iOS 17+, Transition) with a .pageTurn accessor. The outgoing view gets zIndex 1 and an Animatable ViewModifier with progress 0 → 1: rotation3DEffect(−90° × p, axis y, anchor .leading, perspective 0.6), an overlay LinearGradient from clear to black at 45 % × p (leading → trailing) so the free edge darkens as it turns, a shadow of opacity 0.3 × sin(πp), radius 12, x 6, and opacity 0 at the very end. The incoming view sits underneath and brightens from −0.25 to 0. Read Reduce Motion in an inner View and simply fade the page out.

## Glitch Transition

The view breaks up like a bad signal on its way in or out. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/GlitchTransition.swift, Sources/MotionLibrary/Support/GlitchSlice.swift.

```swift
if showAlert {
    AlertBanner()
        .transition(.glitch)
}
```

How it works: Create a SwiftUI GlitchTransition (iOS 17+, Transition) with .glitch and .glitch(slices:) accessors that applies an Animatable ViewModifier with amount 0 (identity) → 1 (inserted or removed). At 0 render the content as is. Otherwise, with frame = Int(amount × 16) so the pattern changes in steps: stack a red copy (colorMultiply(.red), offset x −amount × 10, 60 %), a cyan copy (offset +amount × 10, 60 %) and 7 horizontal slices of the content, each masked to its band and offset sideways by (random(slice, frame) − 0.5) × 60 × amount; composite them and set opacity to 1 − 0.6 × amount, or 0.15 when random(frame) ≤ 0.9 × amount, reaching 0 at the end. Read Reduce Motion in an inner View and fade instead.

## Origami Fold

The view folds up into creased panels like a paper map. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/OrigamiFold.swift, Sources/MotionLibrary/Support/GlitchSlice.swift.

```swift
if showTicket {
    TicketView()
        .transition(.origami)
}
```

How it works: Create a SwiftUI OrigamiTransition (iOS 17+, Transition) with .origami and .origami(folds:) accessors applying an Animatable ViewModifier with progress 0 (flat) → 1 (folded). At 0 render the content. Otherwise keep the footprint with content.hidden() and, in a top-aligned overlay GeometryReader, draw 4 copies of the content, each masked to its horizontal panel. With angle = 90° × p and c = cos(angle): even panels hinge on their top edge (rotation3DEffect +angle about x, anchor at y = i / n), odd panels on their bottom edge (−angle, anchor (i + 1) / n), and each is offset by hinge × panelHeight × (c − 1) so it starts where the previous one ends, collapsing like an accordion towards the top. Shade panels with black at (0.1 even, 0.4 odd) × (1 − c), perspective 0.4, and fade out over the last 15 %. Read Reduce Motion in an inner View and fade instead.

## Ink Bleed

New content spreads in like a blot of ink on wet paper, with a ragged edge. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/InkBleed.swift.

```swift
if showsDetail {
    DetailCard()
        .transition(.inkBleed(from: .topLeading))
}
```

How it works: Create a SwiftUI Transition .inkBleed / .inkBleed(from: UnitPoint) (iOS 17+) that masks the content with an Animatable blot view whose progress is 1 when the phase is identity and 0 otherwise. The blot is a Canvas with .alphaThreshold(min: 0.5) and a blur of max(2, 0.06r), drawing into a layer: a circle of radius 0.82r at the origin plus 26 circles around it, at angle i / 26 × 2π + hashed jitter, distance r × (0.62–0.92) and radius r × (0.12–0.32). r = (1.25 × distance to the furthest corner + 30) × progress, so blurring then thresholding melts them into one ragged blot that clears the corners at 1. With Reduce Motion on, fade instead.

## Zoom Blur

Content rushes in from the camera, blurred and trailed by echoes, then snaps sharp. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionLibrary/Transition/ZoomBlur.swift.

```swift
Text(title)
    .id(title)
    .transition(.zoomBlur)
```

How it works: Create a SwiftUI Transition .zoomBlur / .zoomBlur(scale:) (iOS 17+). In an Animatable modifier with amount 0 (in place) … 1 (away), scale the content to 1 + (scale − 1) × amount (scale 1.6), blur it by 14 × amount and fade it to 1 − amount. While 0 < amount < 1, add three echo copies behind it, each a little larger (+ 0.12 × step × amount), blurrier (6 + 6 × step × amount) and fainter ((1 − amount) × 0.28 / step), as a cheap radial zoom blur. The phase maps identity to 0 and both insertion and removal to 1, so it rushes in from the camera and out past it. With Reduce Motion on, fade instead.

## Water Ripple

A real ripple distorts the view's pixels outward from a tap. Trigger: Tap / Value change. Requires iOS 17+. Files: Sources/MotionShaders/WaterRipple.swift, Sources/MotionShaders/Shaders/WaterRipple.metal.

```swift
import MotionShaders

Image("pond")
    .waterRippleOnTap()

Card()
    .waterRipple(at: tapLocation, trigger: tapCount)
```

How it works: Create a SwiftUI .waterRipple(at:trigger:amplitude:duration:) view modifier (iOS 17+) using a Metal [[stitchable]] layer shader. The shader takes (float2 position, SwiftUI::Layer layer, float2 origin, float time, float amplitude, float frequency, float decay, float speed): distance = length(position − origin), local = max(0, time − distance / speed), wave = amplitude × sin(frequency × local) × exp(−decay × local); sample the layer at position + wave × normalize(position − origin) and add 0.25 × wave / amplitude to rgb (times alpha) so crests brighten. In Swift, run keyframeAnimator(initialValue: 0, trigger:) with MoveKeyframe(0) and a LinearKeyframe to duration (3 s) over duration, and apply .visualEffect { $0.layerEffect(ShaderLibrary.motionRipple(.float2(origin), .float(elapsed), .float(12), .float(15), .float(8), .float(1200)), maxSampleOffset: CGSize(width: 12, height: 12), isEnabled: 0 < elapsed < duration) }. Add .waterRippleOnTap() that records a SpatialTapGesture location (as a simultaneous gesture) and bumps the trigger. With Reduce Motion on, disable the effect.

## Pixellate

The view melts into a mosaic of square blocks and back. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionShaders/Pixellate.swift, Sources/MotionShaders/Shaders/Pixellate.metal.

```swift
import MotionShaders

Avatar()
    .pixellate(isHidden ? 18 : 1)
    .animation(.easeInOut, value: isHidden)
```

How it works: Create a SwiftUI .pixellate(_ size:) view modifier (iOS 17+) as an Animatable ViewModifier over size, so withAnimation interpolates the block size. It applies .layerEffect(ShaderLibrary.motionPixellate(.float(size)), maxSampleOffset: CGSize(width: size, height: size), isEnabled: size > 1). The Metal [[stitchable]] shader (float2 position, SwiftUI::Layer layer, float size) returns layer.sample(position) when size ≤ 1, otherwise layer.sample((floor(position / size) + 0.5) × size), one colour per block.

## Chromatic Aberration

Red and blue split sideways like a cheap lens; animate it on a beat. Trigger: Value change / Loop. Requires iOS 17+. Files: Sources/MotionShaders/ChromaticAberration.swift, Sources/MotionShaders/Shaders/ChromaticAberration.metal.

```swift
import MotionShaders

Text("BASS DROP")
    .font(.largeTitle.weight(.black))
    .chromaticAberration(isPlaying ? 6 : 0)
```

How it works: Create a SwiftUI .chromaticAberration(_ amount:) view modifier (iOS 17+) as an Animatable ViewModifier over amount, applying .layerEffect(ShaderLibrary.motionChromatic(.float(amount)), maxSampleOffset: CGSize(width: |amount|, height: 0), isEnabled: |amount| > 0.01). The Metal [[stitchable]] shader (float2 position, SwiftUI::Layer layer, float amount) samples red at position + (amount, 0), green at position and blue at position − (amount, 0), with alpha = the max of the three samples' alpha. For a beat, spike amount to 7 pt with withAnimation(.easeOut(duration: 0.12)) and, in its completion, ease back to 1.5 over 0.5 s.

## CRT Screen

Curved glass, scanlines, a rolling band and flicker, like an old monitor. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionShaders/CRT.swift, Sources/MotionShaders/Shaders/CRT.metal.

```swift
import MotionShaders

GameView()
    .crtScreen()
    .clipShape(RoundedRectangle(cornerRadius: 24))
```

How it works: Create a SwiftUI .crtScreen(curvature:) view modifier (iOS 17+). Inside TimelineView(.animation), apply .visualEffect { $0.layerEffect(ShaderLibrary.motionCRT(.float2(proxy.size), .float(time), .float(curvature)), maxSampleOffset: size × curvature) } with curvature 0.06. The Metal [[stitchable]] shader (position, SwiftUI::Layer layer, float2 size, float time, float curvature): map to centred uv in −1…1, barrel-distort with uv × (1 + curvature × dot(uv, uv)), return black outside 0…1; sample red at +0.8 pt and blue at −0.8 pt for fringing; multiply by scanlines 0.8 + 0.2 sin(y × π × 0.66), a rolling band 1 + 0.08 × smoothstep(0.92, 1, sin(uv.y × 3 − time × 1.5)), a vignette smoothstep(1.25, 0.4, length(centred)) and a flicker 0.97 + 0.03 sin(time × 60). With Reduce Motion on, pause the timeline at time 0.

## Heat Haze

The view shimmers like hot air over a desert road. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionShaders/HeatHaze.swift, Sources/MotionShaders/Shaders/HeatHaze.metal.

```swift
import MotionShaders

Image("desert-road")
    .heatHaze()
```

How it works: Create a SwiftUI .heatHaze(strength:) view modifier (iOS 17+). Inside TimelineView(.animation), apply .visualEffect { $0.distortionEffect(ShaderLibrary.motionHeatHaze(.float2(proxy.size), .float(time), .float(strength)), maxSampleOffset: CGSize(width: strength, height: strength)) } with strength 6 pt. The Metal [[stitchable]] distortion shader (float2 position, float2 size, float time, float strength) uses smooth value noise: rise = y × 0.05 + time × 2, n = noise(x × 0.04, rise) − 0.5, m = noise(x × 0.09 + 10, rise × 1.7) − 0.5, weight = 0.35 + 0.65 × y / height (stronger at the bottom), and returns position + ((n + 0.5m) × strength × weight, n × strength × 0.3 × weight). With Reduce Motion on, use strength 0.

## Noise Dissolve

The view burns away in organic blotches with a glowing edge. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionShaders/NoiseDissolve.swift, Sources/MotionShaders/Shaders/NoiseDissolve.metal.

```swift
import MotionShaders

Card()
    .noiseDissolve(isDeleting ? 1 : 0)
    .animation(.easeIn(duration: 1), value: isDeleting)

if !isDeleted {
    NoteCard().transition(.noiseDissolve)
}
```

How it works: Create a SwiftUI .noiseDissolve(_ progress:scale:edge:) view modifier (iOS 17+) as an Animatable ViewModifier over progress, applying .colorEffect(ShaderLibrary.motionDissolve(.float(progress), .float(scale), .color(edge)), isEnabled: progress > 0) with scale 18 pt and an orange edge, plus a NoiseDissolveTransition (.noiseDissolve) that uses progress 1 when not identity. The Metal [[stitchable]] colour shader (float2 position, half4 color, float progress, float scale, half4 edge): n = 0.7 × noise(position / scale) + 0.3 × noise(position / (0.35 × scale)) using smooth value noise; threshold = progress × 1.1 − 0.05; return transparent where n < threshold, and mix towards edge × alpha by 1 − smoothstep(threshold, threshold + 0.06, n) so a thin band glows just before it burns. With Reduce Motion on, the transition fades instead.

## Disintegrate

The view crumbles into grains of sand that blow away on the wind. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionShaders/Disintegrate.swift, Sources/MotionShaders/Shaders/Disintegrate.metal.

```swift
import MotionShaders

Avatar()
    .disintegrate(isGone ? 1 : 0)
    .animation(.easeIn(duration: 1.6), value: isGone)

if !isDeleted {
    MessageRow().transition(.disintegrate)
}
```

How it works: Create a SwiftUI .disintegrate(_ progress:wind:grain:) view modifier and matching Transition (iOS 17+) using a Metal [[stitchable]] layer shader with (position, layer, float2 size, float progress, float grain, float2 wind). Split the view into grain-sized cells (2 pt) with two hashes n, n2 per cell. along = dot(position / size, normalize(wind)) × 0.5 + 0.5; delay = (1 − along) × 0.55 + 0.3n; local = clamp((1.4 × progress − delay) / 0.5, 0, 1). If local is 0, return the layer unchanged; if n2 < 1.15 × local, return clear (the grain is gone); otherwise sample the layer at position − (wind × local² + (sin 40n, cos 31n) × local × 6 × grain) and multiply by 1 − local. Apply it through .visualEffect so the shader gets the size, with maxSampleOffset |wind| + 6 × grain, in an Animatable modifier on progress. The transition maps identity to 0 and removal/insertion to 1 (default wind (140, −60)); with Reduce Motion on it fades instead.

## Genie

The view pinches and pours into a point below it, like minimising a window. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionShaders/Genie.swift, Sources/MotionShaders/Shaders/Genie.metal.

```swift
import MotionShaders

Panel()
    .genie(isMinimised ? 1 : 0, toward: 0.8)
    .animation(.easeInOut(duration: 0.7), value: isMinimised)
```

How it works: Create a SwiftUI .genie(_ progress:toward:) view modifier and matching Transition (iOS 17+) using a Metal [[stitchable]] distortion shader (position, float2 size, float progress, float target) that returns where to sample. pinch = clamp(2p, 0, 1), slide = clamp(2p − 1, 0, 1). Return an off-view point below the bottom edge (that part has gone into the target, and maxSampleOffset widens the drawn area). y = position.y − slide × height (return an off-view point if y < 0). bend = smoothstep(0, 1, clamp(y / height + slide, 0, 1)) and squeeze = pinch × bend; the row's edges move from 0 and width towards target × width ∓ 3 pt by squeeze. Return off-view for x outside them, else x = (position.x − left) / (right − left) × width. So the bottom first pinches towards the target in an S-curve, then the whole shape slides down into it. Apply through .visualEffect for the size, maxSampleOffset = size, in an Animatable modifier on progress. The transition defaults to the middle of the bottom edge; with Reduce Motion on it fades instead.

## Glass Lens

A round glass lens magnifies what's under it, bending light at its rim. Trigger: Drag / Hover. Requires iOS 17+. Files: Sources/MotionShaders/GlassLens.swift, Sources/MotionShaders/Shaders/GlassLens.metal.

```swift
import MotionShaders

ArticleView()
    .glassLensOnDrag(radius: 60)
```

How it works: Create SwiftUI .glassLens(at:radius:magnification:) and .glassLensOnDrag() view modifiers (iOS 17+) using a Metal [[stitchable]] layer shader (position, layer, float2 centre, float radius, float magnification). u = distance from centre / radius. Outside (u ≥ 1), darken the layer by up to 22 % in a soft ring that fades out by u = 1.12. Inside, sample at centre + offset × scale with scale = mix(1 / magnification, 1, u³), so the middle is magnified (1.8×) and the rim isn't; sample red at scale + 0.035u⁴ and blue at scale − 0.035u⁴ for colour fringing. Brighten towards white by a rim term smoothstep(0.86, 1, u) × 0.35 plus a specular spot centred at (−0.38, −0.42) × radius that fades over 0.32 × radius. maxSampleOffset = radius. The drag version follows a DragGesture(minimumDistance: 0) and the hover location, starting in the middle.

## Swirl

The view twists around a point like water going down a drain. Trigger: Drag / Value change. Requires iOS 17+. Files: Sources/MotionShaders/Swirl.swift, Sources/MotionShaders/Shaders/Swirl.metal.

```swift
import MotionShaders

Image("galaxy")
    .swirlOnDrag()

Logo()
    .swirl(at: centre, strength: isStirred ? 4 : 0)
    .animation(.spring(duration: 1), value: isStirred)
```

How it works: Create SwiftUI .swirl(at:radius:strength:) and .swirlOnDrag(radius:strength:) view modifiers (iOS 17+) using a Metal [[stitchable]] distortion shader (position, float2 centre, float radius, float strength): within radius (110 pt), rotate the offset from the centre by strength × t² where t = 1 − distance / radius, so it twists most at the centre and not at all at the edge; outside, return the position unchanged. Animate strength in an Animatable modifier, maxSampleOffset = radius. The drag version moves the centre to the finger and sets strength to 4 × min(1, 0.35 + travel / 160) with an interactive spring, then springs back to 0 with .spring(duration: 0.8, bounce: 0.45) on release. With Reduce Motion on, the drag doesn't twist.

## Kaleidoscope

One wedge of the view mirrored round the centre, turning into new patterns. Trigger: Loop / Value change. Requires iOS 17+. Files: Sources/MotionShaders/Kaleidoscope.swift, Sources/MotionShaders/Shaders/Kaleidoscope.metal.

```swift
import MotionShaders

Image("flowers")
    .kaleidoscope(segments: 8)
    .clipShape(Circle())
```

How it works: Create a SwiftUI .kaleidoscope(segments:rotation:spins:) view modifier (iOS 17+) using a Metal [[stitchable]] layer shader (position, layer, float2 size, float segments, float rotation). Around the centre, take the polar angle modulo the wedge 2π / segments and mirror the second half of each wedge (a > wedge / 2 → wedge − a), add rotation, and sample at centre + r' × (cos a, sin a), where r' folds the radius back into the view (reach − |r mod 2 reach − reach|, reach = half the shorter side) so the corners aren't empty. Pass the size through .visualEffect with maxSampleOffset = size, in an Animatable modifier on rotation. When spins is on, add time × 0.25 rad from TimelineView(.animation) so the pattern keeps blooming. With Reduce Motion on, don't spin.

## Halftone

The view is printed in round dots, bigger where it's darker, like newsprint. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionShaders/Halftone.swift, Sources/MotionShaders/Shaders/Halftone.metal.

```swift
import MotionShaders

Image("portrait")
    .halftone(dotSize: isPrinted ? 8 : 1)
    .animation(.easeInOut, value: isPrinted)
```

How it works: Create a SwiftUI .halftone(dotSize:angle:paper:) view modifier (iOS 17+) using a Metal [[stitchable]] layer shader (position, layer, float dotSize, float angle, half4 paper). Rotate the position into a grid at angle (45°), find the centre of its dotSize cell (8 pt), rotate that back and sample the layer there for the dot's colour. Un-premultiply, take luminance L, coverage = (1 − 0.85L) × alpha, dot radius = √coverage × 0.72 × dotSize, and draw the dot with a 0.8 pt smoothstep edge over the paper colour, keeping the alpha of the layer at the pixel so transparent areas stay transparent. Animate dotSize in an Animatable modifier and disable the effect below 1.5 pt, so animating from 1 brings the dots in. maxSampleOffset = dotSize.

## Dither

Chunky pixels in a few flat colours with a Bayer cross-hatch, like a retro handheld. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionShaders/Dither.swift, Sources/MotionShaders/Shaders/Dither.metal.

```swift
import MotionShaders

GameScene()
    .dither(pixelSize: 3)                             // four greens
Avatar()
    .dither(pixelSize: 2, palette: DitherPalette.mono) // 1-bit
```

How it works: Create a SwiftUI .dither(pixelSize:palette:) view modifier (iOS 17+) using a Metal [[stitchable]] layer shader (position, layer, float pixelSize, device const half4 *palette, int count). Sample the layer at the centre of the position's pixelSize block (3 pt), un-premultiply, take luminance, and add a 4 × 4 Bayer threshold ((bayer[i] + 0.5) / 16 − 0.5) / (levels − 1) indexed by the block coordinates mod 4. Round to the nearest of the palette's colours (darkest first) and return it premultiplied by the sample's alpha. Pass the palette with .colorArray. Ship palettes: four greens like an early handheld (0.06, 0.22, 0.06) … (0.61, 0.74, 0.06), mono black/white, and sepia. Animate pixelSize in an Animatable modifier; maxSampleOffset = pixelSize.

## Thermal Vision

Brightness turns into heat colours, from cold indigo to white hot. Trigger: Value change. Requires iOS 17+. Files: Sources/MotionShaders/Thermal.swift, Sources/MotionShaders/Shaders/Thermal.metal.

```swift
import MotionShaders

CameraFeed()
    .thermal(isScanning ? 1 : 0)
    .animation(.easeInOut(duration: 0.6), value: isScanning)
```

How it works: Create a SwiftUI .thermal(_ intensity:) view modifier (iOS 17+) using a Metal [[stitchable]] colour shader (position, half4 colour, float intensity). Un-premultiply, take luminance as heat, and map it through seven evenly spaced stops: (0, 0, 0.05), (0.2, 0.05, 0.45), (0.65, 0.05, 0.6), (0.95, 0.15, 0.2), (1, 0.5, 0), (1, 0.9, 0.2), (1, 1, 1), interpolating linearly. Mix the original colour with the heat colour by intensity and premultiply again. Animate intensity in an Animatable modifier and disable the effect at 0, so the view can switch into heat vision.

## Flag Wave

The view ripples like a flag on a pole, its folds catching the light. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionShaders/FlagWave.swift, Sources/MotionShaders/Shaders/FlagWave.metal.

```swift
import MotionShaders

Image("banner")
    .flagWave(amplitude: 10)
```

How it works: Create a SwiftUI .flagWave(amplitude:wavelength:speed:) view modifier (iOS 17+) using a Metal [[stitchable]] layer shader (position, layer, float2 size, float time, float amplitude, float wavelength). reach = x / width (0 at the pole on the leading edge, 1 at the free end); phase = x / wavelength × 2π − 4 × time; wave = sin(phase) + 0.35 sin(2.3 phase + 1.1). Sample at (x + 0.25 × amplitude × reach × cos(phase), y − amplitude × reach × wave) and multiply the colour by 1 + 0.18 × reach × (cos(phase) + 0.8 cos(2.3 phase + 1.1)) so slopes catch light and shade, clamped to alpha. Drive time from TimelineView(.animation), pad the view vertically by 1.4 × amplitude (and take it back with negative padding) so the ripples have room, and apply through .visualEffect for the size. With Reduce Motion on, leave the view still.

## Voronoi Cells

Slowly drifting cells like stained glass, with soft seams between them. Trigger: Loop. Requires iOS 17+. Files: Sources/MotionShaders/Voronoi.swift, Sources/MotionShaders/Shaders/Voronoi.metal.

```swift
import MotionShaders

VoronoiCells(colors: [.indigo, .purple, .pink, .orange, .teal])
    .ignoresSafeArea()
```

How it works: Create a SwiftUI VoronoiCells(colors:cellSize:speed:) view (iOS 17+): a Rectangle with a Metal [[stitchable]] colour shader (position, colour, float time, float scale, device const half4 *palette, int count) driven by TimelineView(.animation). Work in cells of scale (60 pt); for the 3 × 3 neighbouring cells, the seed is cell + 0.5 + 0.4 × sin(time + 2π × hash2(cell)), so seeds drift. Track the nearest and second-nearest distances; colour the pixel with palette[hash(nearest cell) × count], darkened by smoothstep(0, 0.08, second − nearest) for soft seams and by 1 − 0.35 × nearest for a gentle glow at each seed. Pass the colours with .colorArray. With Reduce Motion on, pause the timeline. Hide it from accessibility.
