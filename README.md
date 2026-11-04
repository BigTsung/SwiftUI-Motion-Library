<div align="center">

# SwiftUI Motion Library

**Copy-paste SwiftUI motion effects, browsable by component and trigger.**<br>
Each one comes with a live demo, usage code and an AI prompt. Pure SwiftUI, zero dependencies.<br>
<sub>🇹🇼 中文使用者請看 <a href="README.zh-TW.md">繁體中文說明</a></sub>

<a href="https://swift.org"><img alt="Swift 5.9" src="https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white"></a> <img alt="iOS 17 · macOS 14 · visionOS 1" src="https://img.shields.io/badge/iOS%2017%20%C2%B7%20macOS%2014%20%C2%B7%20visionOS%201-555?style=for-the-badge"> <img alt="Swift Package Manager" src="https://img.shields.io/badge/SPM-compatible-2E7DF7?style=for-the-badge"> <a href="#license"><img alt="MIT" src="https://img.shields.io/badge/license-MIT-2EA44F?style=for-the-badge"></a> <a href="README.zh-TW.md"><img alt="繁體中文" src="https://img.shields.io/badge/README-%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87-555?style=for-the-badge"></a>

🤖 **Made for AI coding tools.** `llms.txt`, an Agent Skill, a Cursor rule and an MCP server<br>
are generated from the same catalog as the gallery. [See how ↓](#ask-your-ai-assistant)<br>
**AI agents:** start at [`llms.txt`](https://raw.githubusercontent.com/BigTsung/SwiftUI-Motion-Library/main/llms.txt): every effect, its API and the files it needs.

🆕 **2026-11-04 · v0.4**: 45 new effects and the optional `MotionShaders` product. [See the shaders ↓](#shader)<br>
🆕 **2026-11-04 · Demo app**: an iOS app with the gallery, full-screen scroll examples and their UI tests. [Open it ↓](#option-2-clone-and-browse-the-gallery)

</div>

## ✨ Highlights

<table>
<tr>
<td width="33%" align="center" valign="top"><img src="Docs/gifs/holo-card.gif" width="240" alt="Holographic Card"><br><a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Holographic.swift"><b>Holographic Card</b></a><br><sub>Card · Hover / Drag</sub><br><code>.holographic()</code></td>
<td width="33%" align="center" valign="top"><img src="Docs/gifs/slide-to-confirm.gif" width="240" alt="Slide to Confirm"><br><a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/SlideToConfirm.swift"><b>Slide to Confirm</b></a><br><sub>Button · Drag</sub><br><code>SlideToConfirm(_:action:)</code></td>
<td width="33%" align="center" valign="top"><img src="Docs/gifs/liquid-swipe.gif" width="240" alt="Liquid Swipe"><br><a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/LiquidSwipe.swift"><b>Liquid Swipe</b></a><br><sub>Transition · Value change</sub><br><code>.transition(.liquidSwipe)</code></td>
</tr>
<tr>
<td width="33%" align="center" valign="top"><img src="Docs/gifs/mesh-gradient.gif" width="240" alt="Mesh Gradient"><br><a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/AnimatedMeshGradient.swift"><b>Mesh Gradient</b></a><br><sub>Background · Loop · iOS 18+</sub><br><code>AnimatedMeshGradient()</code></td>
<td width="33%" align="center" valign="top"><img src="Docs/gifs/dot-globe.gif" width="240" alt="Dot Globe"><br><a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/DotGlobe.swift"><b>Dot Globe</b></a><br><sub>Particle &amp; 3D · Loop</sub><br><code>DotGlobe()</code></td>
<td width="33%" align="center" valign="top"><img src="Docs/gifs/water-ripple.gif" width="240" alt="Water Ripple"><br><a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/WaterRipple.swift"><b>Water Ripple</b></a><br><sub>Shader · Tap / Value change</sub><br><code>.waterRippleOnTap()</code></td>
</tr>
</table>

<div align="center">

Every preview is recorded from the gallery's own demos.<br>
[**All effects ↓**](#effects) · [**Use it ↓**](#how-to-use) · [**Contribute ↓**](#contributing)

</div>

## 👋 Why

Web developers have huge motion galleries organised by *what* you animate and *when*. SwiftUI has great one-off repos and a few focused packages, but no single place to browse effects by **component × trigger**, try them, and take the code. This repo aims to be that place.

Every effect ships with:

- 🧩 **A reusable API**: a `View`, `ViewModifier` or `ButtonStyle`, with no dependencies.
- ▶️ **A live demo** in the bundled gallery.
- 📋 **Usage code** you can copy.
- 🤖 **An AI prompt** that describes the look and the technique, so you can paste it into Claude, ChatGPT or Copilot to adapt it.
- ♿️ **Reduce Motion support** for anything that loops or moves a lot.

## How to use

Add the package, then use an effect in one line or let your AI assistant pick one.

### Option 1: Swift Package Manager (recommended)

In Xcode, **File → Add Package Dependencies…** and enter this repository's URL, or in `Package.swift`:

```swift
.package(url: "https://github.com/BigTsung/SwiftUI-Motion-Library", from: "0.4.0")
```

```swift
.product(name: "MotionLibrary", package: "SwiftUI-Motion-Library"),   // the effects
.product(name: "MotionShaders", package: "SwiftUI-Motion-Library"),   // optional Metal shader effects
.product(name: "MotionGallery", package: "SwiftUI-Motion-Library"),   // optional browser UI
```

### Option 2: clone and browse the gallery

- **Fastest:** open `Package.swift` in Xcode, open `Sources/MotionGallery/Views/MotionGalleryView.swift` and use the canvas preview. Every effect file also has its own `#Preview`.
- **In an app:** add the `MotionGallery` product and show `MotionGalleryView()`.
- **Demo app:** open `Examples/MotionLibraryDemo/MotionLibraryDemo.xcodeproj` and run it on a simulator or device (pick your team under Signing to run on a device). It has the gallery plus full-screen examples of the scroll effects (stacking cards, shrinking and stretchy headers, reading progress), and UI tests that scroll them with a finger.

The gallery lets you filter by component and trigger, play with each effect, replay it, and copy the usage code or AI prompt.

### Option 3: copy only the files you need

No dependency at all: click an effect's name below to open its source file and copy it. The API under each preview shows how to call it; [`llms-full.txt`](llms-full.txt) has a full usage example for every effect. Some effects share a small helper (for example `Support/Haptics.swift`); their cell links every extra file to copy. Each effect compiles from just those files, checked by `Scripts/check-standalone.sh`.

### Then write it in one line

```swift
import MotionLibrary

struct LoginView: View {
    @State private var attempts = 0
    @State private var password = ""

    var body: some View {
        VStack(spacing: 24) {
            TypewriterText("Welcome back")
                .font(.largeTitle.bold())

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .shake(trigger: attempts)

            Button("Sign in") { attempts += 1 }
                .buttonStyle(.pressable)
        }
        .padding()
        .background(AuroraBackground().ignoresSafeArea())
    }
}
```

### Ask your AI assistant

The library is built to be picked up by AI assistants, so "add a hold-to-delete button" turns into one line of `MotionLibrary` instead of 80 lines of hand-tuned animation. Paste this into any assistant that can read the web:

```text
Use SwiftUI Motion Library (https://github.com/BigTsung/SwiftUI-Motion-Library).
Read https://raw.githubusercontent.com/BigTsung/SwiftUI-Motion-Library/main/llms.txt first, then add the <effect name> effect to <your view>.
```

The assistant finds the effect there, adds the package (or copies the effect's listed files if you'd rather not add a dependency) and uses the usage code.

| Format | For | How |
|---|---|---|
| [`llms.txt`](llms.txt) / [`llms-full.txt`](llms-full.txt) | Any assistant | Point it at the raw URL, or paste the file. `llms-full.txt` has every effect's usage, technique and source. |
| [Agent Skill](skills/swiftui-motion) | Claude Code and other skill-aware agents | Copy `skills/swiftui-motion` into `~/.claude/skills/` or your project's `.claude/skills/`. |
| [Cursor rule](.cursor/rules/swiftui-motion.mdc) | Cursor | Copy it into your project's `.cursor/rules/`. |
| [MCP server](mcp) | Claude Code, Claude Desktop, Cursor, VS Code… | `claude mcp add swiftui-motion -- node /path/to/mcp/server.mjs`. Tools: `list_motion_effects`, `get_motion_effect`. |
| [`motion-catalog.json`](Docs/motion-catalog.json) | Your own tools | Every effect as structured data. |

All of these are generated from the catalog by `Scripts/generate-docs.sh`; `Scripts/generate-docs.sh --check` reports any that are out of date.

### Before you start

- iOS 17+, macOS 14+, visionOS 1+, Xcode 15+.
- A few effects need iOS 18 (macOS 15, visionOS 2); they are marked in the grid and `@available` in code.
- The Shader effects (water ripple, pixellate, CRT…) live in the separate `MotionShaders` product because they are Metal shaders: Xcode 26 and later download the Metal Toolchain on demand (**Settings → Components**). `MotionLibrary` itself needs nothing extra. The gallery depends on both.

## Effects

Effects are grouped by component: text, buttons, cards, shapes, backgrounds, numbers, particles & 3D, transitions and Metal shaders. Click a name for its source file.

<!-- effects:start (generated by Scripts/generate-docs.sh; edit MotionCatalog.swift instead) -->
<p align="center"><b>118 effects</b> in 9 categories</p>

<table align="center">
<tr>
<td align="center" width="25%">
🔤<br>
<a href="#text"><b>Text</b></a><br>
<sub>19 effects</sub>
</td>
<td align="center" width="25%">
🔘<br>
<a href="#button"><b>Button</b></a><br>
<sub>18 effects</sub>
</td>
<td align="center" width="25%">
🃏<br>
<a href="#card--group"><b>Card &amp; Group</b></a><br>
<sub>19 effects</sub>
</td>
<td align="center" width="25%">
🔷<br>
<a href="#shape"><b>Shape</b></a><br>
<sub>11 effects</sub>
</td>
</tr>
<tr>
<td align="center" width="25%">
🌈<br>
<a href="#background"><b>Background</b></a><br>
<sub>12 effects</sub>
</td>
<td align="center" width="25%">
🔢<br>
<a href="#number"><b>Number</b></a><br>
<sub>6 effects</sub>
</td>
<td align="center" width="25%">
✨<br>
<a href="#particle--3d"><b>Particle &amp; 3D</b></a><br>
<sub>15 effects</sub>
</td>
<td align="center" width="25%">
🎬<br>
<a href="#transition"><b>Transition</b></a><br>
<sub>12 effects</sub>
</td>
</tr>
<tr>
<td align="center" width="25%">
🪄<br>
<a href="#shader"><b>Shader</b></a><br>
<sub>6 effects</sub>
</td>
</tr>
</table>

### Text

<table>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/typewriter.gif" width="240" alt="Typewriter"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/TypewriterText.swift"><b>Typewriter</b></a><br>
<sub>Appear / Value change</sub><br>
<code>TypewriterText(&quot;…&quot;)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/scramble.gif" width="240" alt="Scramble / Decode"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/ScrambleText.swift"><b>Scramble / Decode</b></a><br>
<sub>Appear / Value change</sub><br>
<code>ScrambleText(&quot;…&quot;)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shimmer.gif" width="240" alt="Shimmer"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/Shimmer.swift"><b>Shimmer</b></a><br>
<sub>Loop</sub><br>
<code>.shimmer()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/gradient-sweep.gif" width="240" alt="Gradient Sweep"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/GradientSweep.swift"><b>Gradient Sweep</b></a><br>
<sub>Loop</sub><br>
<code>.gradientSweep()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/blur-in.gif" width="240" alt="Blur-in Words"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/BlurInText.swift"><b>Blur-in Words</b></a><br>
<sub>Appear / Value change</sub><br>
<code>BlurInText(&quot;…&quot;)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/marquee.gif" width="240" alt="Marquee"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/MarqueeText.swift"><b>Marquee</b></a><br>
<sub>Loop</sub><br>
<code>MarqueeText(&quot;…&quot;)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/wave-text.gif" width="240" alt="Wave Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/WaveText.swift"><b>Wave Text</b></a><br>
<sub>Loop · iOS 18+</sub><br>
<code>WaveText(&quot;…&quot;)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/count-up.gif" width="240" alt="Count Up"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/CountUpText.swift"><b>Count Up</b></a><br>
<sub>Appear / Value change</sub><br>
<code>CountUpText(value: …)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/split-text.gif" width="240" alt="Split Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/SplitText.swift"><b>Split Text</b></a><br>
<sub>Appear / Value change · iOS 18+</sub><br>
<code>SplitText(&quot;…&quot;)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/rotating-text.gif" width="240" alt="Rotating Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/RotatingText.swift"><b>Rotating Text</b></a><br>
<sub>Loop</sub><br>
<code>RotatingText([…])</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/glitch.gif" width="240" alt="Glitch"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/Glitch.swift"><b>Glitch</b></a><br>
<sub>Loop</sub><br>
<code>.glitch()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/circular-text.gif" width="240" alt="Circular Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/CircularText.swift"><b>Circular Text</b></a><br>
<sub>Loop</sub><br>
<code>CircularText(&quot;…&quot;)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/focus-text.gif" width="240" alt="Focus Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/FocusText.swift"><b>Focus Text</b></a><br>
<sub>Loop</sub><br>
<code>FocusText(&quot;…&quot;)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/highlighter.gif" width="240" alt="Highlighter"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/Highlighter.swift"><b>Highlighter</b></a><br>
<sub>Appear / Value change</sub><br>
<code>.highlighter()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/morphing-text.gif" width="240" alt="Morphing Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/MorphingText.swift"><b>Morphing Text</b></a><br>
<sub>Loop</sub><br>
<code>MorphingText([…])</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/neon.gif" width="240" alt="Neon Flicker"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/NeonFlicker.swift"><b>Neon Flicker</b></a><br>
<sub>Loop</sub><br>
<code>.neon(color:flicker:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/karaoke-text.gif" width="240" alt="Karaoke Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/KaraokeText.swift"><b>Karaoke Text</b></a><br>
<sub>Value change / Scroll</sub><br>
<code>KaraokeText(_:progress:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/weight-wave.gif" width="240" alt="Weight Wave"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/WeightWaveText.swift"><b>Weight Wave</b></a><br>
<sub>Loop</sub><br>
<code>WeightWaveText(_:)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/exploding-text.gif" width="240" alt="Exploding Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/ExplodingText.swift"><b>Exploding Text</b></a><br>
<sub>Value change / Tap · iOS 18+</sub><br>
<code>ExplodingText(_:isExploded:)</code>
</td>
</tr>
</table>

### Button

<table>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/pressable.gif" width="240" alt="Pressable"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/PressableButtonStyle.swift"><b>Pressable</b></a><br>
<sub>Press</sub><br>
<code>.buttonStyle(.pressable)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/Haptics.swift">Haptics.swift</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/ripple.gif" width="240" alt="Tap Ripple"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/Ripple.swift"><b>Tap Ripple</b></a><br>
<sub>Tap</sub><br>
<code>.ripple()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shake.gif" width="240" alt="Error Shake"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/Shake.swift"><b>Error Shake</b></a><br>
<sub>Value change</sub><br>
<code>.shake(trigger:)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/magnetic.gif" width="240" alt="Magnetic Button"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/Magnetic.swift"><b>Magnetic Button</b></a><br>
<sub>Hover / Drag</sub><br>
<code>.magnetic()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/hold-to-confirm.gif" width="240" alt="Hold to Confirm"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/HoldToConfirmButton.swift"><b>Hold to Confirm</b></a><br>
<sub>Press</sub><br>
<code>HoldToConfirmButton(&quot;…&quot;) { }</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/Haptics.swift">Haptics.swift</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/status-button.gif" width="240" alt="Loading → Success"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/StatusButton.swift"><b>Loading → Success</b></a><br>
<sub>Tap / Value change</sub><br>
<code>StatusButton(&quot;…&quot;, status:) { }</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/CheckmarkShape.swift">CheckmarkShape.swift</a>, <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/Haptics.swift">Haptics.swift</a></sub>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/glow-border.gif" width="240" alt="Glow Border"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/GlowBorder.swift"><b>Glow Border</b></a><br>
<sub>Loop</sub><br>
<code>.glowBorder()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shine.gif" width="240" alt="Shine"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/Shine.swift"><b>Shine</b></a><br>
<sub>Value change / Loop</sub><br>
<code>.shine(every:) / .shine(trigger:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/jelly.gif" width="240" alt="Jelly"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/Jelly.swift"><b>Jelly</b></a><br>
<sub>Tap / Value change</sub><br>
<code>.jelly(trigger:)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/click-spark.gif" width="240" alt="Click Spark"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/ClickSpark.swift"><b>Click Spark</b></a><br>
<sub>Tap</sub><br>
<code>.clickSpark()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/like-button.gif" width="240" alt="Like Button"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/LikeButton.swift"><b>Like Button</b></a><br>
<sub>Tap</sub><br>
<code>LikeButton(isLiked:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/Haptics.swift">Haptics.swift</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/animated-symbol.gif" width="240" alt="Animated Symbol"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/AnimatedSymbol.swift"><b>Animated Symbol</b></a><br>
<sub>Loop</sub><br>
<code>AnimatedSymbol(&quot;…&quot;, style:)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/liquid-toggle.gif" width="240" alt="Liquid Toggle"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/LiquidToggleStyle.swift"><b>Liquid Toggle</b></a><br>
<sub>Tap</sub><br>
<code>.toggleStyle(.liquid)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/gooey-menu.gif" width="240" alt="Gooey Menu"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/GooeyMenu.swift"><b>Gooey Menu</b></a><br>
<sub>Tap</sub><br>
<code>GooeyMenu(symbols:action:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/slide-to-confirm.gif" width="240" alt="Slide to Confirm"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/SlideToConfirm.swift"><b>Slide to Confirm</b></a><br>
<sub>Drag</sub><br>
<code>SlideToConfirm(_:action:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/Haptics.swift">Haptics.swift</a></sub>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/download-button.gif" width="240" alt="Download Button"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/DownloadButton.swift"><b>Download Button</b></a><br>
<sub>Tap / Value change</sub><br>
<code>DownloadButton(progress:action:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/Haptics.swift">Haptics.swift</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/star-rating.gif" width="240" alt="Star Rating"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/StarRating.swift"><b>Star Rating</b></a><br>
<sub>Tap / Value change</sub><br>
<code>StarRating(rating:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/Haptics.swift">Haptics.swift</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/bouncy-tab-bar.gif" width="240" alt="Bouncy Tab Bar"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/BouncyTabBar.swift"><b>Bouncy Tab Bar</b></a><br>
<sub>Tap / Value change</sub><br>
<code>BouncyTabBar(selection:items:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/Haptics.swift">Haptics.swift</a></sub>
</td>
</tr>
</table>

### Card & Group

<table>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/staggered-appear.gif" width="240" alt="Staggered Entrance"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/StaggeredAppear.swift"><b>Staggered Entrance</b></a><br>
<sub>Appear</sub><br>
<code>.staggeredAppear(index:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/tilt.gif" width="240" alt="3D Tilt"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/Tilt.swift"><b>3D Tilt</b></a><br>
<sub>Drag</sub><br>
<code>.tiltOnDrag()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/scroll-reveal.gif" width="240" alt="Scroll Reveal"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ScrollReveal.swift"><b>Scroll Reveal</b></a><br>
<sub>Scroll</sub><br>
<code>.scrollReveal()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/flip-card.gif" width="240" alt="Flip Card"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/FlipCard.swift"><b>Flip Card</b></a><br>
<sub>Tap / Value change</sub><br>
<code>FlipCard(isFlipped:) { } back: { }</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/swipe-stack.gif" width="240" alt="Swipe Card Stack"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/SwipeCardStack.swift"><b>Swipe Card Stack</b></a><br>
<sub>Drag</sub><br>
<code>SwipeCardStack(items) { item in }</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/parallax-carousel.gif" width="240" alt="Parallax Carousel"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ParallaxCarousel.swift"><b>Parallax Carousel</b></a><br>
<sub>Scroll</sub><br>
<code>ParallaxCarousel(items) { item in }</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/expandable-card.gif" width="240" alt="Expandable Card"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ExpandableCard.swift"><b>Expandable Card</b></a><br>
<sub>Tap</sub><br>
<code>ExpandableCard(isExpanded:) { } detail: { }</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/hero-expand.gif" width="240" alt="Hero Expand"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/HeroGrid.swift"><b>Hero Expand</b></a><br>
<sub>Tap</sub><br>
<code>HeroGrid(items) { thumbnail } detail: { }</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/spotlight-card.gif" width="240" alt="Spotlight Card"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/Spotlight.swift"><b>Spotlight Card</b></a><br>
<sub>Hover / Drag</sub><br>
<code>.spotlight()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/dock.gif" width="240" alt="Magnifying Dock"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/MagnifyingDock.swift"><b>Magnifying Dock</b></a><br>
<sub>Hover / Drag</sub><br>
<code>MagnifyingDock(items) { item in }</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/jiggle.gif" width="240" alt="Jiggle"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/Jiggle.swift"><b>Jiggle</b></a><br>
<sub>Loop / Value change</sub><br>
<code>.jiggle(isActive:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/fan-stack.gif" width="240" alt="Fan Stack"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/FanStack.swift"><b>Fan Stack</b></a><br>
<sub>Tap / Value change</sub><br>
<code>FanStack(items, isSpread:) { item in }</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/scratch-card.gif" width="240" alt="Scratch Card"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ScratchCard.swift"><b>Scratch Card</b></a><br>
<sub>Drag</sub><br>
<code>.scratchToReveal(_:onReveal:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/stacking-cards.gif" width="240" alt="Stacking Cards"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/StackingCards.swift"><b>Stacking Cards</b></a><br>
<sub>Scroll</sub><br>
<code>.stackingCard()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/deck-shuffle.gif" width="240" alt="Deck Shuffle"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/DeckShuffle.swift"><b>Deck Shuffle</b></a><br>
<sub>Value change / Tap</sub><br>
<code>DeckShuffle(_:trigger:content:)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/looping-carousel.gif" width="240" alt="Looping Carousel"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/LoopingCarousel.swift"><b>Looping Carousel</b></a><br>
<sub>Drag / Loop</sub><br>
<code>LoopingCarousel(_:autoplay:content:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/drag-to-dismiss.gif" width="240" alt="Drag to Dismiss"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/DragToDismiss.swift"><b>Drag to Dismiss</b></a><br>
<sub>Drag</sub><br>
<code>.dragToDismiss(isPresented:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shrinking-header.gif" width="240" alt="Shrinking Header"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ScrollHeaders.swift"><b>Shrinking Header</b></a><br>
<sub>Scroll</sub><br>
<code>.shrinkingHeader()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/stretchy-header.gif" width="240" alt="Stretchy Header"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ScrollHeaders.swift"><b>Stretchy Header</b></a><br>
<sub>Scroll</sub><br>
<code>.stretchyHeader()</code>
</td>
</tr>
</table>

### Shape

<table>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/pulse-rings.gif" width="240" alt="Pulse Rings"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/PulseRings.swift"><b>Pulse Rings</b></a><br>
<sub>Loop</sub><br>
<code>PulseRings()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/burst.gif" width="240" alt="Like Burst"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/Burst.swift"><b>Like Burst</b></a><br>
<sub>Tap / Value change</sub><br>
<code>.burst(trigger:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/checkmark.gif" width="240" alt="Checkmark Draw"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/AnimatedCheckmark.swift"><b>Checkmark Draw</b></a><br>
<sub>Value change</sub><br>
<code>AnimatedCheckmark(isChecked:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/CheckmarkShape.swift">CheckmarkShape.swift</a></sub>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/confetti.gif" width="240" alt="Confetti"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/Confetti.swift"><b>Confetti</b></a><br>
<sub>Tap / Value change</sub><br>
<code>.confetti(trigger:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/loaders.gif" width="240" alt="Loaders"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/MotionLoader.swift"><b>Loaders</b></a><br>
<sub>Loop</sub><br>
<code>MotionLoader(.spinner)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/morphing-blob.gif" width="240" alt="Morphing Blob"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/MorphingBlob.swift"><b>Morphing Blob</b></a><br>
<sub>Loop</sub><br>
<code>MorphingBlob()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/draw-on.gif" width="240" alt="Draw On"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/DrawOn.swift"><b>Draw On</b></a><br>
<sub>Appear / Value change</sub><br>
<code>Shape.drawOn()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/progress-ring.gif" width="240" alt="Progress Ring"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/ProgressRing.swift"><b>Progress Ring</b></a><br>
<sub>Value change</sub><br>
<code>ProgressRing(progress:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/skeleton.gif" width="240" alt="Skeleton"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/Skeleton.swift"><b>Skeleton</b></a><br>
<sub>Loop / Value change</sub><br>
<code>.skeleton(isLoading:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/Shimmer.swift">Shimmer.swift</a></sub>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/sliding-tabs.gif" width="240" alt="Sliding Tabs"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/SlidingTabs.swift"><b>Sliding Tabs</b></a><br>
<sub>Tap</sub><br>
<code>SlidingTabs([…], selection:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/reading-progress.gif" width="240" alt="Reading Progress"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/ReadingProgress.swift"><b>Reading Progress</b></a><br>
<sub>Scroll</sub><br>
<code>ReadingProgressScrollView { … }</code>
</td>
</tr>
</table>

### Background

<table>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/aurora.gif" width="240" alt="Aurora"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/AuroraBackground.swift"><b>Aurora</b></a><br>
<sub>Loop</sub><br>
<code>AuroraBackground()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/mesh-gradient.gif" width="240" alt="Mesh Gradient"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/AnimatedMeshGradient.swift"><b>Mesh Gradient</b></a><br>
<sub>Loop · iOS 18+</sub><br>
<code>AnimatedMeshGradient()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/retro-grid.gif" width="240" alt="Retro Grid"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/RetroGrid.swift"><b>Retro Grid</b></a><br>
<sub>Loop</sub><br>
<code>RetroGrid()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/border-beam.gif" width="240" alt="Border Beam"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/BorderBeam.swift"><b>Border Beam</b></a><br>
<sub>Loop</sub><br>
<code>.borderBeam()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/waves.gif" width="240" alt="Waves"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/WaveBackground.swift"><b>Waves</b></a><br>
<sub>Loop</sub><br>
<code>WaveBackground()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/grain.gif" width="240" alt="Film Grain"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/Grain.swift"><b>Film Grain</b></a><br>
<sub>Loop</sub><br>
<code>.grain()</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/SeededRandom.swift">SeededRandom.swift</a></sub>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/flashlight.gif" width="240" alt="Flashlight"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/Flashlight.swift"><b>Flashlight</b></a><br>
<sub>Hover / Drag</sub><br>
<code>.flashlight()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/lava-lamp.gif" width="240" alt="Lava Lamp"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/LavaLamp.swift"><b>Lava Lamp</b></a><br>
<sub>Loop</sub><br>
<code>LavaLamp()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/matrix-rain.gif" width="240" alt="Matrix Rain"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/MatrixRain.swift"><b>Matrix Rain</b></a><br>
<sub>Loop</sub><br>
<code>MatrixRain()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/dot-grid.gif" width="240" alt="Interactive Dot Grid"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/InteractiveDotGrid.swift"><b>Interactive Dot Grid</b></a><br>
<sub>Drag / Hover / Loop</sub><br>
<code>InteractiveDotGrid()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/meteors.gif" width="240" alt="Meteors"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/Meteors.swift"><b>Meteors</b></a><br>
<sub>Loop</sub><br>
<code>Meteors()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/flow-field.gif" width="240" alt="Flow Field"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/FlowField.swift"><b>Flow Field</b></a><br>
<sub>Loop</sub><br>
<code>FlowField()</code>
</td>
</tr>
</table>

### Number

<table>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/rolling-number.gif" width="240" alt="Rolling Number"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/RollingNumber.swift"><b>Rolling Number</b></a><br>
<sub>Value change</sub><br>
<code>RollingNumber(value:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/split-flap.gif" width="240" alt="Split-Flap Display"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/SplitFlap.swift"><b>Split-Flap Display</b></a><br>
<sub>Value change</sub><br>
<code>SplitFlapText(_:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/slot-machine.gif" width="240" alt="Slot Machine"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/SlotMachineNumber.swift"><b>Slot Machine</b></a><br>
<sub>Value change</sub><br>
<code>SlotMachineNumber(value:)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/price-ticker.gif" width="240" alt="Price Ticker"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/PriceTicker.swift"><b>Price Ticker</b></a><br>
<sub>Value change</sub><br>
<code>PriceTicker(value:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/animated-chart.gif" width="240" alt="Animated Chart"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/AnimatedChart.swift"><b>Animated Chart</b></a><br>
<sub>Appear / Value change</sub><br>
<code>GrowingBarChart(values:) / DrawingLineChart(values:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/needle-gauge.gif" width="240" alt="Needle Gauge"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/NeedleGauge.swift"><b>Needle Gauge</b></a><br>
<sub>Value change</sub><br>
<code>NeedleGauge(value:)</code>
</td>
</tr>
</table>

### Particle & 3D

<table>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/particle-field.gif" width="240" alt="Particle Field"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/ParticleField.swift"><b>Particle Field</b></a><br>
<sub>Loop</sub><br>
<code>ParticleField()</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/SeededRandom.swift">SeededRandom.swift</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/starfield.gif" width="240" alt="Starfield"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Starfield.swift"><b>Starfield</b></a><br>
<sub>Loop</sub><br>
<code>Starfield()</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/SeededRandom.swift">SeededRandom.swift</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/cover-flow.gif" width="240" alt="Cover Flow"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/CoverFlow.swift"><b>Cover Flow</b></a><br>
<sub>Scroll</sub><br>
<code>CoverFlow(items) { item in }</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/float-3d.gif" width="240" alt="Float 3D"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Float3D.swift"><b>Float 3D</b></a><br>
<sub>Loop</sub><br>
<code>.float3D()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/fireworks.gif" width="240" alt="Fireworks"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Fireworks.swift"><b>Fireworks</b></a><br>
<sub>Loop</sub><br>
<code>Fireworks()</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/SeededRandom.swift">SeededRandom.swift</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/snowfall.gif" width="240" alt="Snowfall &amp; Rain"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Snowfall.swift"><b>Snowfall &amp; Rain</b></a><br>
<sub>Loop</sub><br>
<code>Snowfall(.snow / .rain)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/SeededRandom.swift">SeededRandom.swift</a></sub>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/floating-reactions.gif" width="240" alt="Floating Reactions"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/FloatingReactions.swift"><b>Floating Reactions</b></a><br>
<sub>Tap / Value change</sub><br>
<code>.floatingReactions(trigger:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/warp-tunnel.gif" width="240" alt="Warp Tunnel"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/WarpTunnel.swift"><b>Warp Tunnel</b></a><br>
<sub>Loop</sub><br>
<code>WarpTunnel()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/holo-card.gif" width="240" alt="Holographic Card"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Holographic.swift"><b>Holographic Card</b></a><br>
<sub>Hover / Drag</sub><br>
<code>.holographic()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/physics-emoji.gif" width="240" alt="Physics Emoji"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/PhysicsEmoji.swift"><b>Physics Emoji</b></a><br>
<sub>Value change / Tap</sub><br>
<code>PhysicsEmoji(trigger:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shatter.gif" width="240" alt="Shatter"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Shatter.swift"><b>Shatter</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.shatter)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/cube.gif" width="240" alt="3D Cube"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/CubeTransition.swift"><b>3D Cube</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.cube)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/dot-globe.gif" width="240" alt="Dot Globe"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/DotGlobe.swift"><b>Dot Globe</b></a><br>
<sub>Loop</sub><br>
<code>DotGlobe()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/bubbles.gif" width="240" alt="Bubbles"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Bubbles.swift"><b>Bubbles</b></a><br>
<sub>Loop</sub><br>
<code>Bubbles()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/fireflies.gif" width="240" alt="Fireflies"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Fireflies.swift"><b>Fireflies</b></a><br>
<sub>Loop</sub><br>
<code>Fireflies()</code>
</td>
</tr>
</table>

### Transition

<table>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/iris.gif" width="240" alt="Iris"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/MaskTransitions.swift"><b>Iris</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.iris)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/blinds.gif" width="240" alt="Blinds"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/MaskTransitions.swift"><b>Blinds</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.blinds)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/clock-wipe.gif" width="240" alt="Clock Wipe"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/MaskTransitions.swift"><b>Clock Wipe</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.clockWipe)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/dissolve.gif" width="240" alt="Pixel Dissolve"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/MaskTransitions.swift"><b>Pixel Dissolve</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.dissolve)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/poof.gif" width="240" alt="Poof"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/StyleTransitions.swift"><b>Poof</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.poof)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/swoosh.gif" width="240" alt="Swoosh"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/StyleTransitions.swift"><b>Swoosh</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.swoosh)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/film-exposure.gif" width="240" alt="Film Exposure"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/StyleTransitions.swift"><b>Film Exposure</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.filmExposure)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/circular-reveal.gif" width="240" alt="Circular Reveal"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/CircularReveal.swift"><b>Circular Reveal</b></a><br>
<sub>Tap / Value change</sub><br>
<code>CircularReveal(value:origin:content:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/liquid-swipe.gif" width="240" alt="Liquid Swipe"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/LiquidSwipe.swift"><b>Liquid Swipe</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.liquidSwipe)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/page-turn.gif" width="240" alt="Page Turn"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/PageTurn.swift"><b>Page Turn</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.pageTurn)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/glitch-transition.gif" width="240" alt="Glitch Transition"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/GlitchTransition.swift"><b>Glitch Transition</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.glitch)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/GlitchSlice.swift">GlitchSlice.swift</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/origami.gif" width="240" alt="Origami Fold"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/OrigamiFold.swift"><b>Origami Fold</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.origami)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Support/GlitchSlice.swift">GlitchSlice.swift</a></sub>
</td>
</tr>
</table>

### Shader

<table>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/water-ripple.gif" width="240" alt="Water Ripple"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/WaterRipple.swift"><b>Water Ripple</b></a><br>
<sub>Tap / Value change</sub><br>
<code>.waterRippleOnTap() / .waterRipple(at:trigger:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/Shaders/WaterRipple.metal">WaterRipple.metal</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/pixellate.gif" width="240" alt="Pixellate"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/Pixellate.swift"><b>Pixellate</b></a><br>
<sub>Value change</sub><br>
<code>.pixellate(_:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/Shaders/Pixellate.metal">Pixellate.metal</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/chromatic-aberration.gif" width="240" alt="Chromatic Aberration"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/ChromaticAberration.swift"><b>Chromatic Aberration</b></a><br>
<sub>Value change / Loop</sub><br>
<code>.chromaticAberration(_:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/Shaders/ChromaticAberration.metal">ChromaticAberration.metal</a></sub>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/crt.gif" width="240" alt="CRT Screen"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/CRT.swift"><b>CRT Screen</b></a><br>
<sub>Loop</sub><br>
<code>.crtScreen()</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/Shaders/CRT.metal">CRT.metal</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/heat-haze.gif" width="240" alt="Heat Haze"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/HeatHaze.swift"><b>Heat Haze</b></a><br>
<sub>Loop</sub><br>
<code>.heatHaze(strength:)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/Shaders/HeatHaze.metal">HeatHaze.metal</a></sub>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/noise-dissolve.gif" width="240" alt="Noise Dissolve"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/NoiseDissolve.swift"><b>Noise Dissolve</b></a><br>
<sub>Value change</sub><br>
<code>.noiseDissolve(_:) / .transition(.noiseDissolve)</code><br><sub>Copying the file? Also copy <a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/Shaders/NoiseDissolve.metal">NoiseDissolve.metal</a></sub>
</td>
</tr>
</table>
<!-- effects:end -->

The previews are recorded from the gallery demos with `Scripts/record-readme-gifs.sh` (macOS, needs ffmpeg). It renders off-screen, so you can keep working while it runs.

## Contributing

New effects are very welcome. See [CONTRIBUTING.md](CONTRIBUTING.md). Each effect is one source file, one demo view and one catalog entry.

<details>
<summary><b>Project layout</b></summary>

```
Sources/
  MotionLibrary/          # the effects (public API, zero dependencies)
    Text/  Button/  Card/  Shape/  Background/  Number/  Particle/  Transition/
  MotionShaders/          # optional Metal shader effects (+ Shaders/*.metal)
  MotionGallery/          # catalog metadata + browser UI
    Model/MotionEffect.swift
    Catalog/MotionCatalog.swift   # one entry per effect: the source of truth
    Catalog/Demos.swift           # demo views
    Views/
Docs/                     # README GIFs + motion-catalog.json (generated)
llms.txt  llms-full.txt   # generated
skills/  .cursor/rules/   # Agent Skill and Cursor rule (generated)
mcp/                      # zero-dependency MCP server
Examples/MotionLibraryDemo/  # iOS demo app + scroll UI tests
Scripts/
  check-build.sh          # compile without Xcode
  generate-docs.sh        # regenerate everything derived from the catalog
  record-readme-gifs.sh   # record the README GIFs (off-screen)
  record-simulator-gifs.sh  # GIFs that need real scrolling (iOS Simulator)
```

</details>

## License

MIT. Use it in commercial apps, no attribution required (but appreciated ⭐).

---

<div align="center">

⭐ **Star this repo** if it saved you an afternoon of tuning springs<br>
🧩 **[Add an effect](CONTRIBUTING.md)**: one source file, one demo, one catalog entry

</div>
