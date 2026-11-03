---
name: swiftui-motion
description: "Adds polished SwiftUI animations from SwiftUI Motion Library: animated text, button micro-interactions, card transitions, loaders, confetti, animated backgrounds, particles and 3D effects. Use when building or improving SwiftUI UI that needs animation, transitions, loading or success states, celebratory feedback, or a moving background."
---

# SwiftUI Motion Library

33 ready-made SwiftUI motion effects as one-line views and modifiers, with no dependencies. Source: https://github.com/BigTsung/SwiftUI-Motion-Library

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

### Shape

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Pulse Rings | `PulseRings()` | Loop | Concentric rings expand and fade continuously, like a radar or live dot. |
| Like Burst | `.burst(trigger:)` | Tap / Value change | Particles fly outward from the centre when a value changes. |
| Checkmark Draw | `AnimatedCheckmark(isChecked:)` | Value change | A success mark draws itself: circle stroke, fill, then a popping check. |
| Confetti | `.confetti(trigger:)` | Tap / Value change | Confetti bursts out of the view, tumbles under gravity and fades. |
| Loaders | `MotionLoader(.spinner)` | Loop | Five looping activity indicators: spinner, dots, bars, orbit and pulse. |
| Morphing Blob | `MorphingBlob()` | Loop | An organic, lava-lamp blob whose outline never stops changing. |

### Background

| Effect | API | Trigger | Use it for |
|---|---|---|---|
| Aurora | `AuroraBackground()` | Loop | Soft, blurred colour blobs drift slowly behind your content. |

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
