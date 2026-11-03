# Contributing

Thanks for helping grow the library! Adding an effect takes three files.

## Checklist for a new effect

1. **Effect source:** `Sources/MotionLibrary/<Component>/<EffectName>.swift`
   - Public API is one of:
     - a `View` (`PulseRings`, `TypewriterText`),
     - a `ViewModifier` exposed through a `public extension View` method (`.shimmer()`, `.shake(trigger:)`),
     - a `ButtonStyle` with a static accessor (`.buttonStyle(.pressable)`).
   - Keep the `ViewModifier` type itself `internal`; only the `View` extension is public.
   - Sensible defaults for every parameter, so `.effect()` with no arguments looks good.
   - A `///` doc comment with a short usage example.
   - A `#Preview` at the bottom of the file.
   - No third-party dependencies. Pure SwiftUI (+ Metal shaders later, see below).
2. **Demo view:** add a small `struct <Name>Demo: View` to `Sources/MotionGallery/Catalog/Demos.swift`. It must look good both in a ~160×140 grid cell and in the large detail preview.
3. **Catalog entry:** append a `MotionEffect(...)` to the matching section in `Sources/MotionGallery/Catalog/MotionCatalog.swift`:
   - `id`: kebab-case, unique, never changed once released.
   - `triggers`: every `MotionTrigger` that applies.
   - `usage`: a copy-paste snippet, written as a raw string `#""" … """#`.
   - `prompt`: an AI prompt (see below), also a raw string.
4. **README preview:** if the demo needs taps, presses or drags, add a case for its `id` to `recording(for:)` in `Scripts/ReadmeGIFs/main.swift`. Then run `Scripts/record-readme-gifs.sh <id>` (macOS + ffmpeg) to create `Docs/gifs/<id>.gif`, and add a cell for it to the effects grid in `README.md`.

## Writing the AI prompt

The prompt should let someone recreate the effect **without seeing our code**. Include:

- the platform and minimum OS ("SwiftUI (iOS 17+)"),
- what it looks like: shapes, colors, sizes and distances in points, opacity,
- timing: durations, delays, curve or spring parameters,
- the technique: which SwiftUI APIs to use (`keyframeAnimator`, `TimelineView`, `scrollTransition`, …),
- behaviour details: restarts, cancellation, hit testing, accessibility.

## Code style

- Swift 5.9+, SwiftUI only, iOS 17 / macOS 14 / visionOS 1 minimum.
- Prefer `TimelineView` over `repeatForever` for continuous loops.
- Overlays used for decoration must use `.allowsHitTesting(false)`.
- Purely decorative views use `.accessibilityHidden(true)`. Text effects set the real string as their accessibility label.
- Respect `@Environment(\.accessibilityReduceMotion)` when an effect is large or continuous (planned for all effects, see the roadmap in CLAUDE.md).

## Pull requests

- One effect per PR when possible.
- Include a short GIF or screen recording of the effect.
- Make sure `swift build` and the CI workflow pass.
