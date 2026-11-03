---
name: swiftui-motion
description: "Adds polished SwiftUI animations from SwiftUI Motion Library: animated text, button micro-interactions, card transitions, loaders, confetti, animated backgrounds, particles and 3D effects. Use when building or improving SwiftUI UI that needs animation, transitions, loading or success states, celebratory feedback, or a moving background."
---

# SwiftUI Motion Library

73 ready-made SwiftUI motion effects as one-line views and modifiers, with no dependencies. Source: https://github.com/BigTsung/SwiftUI-Motion-Library

## Install

```swift
// Package.swift
.package(url: "https://github.com/BigTsung/SwiftUI-Motion-Library", branch: "main")
// target dependencies
.product(name: "MotionLibrary", package: "SwiftUI-Motion-Library")
```

Then `import MotionLibrary`. Requires iOS 17, macOS 14 or visionOS 1; effects marked iOS 18+ are `@available(iOS 18, macOS 15, visionOS 2, *)`.

## How to use

1. Pick the effect from the table that matches what the UI needs. Prefer the library API over hand-writing the animation.
2. Add the package if the project doesn't have it yet, and `import MotionLibrary`.
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

### Number

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Rolling Number | `RollingNumber(value:)` | Value change | Digits roll like an odometer when the value changes. |

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
