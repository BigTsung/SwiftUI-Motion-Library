# CLAUDE.md: guide for AI coding agents

This file is read by Claude Code (and mirrored in AGENTS.md for Codex and other agents). It explains how this repo is organised and how to extend it. **Follow CONTRIBUTING.md for every new effect.**

## What this project is

A SwiftUI counterpart to web "motion library" galleries: a collection of reusable motion effects, organised on two axes:

- **Component** (`MotionComponent`): text, button, card, shape, background, number
- **Trigger** (`MotionTrigger`): appear, tap, press, drag, scroll, change, loop

Each effect has: a public API in `MotionLibrary`, a demo view, and a catalog entry with usage code + an AI prompt shown in the `MotionGallery` browser UI.

## Architecture

```
Package.swift                         # tools 5.9, iOS 17 / macOS 14 / visionOS 1
Sources/MotionLibrary/<Component>/    # effects, public API, zero dependencies
Sources/MotionGallery/
  Model/MotionEffect.swift            # MotionComponent, MotionTrigger, MotionEffect
  Catalog/MotionCatalog.swift         # static list of every effect (display order)
  Catalog/Demos.swift                 # demo views used by the catalog
  Views/                              # gallery grid, detail view, shared components
```

- `MotionLibrary` must never import `MotionGallery`.
- `MotionEffect.demo` is `@MainActor`. Call it only from view bodies or `@MainActor` helpers.
- Catalog `usage` and `prompt` strings use raw multi-line strings `#""" … """#` so key paths like `\.self` don't break.

## Rules

- Pure SwiftUI. No third-party dependencies in either target.
- Don't raise the deployment targets without asking the maintainer.
- Keep public API names short and SwiftUI-like (`.shimmer()`, not `.applyShimmerEffect()`).
- Every effect file ends with a `#Preview`.
- Don't rename existing catalog `id`s or public API (it's a library; breaking changes need a major version).
- Update the README effects table when adding an effect.

## Verifying changes

The environment that created v0.1 had no Swift toolchain, so **v0.1 has never been compiled**. On first checkout on a Mac:

```sh
swift build                                   # macOS build of both targets
xcodebuild -scheme MotionLibrary-Package \
  -destination 'generic/platform=iOS Simulator' build
```

Fix any compile errors first, then open `MotionGalleryView.swift` in Xcode and check every effect visually in the canvas.

## Roadmap (suggested next tasks)

1. **Make v0.1 compile and look right** on iOS and macOS. Tune demo sizes in the grid.
2. **Demo app:** add `Examples/MotionLibraryDemo` (an Xcode app project depending on the local package) that shows `MotionGalleryView()`, so people can run it on a device.
3. **Reduce Motion:** every looping or large-movement effect reads `accessibilityReduceMotion` and falls back to a fade or a static state.
4. **More effects.** Map the web library's categories to SwiftUI:
   - Text: gradient sweep text, per-character wave/bounce (`TextRenderer`, iOS 18), blur-in words, counting-up text, marquee
   - Button: magnetic button (follows the pointer on iPad/macOS `onContinuousHover`), liquid fill on hold, loading-to-success morph, glow border
   - Card & Group: expand-to-detail (`matchedGeometryEffect`), stacked cards swipe (Tinder style), carousel with parallax, accordion, flip card
   - Shape: morphing blob, spinning loaders set, checkmark draw (`trim`), confetti
   - Background: animated mesh gradient (`MeshGradient`, iOS 18), particle field, grid/noise shader
   - Cursor / Pointer (iPad & macOS): spotlight follow, hover lift (`.hoverEffect`)
   - Shaders: Metal `[[stitchable]]` effects via `.colorEffect` / `.distortionEffect` / `.layerEffect` (ripple, pixellate, glitch) in `Sources/MotionLibrary/Shaders/` (add `resources: [.process("Shaders")]` if needed)
5. **"Copy as AI prompt" for the whole filtered list**, and a "View source" link to GitHub from the detail view.
6. **Docs site:** DocC catalog plus GIF previews in the README; CI that builds DocC.
7. **Tests:** snapshot tests are optional; at minimum a test that every catalog `id` is unique and every `sourceFile` exists.

## Commit style

Conventional commits, e.g. `feat(text): add gradient sweep`, `fix(gallery): grid cell clipping`.
