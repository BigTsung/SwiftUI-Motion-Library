# AGENTS.md: guide for AI coding agents (mirror of CLAUDE.md, keep both in sync)

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
Scripts/                              # check-build, generate-docs, record-readme-gifs
```

- `MotionLibrary` must never import `MotionGallery`.
- `MotionEffect.demo` is `@MainActor`. Call it only from view bodies or `@MainActor` helpers.
- Catalog `usage` and `prompt` strings use raw multi-line strings `#""" … """#` so key paths like `\.self` don't break.
- Never hand-edit generated files (README grid between the `effects` markers, llms*.txt, Docs/motion-catalog.json, skills/, .cursor/rules/). Change the catalog and run `Scripts/generate-docs.sh`.

## Rules

- Pure SwiftUI. No third-party dependencies in either target.
- Don't raise the deployment targets without asking the maintainer.
- Keep public API names short and SwiftUI-like (`.shimmer()`, not `.applyShimmerEffect()`).
- Every effect file ends with a `#Preview`.
- Don't rename existing catalog `id`s or public API (it's a library; breaking changes need a major version).
- After adding or changing an effect, run `Scripts/generate-docs.sh` (README grid, llms.txt, Skill, Cursor rule, catalog JSON) and record its GIF.

## Verifying changes

Full Xcode isn't required. The `#Preview` macro needs Xcode's plugin, so the scripts build a preview-stripped copy of the package (`Scripts/stage-package.sh`):

```sh
Scripts/check-build.sh            # compile MotionLibrary + MotionGallery for macOS
Scripts/generate-docs.sh          # regenerate catalog-derived files (--check in CI)
Scripts/record-readme-gifs.sh id  # record Docs/gifs/<id>.gif off-screen, then look at the frames
```

With Xcode, also build for iOS and visionOS (`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -scheme MotionLibrary-Package -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/xcode build`, same with `visionOS Simulator`) and check effects in the canvas. `sensoryFeedback` needs visionOS 26, so use the internal `.haptic(…)` helpers instead.

## Roadmap (suggested next tasks)

1. ~~Make v0.1 compile~~ (done for macOS; still check iOS in Xcode and tune demo sizes in the grid).
2. **Demo app:** add `Examples/MotionLibraryDemo` (an Xcode app project depending on the local package) that shows `MotionGalleryView()`, so people can run it on a device.
3. ~~Reduce Motion~~ (done: every looping or large-movement effect falls back to a fade or a static state).
4. **More effects.** v0.2 added gradient sweep, blur-in, marquee, wave text, magnetic, hold-to-confirm, status button, glow border, flip, swipe stack, parallax carousel, expandable card, checkmark, confetti, loaders, morphing blob, particle field, starfield, cover flow and float 3D. v0.3 added 40 more (count-up, split text, rotating text, glitch, circular text, focus text, highlighter, shine, jelly, click spark, like button, animated symbol, liquid toggle, hero expand, spotlight card, magnifying dock, jiggle, fan stack, draw-on, progress ring, skeleton, sliding tabs, mesh gradient, retro grid, border beam, waves, film grain, flashlight, fireworks, snowfall, floating reactions, warp tunnel, holographic card) and the Transition component (iris, blinds, clock wipe, pixel dissolve, poof, swoosh, film exposure). Still open:
   - Cursor / Pointer (iPad & macOS): hover lift (`.hoverEffect`)
   - Shaders: Metal `[[stitchable]]` effects via `.distortionEffect` / `.layerEffect` (water ripple distortion, live pixellate, wave distortion) in `Sources/MotionLibrary/Shaders/` (add `resources: [.process("Shaders")]` if needed). Needs the Metal compiler: Xcode is at `/Applications/Xcode.app` but `xcode-select` may point to the Command Line Tools, so build with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.
5. **"Copy as AI prompt" for the whole filtered list**, and a "View source" link to GitHub from the detail view.
6. **Docs site:** DocC catalog (README GIFs and AI-facing docs are done).
7. **Tests:** `Scripts/generate-docs.sh` already fails on duplicate ids, a missing `api` or a missing source file. Snapshot tests are optional.

## Commit style

Conventional commits, e.g. `feat(text): add gradient sweep`, `fix(gallery): grid cell clipping`.
