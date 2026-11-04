---
name: swiftui-motion
description: "Adds polished SwiftUI animations from SwiftUI Motion Library: animated text, button micro-interactions, card transitions, loaders, confetti, animated backgrounds, particles and 3D effects. Use when building or improving SwiftUI UI that needs animation, transitions, loading or success states, celebratory feedback, or a moving background."
---

# SwiftUI Motion Library

145 ready-made SwiftUI motion effects as one-line views and modifiers, with no dependencies. Source: https://github.com/BigTsung/SwiftUI-Motion-Library

## Install

```swift
// Package.swift
.package(url: "https://github.com/BigTsung/SwiftUI-Motion-Library", from: "0.6.0")
// target dependencies
.product(name: "MotionLibrary", package: "SwiftUI-Motion-Library")
```

Then `import MotionLibrary`. Requires iOS 17, macOS 14 or visionOS 1; effects marked iOS 18+ are `@available(iOS 18, macOS 15, visionOS 2, *)`.

In an Xcode app project, add the package with **File → Add Package Dependencies…** rather than editing `project.pbxproj` by hand. To use one effect without the package, copy its source file plus any files listed under "Files" for it (shared helpers such as `Support/Haptics.swift`); every effect compiles from just those files.

## How to use

1. Pick the effect from the table that matches what the UI needs. Prefer the library API over hand-writing the animation.
2. Add the package if the project doesn't have it yet (in an Xcode app project, ask the user to use **File → Add Package Dependencies…** instead of editing `project.pbxproj`), and `import MotionLibrary`. If the user wants no dependency, copy the effect's files instead: its own source plus the helpers listed for it in `Docs/motion-catalog.json` (`files`) or llms-full.txt ("Files").
3. Copy the usage for that effect from `references/effects.md` (or https://raw.githubusercontent.com/BigTsung/SwiftUI-Motion-Library/main/llms-full.txt) and adapt colours, sizes and timing through the parameters.
4. Effects marked iOS 18+ need `if #available(iOS 18, macOS 15, visionOS 2, *)` when the app targets an older OS.
5. Effects with large or looping motion already honour Reduce Motion (they pause, fade or drop the movement), so don't wrap them in your own check.
6. If no effect fits, adapt the closest one: its "How it works" note describes the technique.

## Effects

### Text

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Typewriter | `TypewriterText("…")` | Appear / Value change | Characters appear one by one with a blinking cursor. |
| Scramble / Decode | `ScrambleText("…")` | Appear / Value change | Random glyphs resolve into the real text from left to right. |
| Shimmer | `.shimmer()` | Loop | A band of light sweeps across text or skeleton placeholders. |
| Gradient Sweep | `.gradientSweep()` | Loop | A multi-colour gradient flows through the letters forever. |
| Blur-in Words | `BlurInText("…")` | Appear / Value change | Words come into focus one after another: fade, rise and un-blur. |
| Marquee | `MarqueeText("…")` | Loop | Text too long for its line scrolls sideways forever, with faded edges. |
| Wave Text (iOS 18+) | `WaveText("…")` | Loop | Letters bob in a travelling wave, drawn with a TextRenderer. |
| Count Up | `CountUpText(value: …)` | Appear / Value change | A number counts up from zero, and from old to new value on change. |
| Split Text (iOS 18+) | `SplitText("…")` | Appear / Value change | Letters rise into place one after another with a small overshoot. |
| Rotating Text | `RotatingText([…])` | Loop | Words take turns: the current one slides up and out as the next rises in. |
| Glitch | `.glitch()` | Loop | Every few seconds the view tears: an RGB split, sliced rows and jitter. |
| Circular Text | `CircularText("…")` | Loop | Text wrapped around a circle that slowly turns, like a rotating badge. |
| Focus Text | `FocusText("…")` | Loop | Focus hops from word to word: sharp and bracketed, the rest blurred. |
| Highlighter | `.highlighter()` | Appear / Value change | A marker pen swipes across the text, or underlines it, left to right. |
| Morphing Text | `MorphingText([…])` | Loop | Words melt into each other with a gooey, liquid morph. |
| Neon Flicker | `.neon(color:flicker:)` | Loop | A glowing neon tube that stutters on and glitches now and then. |
| Karaoke Text | `KaraokeText(_:progress:)` | Value change / Scroll | A line fills with colour left to right as progress goes from 0 to 1. |
| Weight Wave | `WeightWaveText(_:)` | Loop | Letters swell from thin to black and back in a travelling wave. |
| Exploding Text (iOS 18+) | `ExplodingText(_:isExploded:)` | Value change / Tap | Letters blast apart spinning and spring back into place. |
| Liquid Fill Text | `LiquidFillText(_:progress:)` | Value change / Loop | A wavy water line rises inside the letters as progress grows. |

### Button

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Pressable | `.buttonStyle(.pressable)` | Press | Button squashes and darkens on press, then springs back with a light haptic. |
| Tap Ripple | `.ripple()` | Tap | A circular ripple expands from the exact tap location. |
| Error Shake | `.shake(trigger:)` | Value change | Horizontal "no" shake for wrong input, triggered by a value change. |
| Magnetic Button | `.magnetic()` | Hover / Drag | The button drifts toward a nearby pointer or dragging finger, then springs home. |
| Hold to Confirm | `HoldToConfirmButton("…") { }` | Press | Liquid fills the button while you hold; the action runs only when it's full. |
| Loading → Success | `StatusButton("…", status:) { }` | Tap / Value change | The button morphs into a spinner, then a green checkmark or a red shake. |
| Glow Border | `.glowBorder()` | Loop | A rainbow border runs around the view with a soft glow behind it. |
| Shine | `.shine(every:) / .shine(trigger:)` | Value change / Loop | A slanted glint of light sweeps across the button, on cue or on a beat. |
| Jelly | `.jelly(trigger:)` | Tap / Value change | A rubbery squash-and-stretch wobble on every tap. |
| Click Spark | `.clickSpark()` | Tap | Short spark lines shoot out from the exact point you tapped. |
| Like Button | `LikeButton(isLiked:)` | Tap | The heart pops in as a ring bursts open and coloured dots fly out. |
| Animated Symbol | `AnimatedSymbol("…", style:)` | Loop | SF Symbols that keep moving: bounce on a beat, pulse, variable colour. |
| Liquid Toggle | `.toggleStyle(.liquid)` | Tap | A switch whose knob stretches like a drop of liquid as it slides. |
| Gooey Menu | `GooeyMenu(symbols:action:)` | Tap | A round button splits into a fan of buttons like a drop of liquid. |
| Slide to Confirm | `SlideToConfirm(_:action:)` | Drag | Drag the knob all the way across to run the action; let go early and it springs back. |
| Download Button | `DownloadButton(progress:) { }` | Tap / Value change | A capsule shrinks into a progress ring, then pops into a checkmark. |
| Star Rating | `StarRating(rating:)` | Tap / Value change | Stars fill one after another with a springy pop and a burst of sparks. |
| Bouncy Tab Bar | `BouncyTabBar(selection:items:)` | Tap / Value change | A pill glides to the selected tab and its icon squashes and hops. |
| Pull Cord | `PullCord(isOn:)` | Drag / Tap | A lamp cord toggle: pull the knob down, it clicks and springs back swinging. |

### Card & Group

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Staggered Entrance | `.staggeredAppear(index:)` | Appear | List items fade and rise into place one after another. |
| 3D Tilt | `.tiltOnDrag()` | Drag | Card tilts in 3D toward the finger with a moving glare, then springs flat. |
| Scroll Reveal | `.scrollReveal()` | Scroll | Rows scale up and come into focus as they enter the visible area. |
| Flip Card | `FlipCard(isFlipped:) { } back: { }` | Tap / Value change | A two-sided card turns over in 3D with a spring. |
| Swipe Card Stack | `SwipeCardStack(items) { item in }` | Drag | Tinder-style deck: drag the top card away and the pile moves up. |
| Parallax Carousel | `ParallaxCarousel(items) { item in }` | Scroll | Paging cards whose images slide slower than the cards, for depth. |
| Expandable Card | `ExpandableCard(isExpanded:) { } detail: { }` | Tap | Tap the header and the card springs open, un-blurring its detail. |
| Hero Expand | `HeroGrid(items) { thumbnail } detail: { }` | Tap | A thumbnail grows into a full detail card, morphing with matchedGeometryEffect. |
| Spotlight Card | `.spotlight()` | Hover / Drag | A soft glow follows the pointer across the card, like a torch. |
| Magnifying Dock | `MagnifyingDock(items) { item in }` | Hover / Drag | Icons swell as the pointer passes over them, like the macOS Dock. |
| Jiggle | `.jiggle(isActive:)` | Loop / Value change | The home-screen edit-mode wiggle, each item slightly out of step. |
| Fan Stack | `FanStack(items, isSpread:) { item in }` | Tap / Value change | A pile of cards fans out like a hand of playing cards, and gathers back. |
| Scratch Card | `.scratchToReveal(_:onReveal:)` | Drag | Rub away a scratch-off cover to reveal what's underneath. |
| Stacking Cards | `.stackingCard()` | Scroll | Cards stick at the top while scrolling and shrink as the next one covers them. |
| Deck Shuffle | `DeckShuffle(items, trigger:) { item in }` | Value change / Tap | A deck splits in two, mixes, and springs back into a messy stack. |
| Looping Carousel | `LoopingCarousel(items) { item in }` | Drag / Loop | A paging carousel that wraps around forever, with peeking neighbours. |
| Drag to Dismiss | `.dragToDismiss(isPresented:)` | Drag | Fling a card away; it flies off with your throw or springs back. |
| Shrinking Header | `.shrinkingHeader()` | Scroll | The header sticks to the top and shrinks as content scrolls under it. |
| Stretchy Header | `.stretchyHeader()` | Scroll | A header image stretches when pulled down and drifts with parallax when scrolled. |
| Island Pill | `IslandPill(isExpanded:) { } expanded: { }` | Tap / Value change | A black pill springs open into a card and back, its contents blurring across. |
| Hover Lift | `.hoverLift(isActive:)` | Hover | Cards rise, grow and lean towards the pointer on iPad and Mac. |
| Marquee Wall | `MarqueeWall(count:) { index in }` | Loop | A tilted wall of cards, columns scrolling endlessly up and down. |
| Photo Develop | `.photoDevelop()` | Appear / Value change | The view develops like an instant photo, from murky dark to full colour. |

### Shape

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Pulse Rings | `PulseRings()` | Loop | Concentric rings expand and fade continuously, like a radar or live dot. |
| Like Burst | `.burst(trigger:)` | Tap / Value change | Particles fly outward from the centre when a value changes. |
| Checkmark Draw | `AnimatedCheckmark(isChecked:)` | Value change | A success mark draws itself: circle stroke, fill, then a popping check. |
| Confetti | `.confetti(trigger:)` | Tap / Value change | Confetti bursts out of the view, tumbles under gravity and fades. |
| Loaders | `MotionLoader(.spinner)` | Loop | Five looping activity indicators: spinner, dots, bars, orbit and pulse. |
| Morphing Blob | `MorphingBlob()` | Loop | An organic, lava-lamp blob whose outline never stops changing. |
| Draw On | `Shape.drawOn()` | Appear / Value change | Any Shape strokes itself on like a pen, and erases back. |
| Progress Ring | `ProgressRing(progress:)` | Value change | A gradient ring springs to each value as the percentage rolls. |
| Skeleton | `.skeleton(isLoading:)` | Loop / Value change | A shimmering placeholder of the view's own layout while it loads. |
| Sliding Tabs | `SlidingTabs([…], selection:)` | Tap | A segmented control whose pill or underline glides to the selection. |
| Reading Progress | `ReadingProgressScrollView { … }` | Scroll | A bar along the top fills as you scroll through the content. |

### Background

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Aurora | `AuroraBackground()` | Loop | Soft, blurred colour blobs drift slowly behind your content. |
| Mesh Gradient (iOS 18+) | `AnimatedMeshGradient()` | Loop | A 3×3 MeshGradient whose points drift so the colours flow like liquid. |
| Retro Grid | `RetroGrid()` | Loop | A synthwave floor: a perspective grid scrolling toward you. |
| Border Beam | `.borderBeam()` | Loop | A short comet of light runs around the card's border forever. |
| Waves | `WaveBackground()` | Loop | Layered sine waves roll across the bottom, back layers slower and paler. |
| Film Grain | `.grain()` | Loop | Flickering film grain over any view, from a tiled noise texture. |
| Flashlight | `.flashlight()` | Hover / Drag | The view goes dark except a soft circle of light around the pointer. |
| Lava Lamp | `LavaLamp()` | Loop | Soft blobs drift up and down, stretching and merging like hot wax. |
| Matrix Rain | `MatrixRain()` | Loop | Columns of glyphs rain down with bright heads and fading trails. |
| Interactive Dot Grid | `InteractiveDotGrid()` | Drag / Hover / Loop | A grid of dots scatters away from your finger and eases back. |
| Meteors | `Meteors()` | Loop | Meteors streak across a starry sky with glowing heads and fading tails. |
| Flow Field | `FlowField()` | Loop | Generative curves follow a shifting vector field with dashes flowing along them. |
| Network | `NetworkBackground()` | Loop / Hover / Drag | Drifting points link up with lines when close, and gather at your finger. |
| Topographic Lines | `TopographicLines()` | Loop | Contour lines of a shifting landscape flow like a living map. |
| Day & Night Sky | `DayNightSky(time:)` | Loop / Value change | A sky runs from starry night through dawn, noon and sunset, sun and moon arcing over. |

### Number

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Rolling Number | `RollingNumber(value:)` | Value change | Digits roll like an odometer when the value changes. |
| Split-Flap Display | `SplitFlapText(_:)` | Value change | Characters flip through the alphabet like an airport departures board. |
| Slot Machine | `SlotMachineNumber(value:)` | Value change | Number reels spin with motion blur and land one after another. |
| Price Ticker | `PriceTicker(value:)` | Value change | Digits roll to the new price as the background flashes green or red. |
| Animated Chart | `GrowingBarChart(values:) / DrawingLineChart(values:)` | Appear / Value change | Bars grow up one after another; a line draws itself left to right. |
| Needle Gauge | `NeedleGauge(value:)` | Value change | A speedometer needle swings to the value, overshoots and settles. |
| Contribution Grid | `ContributionGrid(values:)` | Appear / Value change | Activity squares pop in column by column, shaded by how busy each day was. |
| Analog Clock | `AnalogClock(date:)` | Loop / Value change | A clock with a sweeping second hand; set a time and the hands spring to it. |

### Particle & 3D

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Particle Field | `ParticleField()` | Loop | Drifting particles linked by faint lines, like a living constellation. |
| Starfield | `Starfield()` | Loop | Stars stream out of the centre and stretch into streaks: warp speed. |
| Cover Flow | `CoverFlow(items) { item in }` | Scroll | Side items turn away in 3D, shrink and dim; the centre faces you. |
| Float 3D | `.float3D()` | Loop | The view hovers: a gentle bob, a slow 3D sway and a breathing shadow. |
| Fireworks | `Fireworks()` | Loop | Rockets climb and burst into rings of falling, fading sparks. |
| Snowfall & Rain | `Snowfall(.snow / .rain)` | Loop | Drifting, swaying snowflakes or fast slanted rain, with depth. |
| Floating Reactions | `.floatingReactions(trigger:)` | Tap / Value change | Live-stream style emoji float up, swaying, every time you react. |
| Warp Tunnel | `WarpTunnel()` | Loop | Rings rush out of the vanishing point toward you: flying down a tunnel. |
| Holographic Card | `.holographic()` | Hover / Drag | A trading card that tilts toward you with a rainbow foil and moving glare. |
| Physics Emoji | `PhysicsEmoji(trigger:)` | Value change / Tap | Emoji tumble in with gravity, bounce off each other and pile up. |
| Shatter | `.transition(.shatter)` | Value change | The view breaks into triangular shards that fly, spin and fall away. |
| 3D Cube | `.transition(.cube)` | Value change | Views swap by turning a cube: one face folds away as the next rotates in. |
| Dot Globe | `DotGlobe()` | Loop | A globe of evenly spread dots spins on a tilted axis, with pulsing cities. |
| Bubbles | `Bubbles()` | Loop | Soap bubbles rise and wobble with rainbow rims and glossy highlights. |
| Fireflies | `Fireflies()` | Loop | Glowing fireflies drift lazily and blink on their own rhythms. |
| Flock | `Flock()` | Loop / Drag / Hover | Little arrows swim together like birds or fish, and chase your finger. |
| Ink Trail | `.inkTrail(color:)` | Drag / Hover | The pointer or finger leaves puffs of ink that swell, drift up and fade. |
| Rain on Glass | `RainOnGlass()` | Loop | Raindrops cling to a window while bigger drops slide down in fits and starts. |
| Orbits | `Orbits(colors:)` | Loop | Planets circle a glowing star on tilted orbits, passing behind it and in front. |

### Transition

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Iris | `.transition(.iris)` | Appear | A circle opens from a point to reveal the view, like a camera iris. |
| Blinds | `.transition(.blinds)` | Appear | Horizontal slats open together to reveal the view, like Venetian blinds. |
| Clock Wipe | `.transition(.clockWipe)` | Appear | A wedge sweeps clockwise from twelve o'clock, like a clock hand. |
| Pixel Dissolve | `.transition(.dissolve)` | Appear | The view appears and vanishes in square pixels, in random order. |
| Poof | `.transition(.poof)` | Appear | The view puffs away like smoke: it swells and blurs out. |
| Swoosh | `.transition(.swoosh)` | Appear | The view whooshes in leaning forward, with a motion blur. |
| Film Exposure | `.transition(.filmExposure)` | Appear | The view develops like a photo, from over-exposed white to full colour. |
| Circular Reveal | `CircularReveal(value:) { value in }` | Tap / Value change | New content spreads out in a circle from where you tapped. |
| Liquid Swipe | `.transition(.liquidSwipe)` | Value change | The next page pours in from the edge behind a bulging liquid wave. |
| Page Turn | `.transition(.pageTurn)` | Value change | The old page swings away like a book page, revealing the next one. |
| Glitch Transition | `.transition(.glitch)` | Value change | The view breaks up like a bad signal on its way in or out. |
| Origami Fold | `.transition(.origami)` | Value change | The view folds up into creased panels like a paper map. |
| Ink Bleed | `.transition(.inkBleed)` | Value change | New content spreads in like a blot of ink on wet paper, with a ragged edge. |
| Zoom Blur | `.transition(.zoomBlur)` | Value change | Content rushes in from the camera, blurred and trailed by echoes, then snaps sharp. |

### Shader

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Water Ripple | `.waterRippleOnTap() / .waterRipple(at:trigger:)` | Tap / Value change | A real ripple distorts the view's pixels outward from a tap. |
| Pixellate | `.pixellate(_:)` | Value change | The view melts into a mosaic of square blocks and back. |
| Chromatic Aberration | `.chromaticAberration(_:)` | Value change / Loop | Red and blue split sideways like a cheap lens; animate it on a beat. |
| CRT Screen | `.crtScreen()` | Loop | Curved glass, scanlines, a rolling band and flicker, like an old monitor. |
| Heat Haze | `.heatHaze(strength:)` | Loop | The view shimmers like hot air over a desert road. |
| Noise Dissolve | `.noiseDissolve(_:) / .transition(.noiseDissolve)` | Value change | The view burns away in organic blotches with a glowing edge. |
| Disintegrate | `.disintegrate(_:) / .transition(.disintegrate)` | Value change | The view crumbles into grains of sand that blow away on the wind. |
| Genie | `.genie(_:toward:) / .transition(.genie)` | Value change | The view pinches and pours into a point below it, like minimising a window. |
| Glass Lens | `.glassLensOnDrag() / .glassLens(at:)` | Drag / Hover | A round glass lens magnifies what's under it, bending light at its rim. |
| Swirl | `.swirlOnDrag() / .swirl(at:strength:)` | Drag / Value change | The view twists around a point like water going down a drain. |
| Kaleidoscope | `.kaleidoscope(segments:)` | Loop / Value change | One wedge of the view mirrored round the centre, turning into new patterns. |
| Halftone | `.halftone(dotSize:)` | Value change | The view is printed in round dots, bigger where it's darker, like newsprint. |
| Dither | `.dither(pixelSize:palette:)` | Value change | Chunky pixels in a few flat colours with a Bayer cross-hatch, like a retro handheld. |
| Thermal Vision | `.thermal(_:)` | Value change | Brightness turns into heat colours, from cold indigo to white hot. |
| Flag Wave | `.flagWave()` | Loop | The view ripples like a flag on a pole, its folds catching the light. |
| Voronoi Cells | `VoronoiCells(colors:)` | Loop | Slowly drifting cells like stained glass, with soft seams between them. |
