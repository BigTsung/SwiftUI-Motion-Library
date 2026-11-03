# SwiftUI Motion Library

**A browsable collection of copy-paste SwiftUI motion effects, each with live preview, usage code and an AI prompt.**

Inspired by web motion galleries, built for SwiftUI developers who would rather drop in a polished effect than spend an afternoon tuning springs.

[繁體中文說明在下方 ↓](#繁體中文)

---

## Why

Web developers have huge motion galleries organised by *what* you animate and *when*. SwiftUI has great one-off repos and a few focused packages, but no single place to browse effects by **component × trigger**, try them, and take the code. This repo aims to be that place.

Every effect ships with:

- **A reusable API**: a `View`, `ViewModifier` or `ButtonStyle`, with no dependencies.
- **A live demo** in the bundled gallery.
- **Usage code** you can copy.
- **An AI prompt** that describes the look and the technique, so you can paste it into Claude, ChatGPT or Copilot to adapt it.

## Effects (v0.1)

<table>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/typewriter.gif" width="240" alt="Typewriter"><br>
<b>Typewriter</b><br>
<sub>Text · Appear / Change</sub><br>
<code>TypewriterText(&quot;…&quot;)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/scramble.gif" width="240" alt="Scramble / Decode"><br>
<b>Scramble / Decode</b><br>
<sub>Text · Appear / Change</sub><br>
<code>ScrambleText(&quot;…&quot;)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shimmer.gif" width="240" alt="Shimmer"><br>
<b>Shimmer</b><br>
<sub>Text · Loop</sub><br>
<code>.shimmer()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/pressable.gif" width="240" alt="Pressable"><br>
<b>Pressable</b><br>
<sub>Button · Press</sub><br>
<code>.buttonStyle(.pressable)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/ripple.gif" width="240" alt="Tap Ripple"><br>
<b>Tap Ripple</b><br>
<sub>Button · Tap</sub><br>
<code>.ripple()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/shake.gif" width="240" alt="Error Shake"><br>
<b>Error Shake</b><br>
<sub>Button · Value change</sub><br>
<code>.shake(trigger:)</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/staggered-appear.gif" width="240" alt="Staggered Entrance"><br>
<b>Staggered Entrance</b><br>
<sub>Card & Group · Appear</sub><br>
<code>.staggeredAppear(index:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/tilt.gif" width="240" alt="3D Tilt"><br>
<b>3D Tilt</b><br>
<sub>Card & Group · Drag</sub><br>
<code>.tiltOnDrag()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/scroll-reveal.gif" width="240" alt="Scroll Reveal"><br>
<b>Scroll Reveal</b><br>
<sub>Card & Group · Scroll</sub><br>
<code>.scrollReveal()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/pulse-rings.gif" width="240" alt="Pulse Rings"><br>
<b>Pulse Rings</b><br>
<sub>Shape · Loop</sub><br>
<code>PulseRings()</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/burst.gif" width="240" alt="Like Burst"><br>
<b>Like Burst</b><br>
<sub>Shape · Tap / Change</sub><br>
<code>.burst(trigger:)</code>
</td>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/aurora.gif" width="240" alt="Aurora"><br>
<b>Aurora</b><br>
<sub>Background · Loop</sub><br>
<code>AuroraBackground()</code>
</td>
</tr>
<tr>
<td align="center" valign="top" width="33%">
<img src="Docs/gifs/rolling-number.gif" width="240" alt="Rolling Number"><br>
<b>Rolling Number</b><br>
<sub>Number · Value change</sub><br>
<code>RollingNumber(value:)</code>
</td>
</tr>
</table>

The previews are recorded from the gallery demos with `Scripts/record-readme-gifs.sh` (macOS, needs ffmpeg). Run it again after changing an effect.

## Requirements

iOS 17+, macOS 14+, visionOS 1+, Xcode 15+.

## Installation

Swift Package Manager: **File → Add Package Dependencies…** and enter this repository's URL, or:

```swift
.package(url: "https://github.com/<you>/SwiftUI-Motion-Library", from: "0.1.0")
```

```swift
.product(name: "MotionLibrary", package: "SwiftUI-Motion-Library"),   // the effects
.product(name: "MotionGallery", package: "SwiftUI-Motion-Library"),   // optional browser UI
```

## Quick start

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

## Browse the gallery

- **Fastest:** open `Package.swift` in Xcode, open `Sources/MotionGallery/Views/MotionGalleryView.swift` and use the canvas preview. Every effect file also has its own `#Preview`.
- **In an app:** add the `MotionGallery` product and show `MotionGalleryView()`.

The gallery lets you filter by component and trigger, play with each effect, replay it, and copy the usage code or AI prompt.

## Project layout

```
Sources/
  MotionLibrary/          # the effects (public API, zero dependencies)
    Text/  Button/  Card/  Shape/  Background/  Number/
  MotionGallery/          # catalog metadata + browser UI
    Model/MotionEffect.swift
    Catalog/MotionCatalog.swift   # one entry per effect
    Catalog/Demos.swift           # demo views
    Views/
```

## Contributing

New effects are very welcome. See [CONTRIBUTING.md](CONTRIBUTING.md). Each effect is one source file, one demo view and one catalog entry.

## License

MIT. Use it in commercial apps, no attribution required (but appreciated ⭐).

---

## 繁體中文

**SwiftUI 動態效果收藏庫：每個效果都可以即時預覽、複製程式碼，也附 AI 提示詞。**

網頁前端有很完整的動態效果收藏站，可以用「元件 × 時機」篩選、試玩、複製。SwiftUI 這邊雖然有不少零散的範例 repo，但一直沒有這樣一個集中的地方。這個專案想補上這個空缺，讓 Swift 開發者不用每次都從零開始調 spring 參數。

每個效果都包含：

- **可重用的 API**：`View`、`ViewModifier` 或 `ButtonStyle`，沒有任何外部依賴
- **Gallery 即時預覽**：可以直接操作、重播
- **用法程式碼**：一鍵複製
- **AI 提示詞**：描述外觀和實作手法，貼給 AI 就能改出自己的版本

### 效果預覽

每個效果的 GIF 動圖請看上方的 [Effects](#effects-v01) 表格。

### 安裝

Xcode：**File → Add Package Dependencies…**，貼上本 repo 網址，加入 `MotionLibrary`（效果本體）；`MotionGallery`（瀏覽介面）可以不裝。

### 瀏覽效果

用 Xcode 打開 `Package.swift`，開啟 `MotionGalleryView.swift`，在 Canvas 預覽就能看到全部效果。也可以在自己的 App 裡顯示 `MotionGalleryView()`。

### 分類方式

- **元件**：文字、按鈕、卡片與群組、圖形、背景、數字
- **時機**：進場、點擊、按壓、拖曳、捲動、數值改變、循環

### 貢獻

歡迎新增效果！流程請看 [CONTRIBUTING.md](CONTRIBUTING.md)：一個效果 = 一個原始碼檔案 + 一個 Demo + 一筆目錄資料。
