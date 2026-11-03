# CLAUDE.md: guide for AI coding agents

This file is read by Claude Code (and mirrored in AGENTS.md for Codex and other agents). It explains how this repo is organised and how to extend it. **Follow CONTRIBUTING.md for every new effect.**

## What this project is

A SwiftUI counterpart to web "motion library" galleries: a collection of reusable motion effects, organised on two axes:

- **Component** (`MotionComponent`): text, button, card, shape, background, number, particle (Particle & 3D), transition
- **Trigger** (`MotionTrigger`): appear, tap, press, drag, hover, scroll, change, loop

Each effect has: a public API in `MotionLibrary`, a demo view, and a catalog entry with usage code + an AI prompt shown in the `MotionGallery` browser UI. The catalog is the source of truth for everything AI-facing (llms.txt, the Agent Skill, the Cursor rule, the MCP server's JSON), which `Scripts/generate-docs.sh` regenerates.

## Architecture

```
Package.swift                         # tools 5.9, iOS 17 / macOS 14 / visionOS 1
Sources/MotionLibrary/<Component>/    # effects, public API, zero dependencies
Sources/MotionShaders/                # optional Metal shader effects; Shaders/<Name>.metal per effect
Sources/MotionGallery/
  Model/MotionEffect.swift            # MotionComponent, MotionTrigger, MotionEffect
  Catalog/MotionCatalog.swift         # static list of every effect (display order)
  Catalog/Demos.swift                 # demo views used by the catalog
  Views/                              # gallery grid, detail view, shared components
Docs/gifs/, Docs/motion-catalog.json  # README previews + generated catalog JSON
llms.txt, llms-full.txt               # generated
skills/swiftui-motion/                # generated Agent Skill
.cursor/rules/swiftui-motion.mdc      # generated Cursor rule
mcp/server.mjs                        # zero-dependency MCP server (reads the JSON)
Examples/MotionLibraryDemo/           # iOS demo app (XcodeGen project.yml + committed .xcodeproj) + scroll UI tests
Scripts/                              # check-build, generate-docs, record-readme-gifs, record-simulator-gifs
```

- `MotionLibrary` must never import `MotionGallery`.
- `MotionEffect.demo` is `@MainActor`. Call it only from view bodies or `@MainActor` helpers.
- Catalog `usage` and `prompt` strings use raw multi-line strings `#""" … """#` so key paths like `\.self` don't break.
- Never hand-edit generated files (README grids between the `effects` markers in README.md and README.zh-TW.md, llms*.txt, Docs/motion-catalog.json, skills/, .cursor/rules/). Change the catalog and run `Scripts/generate-docs.sh`.
- The README is bilingual: `README.md` (English) and `README.zh-TW.md` (Traditional Chinese), each with a language switcher at the top. When you change the prose outside the `effects` markers in one, make the same change in the other. Chinese category and trigger names for the grid live in `ReadmeLanguage` in `Scripts/DocsGenerator/main.swift`.

## Rules

- Pure SwiftUI. No third-party dependencies in either target.
- Don't raise the deployment targets without asking the maintainer.
- The demo app's `.xcodeproj` is generated from `Examples/MotionLibraryDemo/project.yml`: edit the YAML and run `xcodegen generate` in that folder, never the project file. New source files in its folders need a regenerate too.
- Keep public API names short and SwiftUI-like (`.shimmer()`, not `.applyShimmerEffect()`).
- Every effect file ends with a `#Preview`.
- Don't rename existing catalog `id`s or public API (it's a library; breaking changes need a major version).
- Shader effects go in `Sources/MotionShaders/<Name>.swift` + `Shaders/<Name>.metal`, with `sourceFile: "MotionShaders/<Name>.swift"` in the catalog (paths starting with `MotionShaders/` are resolved from `Sources/`). The scripts use Xcode's toolchain when Xcode is installed (it can compile Metal); with only the Command Line Tools the shaders are swapped for a placeholder so the Swift still compiles.
- Keyframes must have a positive duration (a 0 s keyframe crashes), and never feed a raw clock value into `dashPhase` (Core Graphics walks the dash pattern up to it and hangs): wrap it to one dash period.
- Scroll-driven effects: test them with real scrolling on iOS. Add a full-screen example and a UI test to `Examples/MotionLibraryDemo` (its tests drag with a finger and assert on accessibility frames, which follow `visualEffect` transforms), and run them with `xcodebuild test -project Examples/MotionLibraryDemo/MotionLibraryDemo.xcodeproj -scheme MotionLibraryDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO`. In `visualEffect`, apply `scaleEffect` before the pinning `offset`, or the scale shrinks the offset and the view drifts away. Don't rely on a `PreferenceKey` getting out of an iOS `ScrollView`: drive the effect from `visualEffect` geometry instead. The macOS GIF recorder can't animate scrolling, so record these GIFs with `Scripts/record-simulator-gifs.sh <id>` (and add the id to `simulatorRecorded` in `Scripts/ReadmeGIFs/main.swift`).
- Releases: bump `packageVersion` in `Scripts/DocsGenerator/main.swift` and the `from:` install line in both READMEs, run `Scripts/generate-docs.sh`, then tag the commit with the bare version (`0.4.0`, no `v`). SwiftPM resolves `from:` against these tags.
- After adding or changing an effect, run `Scripts/generate-docs.sh` (README grid, llms.txt, Skill, Cursor rule, catalog JSON) and record its GIF.

