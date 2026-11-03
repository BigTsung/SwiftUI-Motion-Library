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
   - **Reduce Motion:** if it loops or moves a lot, read `@Environment(\.accessibilityReduceMotion)` and pause, fade or drop the movement instead.
   - Effects that need a newer OS are marked `@available(iOS 18, macOS 15, visionOS 2, *)`; the package itself stays on iOS 17.
   - A `#Preview` at the bottom of the file (it must be the last declaration: the build scripts strip it).
   - No third-party dependencies. Pure SwiftUI, plus Metal for the Shader component (see below).
2. **Demo view:** add a small `struct <Name>Demo: View` to `Sources/MotionGallery/Catalog/Demos.swift`. It must look good both in a ~160×140 grid cell and in the large detail preview.
3. **Catalog entry:** append a `MotionEffect(...)` to the matching section in `Sources/MotionGallery/Catalog/MotionCatalog.swift`:
   - `id`: kebab-case, unique, never changed once released.
   - `triggers`: every `MotionTrigger` that applies.
   - `requirement`: `.ios18` if the effect needs iOS 18; omit it otherwise.
   - `api`: the public API in one line, e.g. `".shimmer()"` or `"PulseRings()"`. It appears in the README, llms.txt, the Skill and the MCP server.
   - `usage`: a copy-paste snippet, written as a raw string `#""" … """#`.
   - `prompt`: an AI prompt (see below), also a raw string.
4. **Check it compiles:** `Scripts/check-build.sh` builds both targets with just the Command Line Tools (no Xcode needed).
5. **README preview:** if the demo needs taps, presses or drags, add a case for its `id` to `recording(for:)` in `Scripts/ReadmeGIFs/main.swift` (or drive it from a small scene in code; synthetic clicks are unreliable on `onTapGesture`). Then run `Scripts/record-readme-gifs.sh <id>` (macOS + ffmpeg) to create `Docs/gifs/<id>.gif`. It renders off-screen, so it won't get in your way.
6. **Generated docs:** run `Scripts/generate-docs.sh`. It rewrites the README grids (English and Traditional Chinese), `llms.txt`, `llms-full.txt`, `Docs/motion-catalog.json`, the Agent Skill and the Cursor rule from the catalog. Never edit those by hand; CI runs `Scripts/generate-docs.sh --check`.

## Shader effects (Metal)

Shader effects live in the separate `MotionShaders` target so `MotionLibrary` builds without the Metal Toolchain.

- Swift API in `Sources/MotionShaders/<Name>.swift`, the `[[stitchable]]` function in `Sources/MotionShaders/Shaders/<Name>.metal` (one file per effect; copy small helpers like noise instead of sharing them, so each pair can be copied into an app on its own).
- Call shaders through `motionShaders` (`ShaderLibrary.bundle(.module)`). Animatable parameters go in an `Animatable` `ViewModifier`; time-driven ones in a `TimelineView`.
- Catalog entry: `component: .shader`, `sourceFile: "MotionShaders/<Name>.swift"`. The generated docs append the `.metal` file to the source.
- Building needs Xcode with the Metal Toolchain (Xcode 26+: **Settings → Components**). The scripts pick Xcode automatically when it's installed.

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
