<div align="center">

# SwiftUI Motion Library

**Copy-paste SwiftUI motion effects, browsable by component and trigger.**<br>
Each one comes with a live demo, usage code and an AI prompt. Pure SwiftUI, zero dependencies.<br>
<sub>🇹🇼 中文使用者請看 <a href="README.zh-TW.md">繁體中文說明</a></sub>

<a href="https://swift.org"><img alt="Swift 5.9" src="https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white"></a> <img alt="iOS 17 · macOS 14 · visionOS 1" src="https://img.shields.io/badge/iOS%2017%20%C2%B7%20macOS%2014%20%C2%B7%20visionOS%201-555?style=for-the-badge"> <img alt="Swift Package Manager" src="https://img.shields.io/badge/SPM-compatible-2E7DF7?style=for-the-badge"> <a href="#license"><img alt="MIT" src="https://img.shields.io/badge/license-MIT-2EA44F?style=for-the-badge"></a> <a href="README.zh-TW.md"><img alt="繁體中文" src="https://img.shields.io/badge/README-%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87-555?style=for-the-badge"></a>

🤖 **Made for AI coding tools.** `llms.txt`, an Agent Skill, a Cursor rule and an MCP server<br>
are generated from the same catalog as the gallery. [See how ↓](#ask-your-ai-assistant)

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

The library is built to be picked up by AI assistants, so "add a hold-to-delete button" turns into one line of `MotionLibrary` instead of 80 lines of hand-tuned animation.

| Format | For | How |
|---|---|---|
| [`llms.txt`](llms.txt) / [`llms-full.txt`](llms-full.txt) | Any assistant | Point it at the raw URL, or paste the file. `llms-full.txt` has every effect's usage, technique and source. |
| [Agent Skill](skills/swiftui-motion) | Claude Code and other skill-aware agents | Copy `skills/swiftui-motion` into `~/.claude/skills/` or your project's `.claude/skills/`. |
| [Cursor rule](.cursor/rules/swiftui-motion.mdc) | Cursor | Copy it into your project's `.cursor/rules/`. |
| [MCP server](mcp) | Claude Code, Claude Desktop, Cursor, VS Code… | `claude mcp add swiftui-motion -- node /path/to/mcp/server.mjs`. Tools: `list_motion_effects`, `get_motion_effect`. |
| [`motion-catalog.json`](Docs/motion-catalog.json) | Your own tools | Every effect as structured data. |

All of these are generated from the catalog by `Scripts/generate-docs.sh`, and CI fails if they fall out of date.

### Before you start

- iOS 17+, macOS 14+, visionOS 1+, Xcode 15+.
- A few effects need iOS 18 (macOS 15, visionOS 2); they are marked in the grid and `@available` in code.
- The Shader effects (water ripple, pixellate, CRT…) live in the separate `MotionShaders` product because they are Metal shaders: Xcode 26 and later download the Metal Toolchain on demand (**Settings → Components**). `MotionLibrary` itself needs nothing extra. The gallery depends on both.

## Effects

Effects are grouped by component: text, buttons, cards, shapes, backgrounds, numbers, particles & 3D, transitions and Metal shaders. Click a name for its source file, or open **Usage** under a preview to copy the code.

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
<details><summary>Usage</summary>

```swift
TypewriterText("Hello, SwiftUI!", interval: .milliseconds(60))
    .font(.title.bold())
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/scramble.gif" width="240" alt="Scramble / Decode"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/ScrambleText.swift"><b>Scramble / Decode</b></a><br>
<sub>Appear / Value change</sub><br>
<code>ScrambleText(&quot;…&quot;)</code>
<details><summary>Usage</summary>

```swift
ScrambleText("ACCESS GRANTED", duration: 1.0)
    .font(.title.bold())
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shimmer.gif" width="240" alt="Shimmer"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/Shimmer.swift"><b>Shimmer</b></a><br>
<sub>Loop</sub><br>
<code>.shimmer()</code>
<details><summary>Usage</summary>

```swift
Text("Loading…")
    .font(.title)
    .shimmer()

RoundedRectangle(cornerRadius: 8)
    .fill(.gray.opacity(0.3))
    .frame(height: 44)
    .shimmer(duration: 1.2)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/gradient-sweep.gif" width="240" alt="Gradient Sweep"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/GradientSweep.swift"><b>Gradient Sweep</b></a><br>
<sub>Loop</sub><br>
<code>.gradientSweep()</code>
<details><summary>Usage</summary>

```swift
Text("Motion Library")
    .font(.largeTitle.weight(.heavy))
    .gradientSweep()

Image(systemName: "sparkles")
    .font(.system(size: 60))
    .gradientSweep(colors: [.yellow, .orange, .pink], duration: 2)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/blur-in.gif" width="240" alt="Blur-in Words"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/BlurInText.swift"><b>Blur-in Words</b></a><br>
<sub>Appear / Value change</sub><br>
<code>BlurInText(&quot;…&quot;)</code>
<details><summary>Usage</summary>

```swift
BlurInText("Design is how it works.")
    .font(.title.weight(.semibold))

BlurInText("Letter by letter", by: .character, stagger: 0.03)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/marquee.gif" width="240" alt="Marquee"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/MarqueeText.swift"><b>Marquee</b></a><br>
<sub>Loop</sub><br>
<code>MarqueeText(&quot;…&quot;)</code>
<details><summary>Usage</summary>

```swift
MarqueeText("Now playing: Midnight Drive — Neon Coast")
    .font(.headline)
    .frame(width: 200)

MarqueeText(longTitle, speed: 60, gap: 24)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/wave-text.gif" width="240" alt="Wave Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/WaveText.swift"><b>Wave Text</b></a><br>
<sub>Loop · iOS 18+</sub><br>
<code>WaveText(&quot;…&quot;)</code>
<details><summary>Usage</summary>

```swift
if #available(iOS 18, *) {
    WaveText("Making waves")
        .font(.largeTitle.bold())
        .foregroundStyle(.blue)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/count-up.gif" width="240" alt="Count Up"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/CountUpText.swift"><b>Count Up</b></a><br>
<sub>Appear / Value change</sub><br>
<code>CountUpText(value: …)</code>
<details><summary>Usage</summary>

```swift
CountUpText(value: revenue, prefix: "$")
    .font(.largeTitle.bold())

CountUpText(value: 98.6, fractionDigits: 1, suffix: "%", duration: 2)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/split-text.gif" width="240" alt="Split Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/SplitText.swift"><b>Split Text</b></a><br>
<sub>Appear / Value change · iOS 18+</sub><br>
<code>SplitText(&quot;…&quot;)</code>
<details><summary>Usage</summary>

```swift
if #available(iOS 18, *) {
    SplitText("Letters take the stage")
        .font(.largeTitle.bold())
}
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/rotating-text.gif" width="240" alt="Rotating Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/RotatingText.swift"><b>Rotating Text</b></a><br>
<sub>Loop</sub><br>
<code>RotatingText([…])</code>
<details><summary>Usage</summary>

```swift
HStack {
    Text("We")
    RotatingText(["design", "build", "ship"])
        .foregroundStyle(.blue)
}
.font(.largeTitle.bold())
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/glitch.gif" width="240" alt="Glitch"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/Glitch.swift"><b>Glitch</b></a><br>
<sub>Loop</sub><br>
<code>.glitch()</code>
<details><summary>Usage</summary>

```swift
Text("SYSTEM FAILURE")
    .font(.title.monospaced().bold())
    .glitch()

Image("logo")
    .glitch(intensity: 2, interval: 4)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/circular-text.gif" width="240" alt="Circular Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/CircularText.swift"><b>Circular Text</b></a><br>
<sub>Loop</sub><br>
<code>CircularText(&quot;…&quot;)</code>
<details><summary>Usage</summary>

```swift
ZStack {
    CircularText("SWIFTUI • MOTION • LIBRARY • ", radius: 60)
        .font(.caption.monospaced().bold())
    Image(systemName: "sparkles").font(.largeTitle)
}
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/focus-text.gif" width="240" alt="Focus Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/FocusText.swift"><b>Focus Text</b></a><br>
<sub>Loop</sub><br>
<code>FocusText(&quot;…&quot;)</code>
<details><summary>Usage</summary>

```swift
FocusText("Motion made simple")
    .font(.title.bold())

FocusText("Plan Build Ship", interval: 0.8, bracketColor: .pink)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/highlighter.gif" width="240" alt="Highlighter"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/Highlighter.swift"><b>Highlighter</b></a><br>
<sub>Appear / Value change</sub><br>
<code>.highlighter()</code>
<details><summary>Usage</summary>

```swift
Text("the important part")
    .highlighter()

Text("Pricing")
    .highlighter(isActive: isSelected, color: .pink, style: .underline)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/morphing-text.gif" width="240" alt="Morphing Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/MorphingText.swift"><b>Morphing Text</b></a><br>
<sub>Loop</sub><br>
<code>MorphingText([…])</code>
<details><summary>Usage</summary>

```swift
MorphingText(["Design", "Build", "Ship"])
    .font(.system(size: 44, weight: .black, design: .rounded))
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/neon.gif" width="240" alt="Neon Flicker"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/NeonFlicker.swift"><b>Neon Flicker</b></a><br>
<sub>Loop</sub><br>
<code>.neon(color:flicker:)</code>
<details><summary>Usage</summary>

```swift
Text("OPEN")
    .font(.system(size: 48, weight: .bold, design: .rounded))
    .neon(color: .pink)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/karaoke-text.gif" width="240" alt="Karaoke Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/KaraokeText.swift"><b>Karaoke Text</b></a><br>
<sub>Value change / Scroll</sub><br>
<code>KaraokeText(_:progress:)</code>
<details><summary>Usage</summary>

```swift
KaraokeText("Never gonna stop the music", progress: playback, highlight: .pink)
    .font(.title2.bold())
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/weight-wave.gif" width="240" alt="Weight Wave"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/WeightWaveText.swift"><b>Weight Wave</b></a><br>
<sub>Loop</sub><br>
<code>WeightWaveText(_:)</code>
<details><summary>Usage</summary>

```swift
WeightWaveText("Variable weight")
    .font(.system(size: 36, design: .rounded))
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/exploding-text.gif" width="240" alt="Exploding Text"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Text/ExplodingText.swift"><b>Exploding Text</b></a><br>
<sub>Value change / Tap · iOS 18+</sub><br>
<code>ExplodingText(_:isExploded:)</code>
<details><summary>Usage</summary>

```swift
ExplodingText("Kaboom!", isExploded: exploded)
    .font(.system(size: 44, weight: .heavy, design: .rounded))
    .onTapGesture { exploded.toggle() }
```

</details>
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
<code>.buttonStyle(.pressable)</code>
<details><summary>Usage</summary>

```swift
Button("Continue") { }
    .buttonStyle(.pressable)

Button("Big squish") { }
    .buttonStyle(.pressable(scale: 0.85))
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/ripple.gif" width="240" alt="Tap Ripple"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/Ripple.swift"><b>Tap Ripple</b></a><br>
<sub>Tap</sub><br>
<code>.ripple()</code>
<details><summary>Usage</summary>

```swift
Text("Tap")
    .frame(width: 200, height: 60)
    .background(.indigo, in: RoundedRectangle(cornerRadius: 12))
    .ripple(color: .white, cornerRadius: 12)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shake.gif" width="240" alt="Error Shake"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/Shake.swift"><b>Error Shake</b></a><br>
<sub>Value change</sub><br>
<code>.shake(trigger:)</code>
<details><summary>Usage</summary>

```swift
@State private var attempts = 0

SecureField("Password", text: $password)
    .shake(trigger: attempts)
    .sensoryFeedback(.error, trigger: attempts)

// On a failed login:
attempts += 1
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/magnetic.gif" width="240" alt="Magnetic Button"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/Magnetic.swift"><b>Magnetic Button</b></a><br>
<sub>Hover / Drag</sub><br>
<code>.magnetic()</code>
<details><summary>Usage</summary>

```swift
Button("Get started") { }
    .buttonStyle(.borderedProminent)
    .magnetic()

Image(systemName: "plus.circle.fill")
    .font(.system(size: 44))
    .magnetic(strength: 0.5, radius: 40)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/hold-to-confirm.gif" width="240" alt="Hold to Confirm"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/HoldToConfirmButton.swift"><b>Hold to Confirm</b></a><br>
<sub>Press</sub><br>
<code>HoldToConfirmButton(&quot;…&quot;) { }</code>
<details><summary>Usage</summary>

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

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/status-button.gif" width="240" alt="Loading → Success"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/StatusButton.swift"><b>Loading → Success</b></a><br>
<sub>Tap / Value change</sub><br>
<code>StatusButton(&quot;…&quot;, status:) { }</code>
<details><summary>Usage</summary>

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

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/glow-border.gif" width="240" alt="Glow Border"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/GlowBorder.swift"><b>Glow Border</b></a><br>
<sub>Loop</sub><br>
<code>.glowBorder()</code>
<details><summary>Usage</summary>

```swift
Text("Upgrade to Pro")
    .padding()
    .background(.black, in: RoundedRectangle(cornerRadius: 14))
    .glowBorder(cornerRadius: 14)

CardView()
    .glowBorder(colors: [.orange, .yellow], cornerRadius: 24, lineWidth: 3)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shine.gif" width="240" alt="Shine"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/Shine.swift"><b>Shine</b></a><br>
<sub>Value change / Loop</sub><br>
<code>.shine(every:) / .shine(trigger:)</code>
<details><summary>Usage</summary>

```swift
PremiumBadge()
    .shine(every: 3)

Button("Upgrade") { purchases += 1 }
    .buttonStyle(.borderedProminent)
    .shine(trigger: purchases)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/jelly.gif" width="240" alt="Jelly"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/Jelly.swift"><b>Jelly</b></a><br>
<sub>Tap / Value change</sub><br>
<code>.jelly(trigger:)</code>
<details><summary>Usage</summary>

```swift
Button("Boing") { taps += 1 }
    .buttonStyle(.borderedProminent)
    .jelly(trigger: taps)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/click-spark.gif" width="240" alt="Click Spark"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/ClickSpark.swift"><b>Click Spark</b></a><br>
<sub>Tap</sub><br>
<code>.clickSpark()</code>
<details><summary>Usage</summary>

```swift
Button("Launch") { }
    .buttonStyle(.borderedProminent)
    .clickSpark(color: .orange)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/like-button.gif" width="240" alt="Like Button"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/LikeButton.swift"><b>Like Button</b></a><br>
<sub>Tap</sub><br>
<code>LikeButton(isLiked:)</code>
<details><summary>Usage</summary>

```swift
LikeButton(isLiked: $post.isLiked)

LikeButton(isLiked: $liked, size: 40, color: .red)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/animated-symbol.gif" width="240" alt="Animated Symbol"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/AnimatedSymbol.swift"><b>Animated Symbol</b></a><br>
<sub>Loop</sub><br>
<code>AnimatedSymbol(&quot;…&quot;, style:)</code>
<details><summary>Usage</summary>

```swift
AnimatedSymbol("bell.fill")                      // bounces every 1.5 s
AnimatedSymbol("heart.fill", style: .pulse)
AnimatedSymbol("wifi", style: .variableColor)
AnimatedSymbol("mic.fill", style: .scaleUp, isActive: isRecording)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/liquid-toggle.gif" width="240" alt="Liquid Toggle"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/LiquidToggleStyle.swift"><b>Liquid Toggle</b></a><br>
<sub>Tap</sub><br>
<code>.toggleStyle(.liquid)</code>
<details><summary>Usage</summary>

```swift
Toggle("Wi-Fi", isOn: $wifi)
    .toggleStyle(.liquid)

Toggle("Dark mode", isOn: $dark)
    .toggleStyle(.liquid(tint: .purple))
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/gooey-menu.gif" width="240" alt="Gooey Menu"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/GooeyMenu.swift"><b>Gooey Menu</b></a><br>
<sub>Tap</sub><br>
<code>GooeyMenu(symbols:action:)</code>
<details><summary>Usage</summary>

```swift
GooeyMenu(symbols: ["camera.fill", "photo.fill", "mic.fill"], color: .indigo) { index in
    attach(index)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/slide-to-confirm.gif" width="240" alt="Slide to Confirm"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/SlideToConfirm.swift"><b>Slide to Confirm</b></a><br>
<sub>Drag</sub><br>
<code>SlideToConfirm(_:action:)</code>
<details><summary>Usage</summary>

```swift
SlideToConfirm("Slide to pay", color: .green) {
    pay()
}
.frame(width: 280)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/download-button.gif" width="240" alt="Download Button"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/DownloadButton.swift"><b>Download Button</b></a><br>
<sub>Tap / Value change</sub><br>
<code>DownloadButton(progress:action:)</code>
<details><summary>Usage</summary>

```swift
DownloadButton(progress: download.progress) {
    download.start()
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/star-rating.gif" width="240" alt="Star Rating"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/StarRating.swift"><b>Star Rating</b></a><br>
<sub>Tap / Value change</sub><br>
<code>StarRating(rating:)</code>
<details><summary>Usage</summary>

```swift
StarRating(rating: $rating)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/bouncy-tab-bar.gif" width="240" alt="Bouncy Tab Bar"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Button/BouncyTabBar.swift"><b>Bouncy Tab Bar</b></a><br>
<sub>Tap / Value change</sub><br>
<code>BouncyTabBar(selection:items:)</code>
<details><summary>Usage</summary>

```swift
BouncyTabBar(selection: $tab, items: [
    .init("house.fill", "Home"),
    .init("magnifyingglass", "Search"),
    .init("person.fill", "Profile"),
])
```

</details>
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
<details><summary>Usage</summary>

```swift
ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
    CardView(item)
        .staggeredAppear(index: index)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/tilt.gif" width="240" alt="3D Tilt"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/Tilt.swift"><b>3D Tilt</b></a><br>
<sub>Drag</sub><br>
<code>.tiltOnDrag()</code>
<details><summary>Usage</summary>

```swift
CardView()
    .tiltOnDrag(maxAngle: 15, cornerRadius: 20)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/scroll-reveal.gif" width="240" alt="Scroll Reveal"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ScrollReveal.swift"><b>Scroll Reveal</b></a><br>
<sub>Scroll</sub><br>
<code>.scrollReveal()</code>
<details><summary>Usage</summary>

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            Row(item).scrollReveal()
        }
    }
}
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/flip-card.gif" width="240" alt="Flip Card"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/FlipCard.swift"><b>Flip Card</b></a><br>
<sub>Tap / Value change</sub><br>
<code>FlipCard(isFlipped:) { } back: { }</code>
<details><summary>Usage</summary>

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

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/swipe-stack.gif" width="240" alt="Swipe Card Stack"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/SwipeCardStack.swift"><b>Swipe Card Stack</b></a><br>
<sub>Drag</sub><br>
<code>SwipeCardStack(items) { item in }</code>
<details><summary>Usage</summary>

```swift
SwipeCardStack(profiles) { profile, direction in
    direction == .right ? like(profile) : pass(profile)
} card: { profile in
    ProfileCard(profile)
        .frame(width: 300, height: 420)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/parallax-carousel.gif" width="240" alt="Parallax Carousel"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ParallaxCarousel.swift"><b>Parallax Carousel</b></a><br>
<sub>Scroll</sub><br>
<code>ParallaxCarousel(items) { item in }</code>
<details><summary>Usage</summary>

```swift
ParallaxCarousel(places) { place in
    Image(place.photo)
        .resizable()
        .scaledToFill()
}
.frame(height: 240)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/expandable-card.gif" width="240" alt="Expandable Card"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ExpandableCard.swift"><b>Expandable Card</b></a><br>
<sub>Tap</sub><br>
<code>ExpandableCard(isExpanded:) { } detail: { }</code>
<details><summary>Usage</summary>

```swift
@State private var isOpen = false

ExpandableCard(isExpanded: $isOpen) {
    Text("Shipping").font(.headline)
} detail: {
    Text("Arrives Thursday. Free returns within 30 days.")
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/hero-expand.gif" width="240" alt="Hero Expand"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/HeroGrid.swift"><b>Hero Expand</b></a><br>
<sub>Tap</sub><br>
<code>HeroGrid(items) { thumbnail } detail: { }</code>
<details><summary>Usage</summary>

```swift
HeroGrid(photos, columns: 3) { photo in
    Image(photo.thumbnail).resizable().scaledToFill().frame(height: 90)
} detail: { photo in
    PhotoDetail(photo)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/spotlight-card.gif" width="240" alt="Spotlight Card"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/Spotlight.swift"><b>Spotlight Card</b></a><br>
<sub>Hover / Drag</sub><br>
<code>.spotlight()</code>
<details><summary>Usage</summary>

```swift
FeatureCard()
    .background(.black, in: RoundedRectangle(cornerRadius: 20))
    .spotlight()

PricingCard()
    .spotlight(color: .purple.opacity(0.4), radius: 160)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/dock.gif" width="240" alt="Magnifying Dock"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/MagnifyingDock.swift"><b>Magnifying Dock</b></a><br>
<sub>Hover / Drag</sub><br>
<code>MagnifyingDock(items) { item in }</code>
<details><summary>Usage</summary>

```swift
MagnifyingDock(apps) { app in
    Image(app.icon).resizable()
}
.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/jiggle.gif" width="240" alt="Jiggle"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/Jiggle.swift"><b>Jiggle</b></a><br>
<sub>Loop / Value change</sub><br>
<code>.jiggle(isActive:)</code>
<details><summary>Usage</summary>

```swift
ForEach(apps) { app in
    AppIcon(app)
        .jiggle(isActive: isEditing)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/fan-stack.gif" width="240" alt="Fan Stack"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/FanStack.swift"><b>Fan Stack</b></a><br>
<sub>Tap / Value change</sub><br>
<code>FanStack(items, isSpread:) { item in }</code>
<details><summary>Usage</summary>

```swift
FanStack(cards, isSpread: isSpread) { card in
    CardView(card).frame(width: 80, height: 120)
}
.onTapGesture { isSpread.toggle() }
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/scratch-card.gif" width="240" alt="Scratch Card"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ScratchCard.swift"><b>Scratch Card</b></a><br>
<sub>Drag</sub><br>
<code>.scratchToReveal(_:onReveal:)</code>
<details><summary>Usage</summary>

```swift
PrizeView()
    .scratchToReveal(Color.gray) {
        didReveal = true
    }
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/stacking-cards.gif" width="240" alt="Stacking Cards"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/StackingCards.swift"><b>Stacking Cards</b></a><br>
<sub>Scroll</sub><br>
<code>.stackingCard()</code>
<details><summary>Usage</summary>

```swift
ScrollView {
    VStack(spacing: 16) {
        ForEach(cards) { card in
            CardView(card).stackingCard()
        }
    }
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/deck-shuffle.gif" width="240" alt="Deck Shuffle"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/DeckShuffle.swift"><b>Deck Shuffle</b></a><br>
<sub>Value change / Tap</sub><br>
<code>DeckShuffle(_:trigger:content:)</code>
<details><summary>Usage</summary>

```swift
DeckShuffle(cards, trigger: shuffles) { card in
    CardFace(card)
}
.onTapGesture { shuffles += 1 }
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/looping-carousel.gif" width="240" alt="Looping Carousel"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/LoopingCarousel.swift"><b>Looping Carousel</b></a><br>
<sub>Drag / Loop</sub><br>
<code>LoopingCarousel(_:autoplay:content:)</code>
<details><summary>Usage</summary>

```swift
LoopingCarousel(banners, autoplay: 3) { banner in
    BannerCard(banner)
}
.frame(height: 200)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/drag-to-dismiss.gif" width="240" alt="Drag to Dismiss"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/DragToDismiss.swift"><b>Drag to Dismiss</b></a><br>
<sub>Drag</sub><br>
<code>.dragToDismiss(isPresented:)</code>
<details><summary>Usage</summary>

```swift
if showPhoto {
    PhotoView()
        .dragToDismiss(isPresented: $showPhoto)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shrinking-header.gif" width="240" alt="Shrinking Header"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ScrollHeaders.swift"><b>Shrinking Header</b></a><br>
<sub>Scroll</sub><br>
<code>.shrinkingHeader()</code>
<details><summary>Usage</summary>

```swift
ScrollView {
    VStack(spacing: 0) {
        ProfileHeader().shrinkingHeader()
        ForEach(posts) { PostRow($0) }
    }
}
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/stretchy-header.gif" width="240" alt="Stretchy Header"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Card/ScrollHeaders.swift"><b>Stretchy Header</b></a><br>
<sub>Scroll</sub><br>
<code>.stretchyHeader()</code>
<details><summary>Usage</summary>

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

</details>
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
<details><summary>Usage</summary>

```swift
ZStack {
    PulseRings(color: .green, count: 3)
        .frame(width: 120, height: 120)
    Circle().fill(.green).frame(width: 24, height: 24)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/burst.gif" width="240" alt="Like Burst"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/Burst.swift"><b>Like Burst</b></a><br>
<sub>Tap / Value change</sub><br>
<code>.burst(trigger:)</code>
<details><summary>Usage</summary>

```swift
Image(systemName: isLiked ? "heart.fill" : "heart")
    .contentTransition(.symbolEffect(.replace))
    .burst(trigger: isLiked, color: .pink, isEnabled: isLiked)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/checkmark.gif" width="240" alt="Checkmark Draw"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/AnimatedCheckmark.swift"><b>Checkmark Draw</b></a><br>
<sub>Value change</sub><br>
<code>AnimatedCheckmark(isChecked:)</code>
<details><summary>Usage</summary>

```swift
AnimatedCheckmark(isChecked: isDone)
    .frame(width: 80, height: 80)

AnimatedCheckmark(isChecked: saved, color: .blue, lineWidth: 3)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/confetti.gif" width="240" alt="Confetti"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/Confetti.swift"><b>Confetti</b></a><br>
<sub>Tap / Value change</sub><br>
<code>.confetti(trigger:)</code>
<details><summary>Usage</summary>

```swift
@State private var orders = 0

Button("Complete order") { orders += 1 }
    .confetti(trigger: orders)

Text("🎉 Level up!")
    .confetti(trigger: level, colors: [.yellow, .orange], count: 120)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/loaders.gif" width="240" alt="Loaders"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/MotionLoader.swift"><b>Loaders</b></a><br>
<sub>Loop</sub><br>
<code>MotionLoader(.spinner)</code>
<details><summary>Usage</summary>

```swift
MotionLoader(.spinner)
    .frame(width: 32, height: 32)

MotionLoader(.dots, color: .secondary)
    .frame(width: 44, height: 44)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/morphing-blob.gif" width="240" alt="Morphing Blob"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/MorphingBlob.swift"><b>Morphing Blob</b></a><br>
<sub>Loop</sub><br>
<code>MorphingBlob()</code>
<details><summary>Usage</summary>

```swift
MorphingBlob(colors: [.purple, .pink, .orange])
    .frame(width: 200, height: 200)

MorphingBlob(fill: Color.blue.opacity(0.3), points: 8, wobble: 0.1)
    .overlay(Image(systemName: "mic.fill"))
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/draw-on.gif" width="240" alt="Draw On"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/DrawOn.swift"><b>Draw On</b></a><br>
<sub>Appear / Value change</sub><br>
<code>Shape.drawOn()</code>
<details><summary>Usage</summary>

```swift
Circle()
    .drawOn()
    .frame(width: 80, height: 80)

SignaturePath()
    .drawOn(isDrawn: signed, style: .blue, lineWidth: 3, duration: 1.6)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/progress-ring.gif" width="240" alt="Progress Ring"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/ProgressRing.swift"><b>Progress Ring</b></a><br>
<sub>Value change</sub><br>
<code>ProgressRing(progress:)</code>
<details><summary>Usage</summary>

```swift
ProgressRing(progress: uploaded)
    .frame(width: 120, height: 120)

ProgressRing(progress: steps / goal, colors: [.green, .mint]) {
    Image(systemName: "figure.walk").font(.title)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/skeleton.gif" width="240" alt="Skeleton"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/Skeleton.swift"><b>Skeleton</b></a><br>
<sub>Loop / Value change</sub><br>
<code>.skeleton(isLoading:)</code>
<details><summary>Usage</summary>

```swift
ArticleRow(article)
    .skeleton(isLoading: isLoading)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/sliding-tabs.gif" width="240" alt="Sliding Tabs"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/SlidingTabs.swift"><b>Sliding Tabs</b></a><br>
<sub>Tap</sub><br>
<code>SlidingTabs([…], selection:)</code>
<details><summary>Usage</summary>

```swift
SlidingTabs(["Day", "Week", "Month"], selection: $range)

SlidingTabs(Category.allCases, selection: $category, indicator: .underline) { $0.title }
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/reading-progress.gif" width="240" alt="Reading Progress"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Shape/ReadingProgress.swift"><b>Reading Progress</b></a><br>
<sub>Scroll</sub><br>
<code>ReadingProgressScrollView { … }</code>
<details><summary>Usage</summary>

```swift
ReadingProgressScrollView(color: .pink) {
    ArticleBody()
}
```

</details>
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
<details><summary>Usage</summary>

```swift
ZStack {
    AuroraBackground(colors: [.purple, .blue, .teal, .pink])
        .ignoresSafeArea()
    Text("Welcome").font(.largeTitle.bold())
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/mesh-gradient.gif" width="240" alt="Mesh Gradient"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/AnimatedMeshGradient.swift"><b>Mesh Gradient</b></a><br>
<sub>Loop · iOS 18+</sub><br>
<code>AnimatedMeshGradient()</code>
<details><summary>Usage</summary>

```swift
if #available(iOS 18, *) {
    AnimatedMeshGradient()
        .ignoresSafeArea()
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/retro-grid.gif" width="240" alt="Retro Grid"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/RetroGrid.swift"><b>Retro Grid</b></a><br>
<sub>Loop</sub><br>
<code>RetroGrid()</code>
<details><summary>Usage</summary>

```swift
ZStack {
    Color.black
    RetroGrid(color: .pink)
    Text("NEON").font(.system(size: 60, weight: .black))
}
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/border-beam.gif" width="240" alt="Border Beam"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/BorderBeam.swift"><b>Border Beam</b></a><br>
<sub>Loop</sub><br>
<code>.borderBeam()</code>
<details><summary>Usage</summary>

```swift
PlanCard()
    .background(.black, in: RoundedRectangle(cornerRadius: 20))
    .borderBeam(cornerRadius: 20)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/waves.gif" width="240" alt="Waves"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/WaveBackground.swift"><b>Waves</b></a><br>
<sub>Loop</sub><br>
<code>WaveBackground()</code>
<details><summary>Usage</summary>

```swift
ZStack(alignment: .top) {
    WaveBackground()
        .ignoresSafeArea()
    Text("Ocean").font(.largeTitle.bold()).padding(.top, 80)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/grain.gif" width="240" alt="Film Grain"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/Grain.swift"><b>Film Grain</b></a><br>
<sub>Loop</sub><br>
<code>.grain()</code>
<details><summary>Usage</summary>

```swift
LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
    .grain()

HeroImage()
    .grain(opacity: 0.2, isAnimated: false)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/flashlight.gif" width="240" alt="Flashlight"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/Flashlight.swift"><b>Flashlight</b></a><br>
<sub>Hover / Drag</sub><br>
<code>.flashlight()</code>
<details><summary>Usage</summary>

```swift
TreasureMap()
    .flashlight(radius: 100)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/lava-lamp.gif" width="240" alt="Lava Lamp"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/LavaLamp.swift"><b>Lava Lamp</b></a><br>
<sub>Loop</sub><br>
<code>LavaLamp()</code>
<details><summary>Usage</summary>

```swift
LavaLamp(colors: [.yellow, .orange, .pink])
    .ignoresSafeArea()
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/matrix-rain.gif" width="240" alt="Matrix Rain"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/MatrixRain.swift"><b>Matrix Rain</b></a><br>
<sub>Loop</sub><br>
<code>MatrixRain()</code>
<details><summary>Usage</summary>

```swift
MatrixRain(color: .green)
    .background(.black)
    .ignoresSafeArea()
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/dot-grid.gif" width="240" alt="Interactive Dot Grid"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/InteractiveDotGrid.swift"><b>Interactive Dot Grid</b></a><br>
<sub>Drag / Hover / Loop</sub><br>
<code>InteractiveDotGrid()</code>
<details><summary>Usage</summary>

```swift
InteractiveDotGrid(spacing: 18)
    .ignoresSafeArea()
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/meteors.gif" width="240" alt="Meteors"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/Meteors.swift"><b>Meteors</b></a><br>
<sub>Loop</sub><br>
<code>Meteors()</code>
<details><summary>Usage</summary>

```swift
Meteors(count: 10)
    .background(Color(red: 0.03, green: 0.04, blue: 0.12))
    .ignoresSafeArea()
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/flow-field.gif" width="240" alt="Flow Field"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Background/FlowField.swift"><b>Flow Field</b></a><br>
<sub>Loop</sub><br>
<code>FlowField()</code>
<details><summary>Usage</summary>

```swift
FlowField(colors: [.cyan, .blue, .purple, .pink])
    .background(Color(white: 0.06))
    .ignoresSafeArea()
```

</details>
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
<details><summary>Usage</summary>

```swift
RollingNumber(value: score)
    .font(.system(size: 48, weight: .bold, design: .rounded))
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/split-flap.gif" width="240" alt="Split-Flap Display"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/SplitFlap.swift"><b>Split-Flap Display</b></a><br>
<sub>Value change</sub><br>
<code>SplitFlapText(_:)</code>
<details><summary>Usage</summary>

```swift
SplitFlapText(departure.time)   // "12:45"
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/slot-machine.gif" width="240" alt="Slot Machine"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/SlotMachineNumber.swift"><b>Slot Machine</b></a><br>
<sub>Value change</sub><br>
<code>SlotMachineNumber(value:)</code>
<details><summary>Usage</summary>

```swift
SlotMachineNumber(value: score, digits: 3)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/price-ticker.gif" width="240" alt="Price Ticker"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/PriceTicker.swift"><b>Price Ticker</b></a><br>
<sub>Value change</sub><br>
<code>PriceTicker(value:)</code>
<details><summary>Usage</summary>

```swift
PriceTicker(value: stock.price)
    .font(.title2.bold())
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/animated-chart.gif" width="240" alt="Animated Chart"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/AnimatedChart.swift"><b>Animated Chart</b></a><br>
<sub>Appear / Value change</sub><br>
<code>GrowingBarChart(values:) / DrawingLineChart(values:)</code>
<details><summary>Usage</summary>

```swift
GrowingBarChart(values: weekly)
    .frame(height: 120)

DrawingLineChart(values: trend, color: .pink)
    .frame(height: 120)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/needle-gauge.gif" width="240" alt="Needle Gauge"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Number/NeedleGauge.swift"><b>Needle Gauge</b></a><br>
<sub>Value change</sub><br>
<code>NeedleGauge(value:)</code>
<details><summary>Usage</summary>

```swift
NeedleGauge(value: cpuLoad)
    .frame(width: 200, height: 200)
```

</details>
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
<code>ParticleField()</code>
<details><summary>Usage</summary>

```swift
ZStack {
    Color.black.ignoresSafeArea()
    ParticleField(count: 60, color: .cyan)
        .ignoresSafeArea()
    Text("Connected").font(.largeTitle.bold())
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/starfield.gif" width="240" alt="Starfield"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Starfield.swift"><b>Starfield</b></a><br>
<sub>Loop</sub><br>
<code>Starfield()</code>
<details><summary>Usage</summary>

```swift
Starfield()
    .background(.black)
    .ignoresSafeArea()

Starfield(count: 300, speed: 1.5) // warp jump
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/cover-flow.gif" width="240" alt="Cover Flow"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/CoverFlow.swift"><b>Cover Flow</b></a><br>
<sub>Scroll</sub><br>
<code>CoverFlow(items) { item in }</code>
<details><summary>Usage</summary>

```swift
CoverFlow(albums) { album in
    Image(album.artwork)
        .resizable()
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
}
.frame(height: 220)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/float-3d.gif" width="240" alt="Float 3D"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Float3D.swift"><b>Float 3D</b></a><br>
<sub>Loop</sub><br>
<code>.float3D()</code>
<details><summary>Usage</summary>

```swift
Image("product")
    .resizable()
    .scaledToFit()
    .frame(width: 180)
    .float3D()

BadgeView()
    .float3D(height: 6, angle: 8, period: 4, shadow: false)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/fireworks.gif" width="240" alt="Fireworks"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Fireworks.swift"><b>Fireworks</b></a><br>
<sub>Loop</sub><br>
<code>Fireworks()</code>
<details><summary>Usage</summary>

```swift
ZStack {
    Color.black.ignoresSafeArea()
    Fireworks()
        .ignoresSafeArea()
    Text("Happy New Year").font(.largeTitle.bold())
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/snowfall.gif" width="240" alt="Snowfall &amp; Rain"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Snowfall.swift"><b>Snowfall &amp; Rain</b></a><br>
<sub>Loop</sub><br>
<code>Snowfall(.snow / .rain)</code>
<details><summary>Usage</summary>

```swift
Snowfall()
    .background(.indigo)
    .ignoresSafeArea()

Snowfall(.rain, count: 150, color: .white.opacity(0.8))
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/floating-reactions.gif" width="240" alt="Floating Reactions"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/FloatingReactions.swift"><b>Floating Reactions</b></a><br>
<sub>Tap / Value change</sub><br>
<code>.floatingReactions(trigger:)</code>
<details><summary>Usage</summary>

```swift
LiveVideo()
    .floatingReactions(trigger: reactionCount)

Button("❤️") { reactionCount += 1 }
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/warp-tunnel.gif" width="240" alt="Warp Tunnel"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/WarpTunnel.swift"><b>Warp Tunnel</b></a><br>
<sub>Loop</sub><br>
<code>WarpTunnel()</code>
<details><summary>Usage</summary>

```swift
WarpTunnel()
    .background(.black)
    .ignoresSafeArea()

WarpTunnel(colors: [.green, .mint], sides: 6) // hexagons
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/holo-card.gif" width="240" alt="Holographic Card"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Holographic.swift"><b>Holographic Card</b></a><br>
<sub>Hover / Drag</sub><br>
<code>.holographic()</code>
<details><summary>Usage</summary>

```swift
Image("card-art")
    .resizable()
    .aspectRatio(5 / 7, contentMode: .fit)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .holographic(cornerRadius: 16)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/physics-emoji.gif" width="240" alt="Physics Emoji"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/PhysicsEmoji.swift"><b>Physics Emoji</b></a><br>
<sub>Value change / Tap</sub><br>
<code>PhysicsEmoji(trigger:)</code>
<details><summary>Usage</summary>

```swift
PhysicsEmoji(trigger: drops)
    .frame(height: 300)
    .onTapGesture { drops += 1 }
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shatter.gif" width="240" alt="Shatter"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Shatter.swift"><b>Shatter</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.shatter)</code>
<details><summary>Usage</summary>

```swift
if !isBroken {
    GlassPane()
        .transition(.shatter)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/cube.gif" width="240" alt="3D Cube"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/CubeTransition.swift"><b>3D Cube</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.cube)</code>
<details><summary>Usage</summary>

```swift
ZStack {
    PageView(page)
        .id(page)
        .transition(.cube)
}
.clipped()
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/dot-globe.gif" width="240" alt="Dot Globe"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/DotGlobe.swift"><b>Dot Globe</b></a><br>
<sub>Loop</sub><br>
<code>DotGlobe()</code>
<details><summary>Usage</summary>

```swift
DotGlobe(dots: 700, color: .cyan)
    .frame(width: 260, height: 260)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/bubbles.gif" width="240" alt="Bubbles"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Bubbles.swift"><b>Bubbles</b></a><br>
<sub>Loop</sub><br>
<code>Bubbles()</code>
<details><summary>Usage</summary>

```swift
Bubbles(count: 18)
    .background(LinearGradient(colors: [.blue.opacity(0.5), .indigo], startPoint: .top, endPoint: .bottom))
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/fireflies.gif" width="240" alt="Fireflies"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Particle/Fireflies.swift"><b>Fireflies</b></a><br>
<sub>Loop</sub><br>
<code>Fireflies()</code>
<details><summary>Usage</summary>

```swift
Fireflies(count: 24)
    .background(Color(red: 0.02, green: 0.06, blue: 0.05))
```

</details>
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
<details><summary>Usage</summary>

```swift
if showPhoto {
    PhotoView()
        .transition(.iris)
}

DetailView()
    .transition(.iris(origin: .topTrailing))
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/blinds.gif" width="240" alt="Blinds"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/MaskTransitions.swift"><b>Blinds</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.blinds)</code>
<details><summary>Usage</summary>

```swift
Banner()
    .transition(.blinds)

Poster()
    .transition(.blinds(slats: 12))
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/clock-wipe.gif" width="240" alt="Clock Wipe"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/MaskTransitions.swift"><b>Clock Wipe</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.clockWipe)</code>
<details><summary>Usage</summary>

```swift
Badge()
    .transition(.clockWipe)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/dissolve.gif" width="240" alt="Pixel Dissolve"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/MaskTransitions.swift"><b>Pixel Dissolve</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.dissolve)</code>
<details><summary>Usage</summary>

```swift
Avatar()
    .transition(.dissolve)

Artwork()
    .transition(.dissolve(cellSize: 6))
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/poof.gif" width="240" alt="Poof"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/StyleTransitions.swift"><b>Poof</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.poof)</code>
<details><summary>Usage</summary>

```swift
ForEach(notes) { note in
    NoteRow(note)
        .transition(.poof)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/swoosh.gif" width="240" alt="Swoosh"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/StyleTransitions.swift"><b>Swoosh</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.swoosh)</code>
<details><summary>Usage</summary>

```swift
if let toast {
    ToastView(toast)
        .transition(.swoosh)
}
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/film-exposure.gif" width="240" alt="Film Exposure"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/StyleTransitions.swift"><b>Film Exposure</b></a><br>
<sub>Appear</sub><br>
<code>.transition(.filmExposure)</code>
<details><summary>Usage</summary>

```swift
AsyncImage(url: url) { image in
    image.resizable()
        .transition(.filmExposure)
} placeholder: {
    ProgressView()
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/circular-reveal.gif" width="240" alt="Circular Reveal"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/CircularReveal.swift"><b>Circular Reveal</b></a><br>
<sub>Tap / Value change</sub><br>
<code>CircularReveal(value:origin:content:)</code>
<details><summary>Usage</summary>

```swift
CircularReveal(value: isDark, origin: tapPoint) { dark in
    ThemePreview(dark: dark)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/liquid-swipe.gif" width="240" alt="Liquid Swipe"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/LiquidSwipe.swift"><b>Liquid Swipe</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.liquidSwipe)</code>
<details><summary>Usage</summary>

```swift
ZStack {
    OnboardingPage(page)
        .id(page)
        .transition(.liquidSwipe)
}
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/page-turn.gif" width="240" alt="Page Turn"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/PageTurn.swift"><b>Page Turn</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.pageTurn)</code>
<details><summary>Usage</summary>

```swift
ZStack {
    ChapterView(chapter)
        .id(chapter)
        .transition(.pageTurn)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/glitch-transition.gif" width="240" alt="Glitch Transition"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/GlitchTransition.swift"><b>Glitch Transition</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.glitch)</code>
<details><summary>Usage</summary>

```swift
if showAlert {
    AlertBanner()
        .transition(.glitch)
}
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/origami.gif" width="240" alt="Origami Fold"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionLibrary/Transition/OrigamiFold.swift"><b>Origami Fold</b></a><br>
<sub>Value change</sub><br>
<code>.transition(.origami)</code>
<details><summary>Usage</summary>

```swift
if showTicket {
    TicketView()
        .transition(.origami)
}
```

</details>
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
<code>.waterRippleOnTap() / .waterRipple(at:trigger:)</code>
<details><summary>Usage</summary>

```swift
import MotionShaders

Image("pond")
    .waterRippleOnTap()

Card()
    .waterRipple(at: tapLocation, trigger: tapCount)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/pixellate.gif" width="240" alt="Pixellate"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/Pixellate.swift"><b>Pixellate</b></a><br>
<sub>Value change</sub><br>
<code>.pixellate(_:)</code>
<details><summary>Usage</summary>

```swift
import MotionShaders

Avatar()
    .pixellate(isHidden ? 18 : 1)
    .animation(.easeInOut, value: isHidden)
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/chromatic-aberration.gif" width="240" alt="Chromatic Aberration"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/ChromaticAberration.swift"><b>Chromatic Aberration</b></a><br>
<sub>Value change / Loop</sub><br>
<code>.chromaticAberration(_:)</code>
<details><summary>Usage</summary>

```swift
import MotionShaders

Text("BASS DROP")
    .font(.largeTitle.weight(.black))
    .chromaticAberration(isPlaying ? 6 : 0)
```

</details>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/crt.gif" width="240" alt="CRT Screen"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/CRT.swift"><b>CRT Screen</b></a><br>
<sub>Loop</sub><br>
<code>.crtScreen()</code>
<details><summary>Usage</summary>

```swift
import MotionShaders

GameView()
    .crtScreen()
    .clipShape(RoundedRectangle(cornerRadius: 24))
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/heat-haze.gif" width="240" alt="Heat Haze"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/HeatHaze.swift"><b>Heat Haze</b></a><br>
<sub>Loop</sub><br>
<code>.heatHaze(strength:)</code>
<details><summary>Usage</summary>

```swift
import MotionShaders

Image("desert-road")
    .heatHaze()
```

</details>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/noise-dissolve.gif" width="240" alt="Noise Dissolve"><br>
<a href="https://github.com/BigTsung/SwiftUI-Motion-Library/blob/main/Sources/MotionShaders/NoiseDissolve.swift"><b>Noise Dissolve</b></a><br>
<sub>Value change</sub><br>
<code>.noiseDissolve(_:) / .transition(.noiseDissolve)</code>
<details><summary>Usage</summary>

```swift
import MotionShaders

Card()
    .noiseDissolve(isDeleting ? 1 : 0)
    .animation(.easeIn(duration: 1), value: isDeleting)

if !isDeleted {
    NoteCard().transition(.noiseDissolve)
}
```

</details>
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