## Verifying changes

Full Xcode isn't required. The `#Preview` macro needs Xcode's plugin, so the scripts build a preview-stripped copy of the package (`Scripts/stage-package.sh`):

```sh
Scripts/check-build.sh            # compile MotionLibrary + MotionGallery for macOS
Scripts/generate-docs.sh          # regenerate catalog-derived files (--check in CI)
Scripts/record-readme-gifs.sh id  # record Docs/gifs/<id>.gif off-screen, then look at the frames
Scripts/record-simulator-gifs.sh  # GIFs that need real scrolling, recorded in the iOS Simulator
```

With Xcode, also build for iOS and visionOS (`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -scheme MotionLibrary-Package -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/xcode build`, same with `visionOS Simulator`) and check effects in the canvas. `sensoryFeedback` needs visionOS 26, so use the internal `.haptic(…)` helpers instead.

## Roadmap (suggested next tasks)

1. ~~Make v0.1 compile~~ (done for macOS; still check iOS in Xcode and tune demo sizes in the grid).
2. ~~Demo app~~ (done: `Examples/MotionLibraryDemo`, the gallery plus full-screen scroll examples and their UI tests).
3. ~~Reduce Motion~~ (done: every looping or large-movement effect falls back to a fade or a static state).
4. **More effects.** v0.2 added gradient sweep, blur-in, marquee, wave text, magnetic, hold-to-confirm, status button, glow border, flip, swipe stack, parallax carousel, expandable card, checkmark, confetti, loaders, morphing blob, particle field, starfield, cover flow and float 3D. v0.3 added 40 more (count-up, split text, rotating text, glitch, circular text, focus text, highlighter, shine, jelly, click spark, like button, animated symbol, liquid toggle, hero expand, spotlight card, magnifying dock, jiggle, fan stack, draw-on, progress ring, skeleton, sliding tabs, mesh gradient, retro grid, border beam, waves, film grain, flashlight, fireworks, snowfall, floating reactions, warp tunnel, holographic card) and the Transition component (iris, blinds, clock wipe, pixel dissolve, poof, swoosh, film exposure). v0.4 added 45 more (morphing text, neon, karaoke, weight wave, exploding text, gooey menu, slide to confirm, download button, star rating, bouncy tab bar, scratch card, stacking cards, deck shuffle, looping carousel, drag to dismiss, shrinking/stretchy headers, reading progress, lava lamp, matrix rain, dot grid, meteors, flow field, split-flap, slot machine, price ticker, animated chart, needle gauge, physics emoji, shatter, cube, dot globe, bubbles, fireflies, circular reveal, liquid swipe, page turn, glitch transition, origami) and the Shader component in the separate `MotionShaders` product (water ripple, pixellate, chromatic aberration, CRT, heat haze, noise dissolve). Still open:
   - Cursor / Pointer (iPad & macOS): hover lift (`.hoverEffect`)
5. **"Copy as AI prompt" for the whole filtered list**, and a "View source" link to GitHub from the detail view.
6. **Docs site:** DocC catalog (README GIFs and AI-facing docs are done).
7. **Tests:** `Scripts/generate-docs.sh` already fails on duplicate ids, a missing `api` or a missing source file. Snapshot tests are optional.

## Commit style

Conventional commits, e.g. `feat(text): add gradient sweep`, `fix(gallery): grid cell clipping`.
