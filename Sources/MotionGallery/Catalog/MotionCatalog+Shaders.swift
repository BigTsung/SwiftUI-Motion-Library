import SwiftUI
import MotionShaders

// Metal shader effects from the optional `MotionShaders` product. Their
// `sourceFile` is relative to `Sources/`, and each has a matching
// `Sources/MotionShaders/Shaders/<Name>.metal`.

extension MotionCatalog {
    static let shader: [MotionEffect] = [
        MotionEffect(
            id: "water-ripple",
            name: "Water Ripple",
            summary: "A real ripple distorts the view's pixels outward from a tap.",
            component: .shader,
            triggers: [.tap, .change],
            sourceFile: "MotionShaders/WaterRipple.swift",
            api: ".waterRippleOnTap() / .waterRipple(at:trigger:)",
            usage: #"""
            import MotionShaders

            Image("pond")
                .waterRippleOnTap()

            Card()
                .waterRipple(at: tapLocation, trigger: tapCount)
            """#,
            prompt: #"""
            Create a SwiftUI .waterRipple(at:trigger:amplitude:duration:) view modifier (iOS 17+) using a Metal [[stitchable]] layer shader. The shader takes (float2 position, SwiftUI::Layer layer, float2 origin, float time, float amplitude, float frequency, float decay, float speed): distance = length(position − origin), local = max(0, time − distance / speed), wave = amplitude × sin(frequency × local) × exp(−decay × local); sample the layer at position + wave × normalize(position − origin) and add 0.25 × wave / amplitude to rgb (times alpha) so crests brighten. In Swift, run keyframeAnimator(initialValue: 0, trigger:) with MoveKeyframe(0) and a LinearKeyframe to duration (3 s) over duration, and apply .visualEffect { $0.layerEffect(ShaderLibrary.motionRipple(.float2(origin), .float(elapsed), .float(12), .float(15), .float(8), .float(1200)), maxSampleOffset: CGSize(width: 12, height: 12), isEnabled: 0 < elapsed < duration) }. Add .waterRippleOnTap() that records a SpatialTapGesture location (as a simultaneous gesture) and bumps the trigger. With Reduce Motion on, disable the effect.
            """#
        ) { WaterRippleDemo() },

        MotionEffect(
            id: "pixellate",
            name: "Pixellate",
            summary: "The view melts into a mosaic of square blocks and back.",
            component: .shader,
            triggers: [.change],
            sourceFile: "MotionShaders/Pixellate.swift",
            api: ".pixellate(_:)",
            usage: #"""
            import MotionShaders

            Avatar()
                .pixellate(isHidden ? 18 : 1)
                .animation(.easeInOut, value: isHidden)
            """#,
            prompt: #"""
            Create a SwiftUI .pixellate(_ size:) view modifier (iOS 17+) as an Animatable ViewModifier over size, so withAnimation interpolates the block size. It applies .layerEffect(ShaderLibrary.motionPixellate(.float(size)), maxSampleOffset: CGSize(width: size, height: size), isEnabled: size > 1). The Metal [[stitchable]] shader (float2 position, SwiftUI::Layer layer, float size) returns layer.sample(position) when size ≤ 1, otherwise layer.sample((floor(position / size) + 0.5) × size), one colour per block.
            """#
        ) { PixellateDemo() },

        MotionEffect(
            id: "chromatic-aberration",
            name: "Chromatic Aberration",
            summary: "Red and blue split sideways like a cheap lens; animate it on a beat.",
            component: .shader,
            triggers: [.change, .loop],
            sourceFile: "MotionShaders/ChromaticAberration.swift",
            api: ".chromaticAberration(_:)",
            usage: #"""
            import MotionShaders

            Text("BASS DROP")
                .font(.largeTitle.weight(.black))
                .chromaticAberration(isPlaying ? 6 : 0)
            """#,
            prompt: #"""
            Create a SwiftUI .chromaticAberration(_ amount:) view modifier (iOS 17+) as an Animatable ViewModifier over amount, applying .layerEffect(ShaderLibrary.motionChromatic(.float(amount)), maxSampleOffset: CGSize(width: |amount|, height: 0), isEnabled: |amount| > 0.01). The Metal [[stitchable]] shader (float2 position, SwiftUI::Layer layer, float amount) samples red at position + (amount, 0), green at position and blue at position − (amount, 0), with alpha = the max of the three samples' alpha. For a beat, spike amount to 7 pt with withAnimation(.easeOut(duration: 0.12)) and, in its completion, ease back to 1.5 over 0.5 s.
            """#
        ) { ChromaticDemo() },

        MotionEffect(
            id: "crt",
            name: "CRT Screen",
            summary: "Curved glass, scanlines, a rolling band and flicker, like an old monitor.",
            component: .shader,
            triggers: [.loop],
            sourceFile: "MotionShaders/CRT.swift",
            api: ".crtScreen()",
            usage: #"""
            import MotionShaders

            GameView()
                .crtScreen()
                .clipShape(RoundedRectangle(cornerRadius: 24))
            """#,
            prompt: #"""
            Create a SwiftUI .crtScreen(curvature:) view modifier (iOS 17+). Inside TimelineView(.animation), apply .visualEffect { $0.layerEffect(ShaderLibrary.motionCRT(.float2(proxy.size), .float(time), .float(curvature)), maxSampleOffset: size × curvature) } with curvature 0.06. The Metal [[stitchable]] shader (position, SwiftUI::Layer layer, float2 size, float time, float curvature): map to centred uv in −1…1, barrel-distort with uv × (1 + curvature × dot(uv, uv)), return black outside 0…1; sample red at +0.8 pt and blue at −0.8 pt for fringing; multiply by scanlines 0.8 + 0.2 sin(y × π × 0.66), a rolling band 1 + 0.08 × smoothstep(0.92, 1, sin(uv.y × 3 − time × 1.5)), a vignette smoothstep(1.25, 0.4, length(centred)) and a flicker 0.97 + 0.03 sin(time × 60). With Reduce Motion on, pause the timeline at time 0.
            """#
        ) { CRTDemo() },

        MotionEffect(
            id: "heat-haze",
            name: "Heat Haze",
            summary: "The view shimmers like hot air over a desert road.",
            component: .shader,
            triggers: [.loop],
            sourceFile: "MotionShaders/HeatHaze.swift",
            api: ".heatHaze(strength:)",
            usage: #"""
            import MotionShaders

            Image("desert-road")
                .heatHaze()
            """#,
            prompt: #"""
            Create a SwiftUI .heatHaze(strength:) view modifier (iOS 17+). Inside TimelineView(.animation), apply .visualEffect { $0.distortionEffect(ShaderLibrary.motionHeatHaze(.float2(proxy.size), .float(time), .float(strength)), maxSampleOffset: CGSize(width: strength, height: strength)) } with strength 6 pt. The Metal [[stitchable]] distortion shader (float2 position, float2 size, float time, float strength) uses smooth value noise: rise = y × 0.05 + time × 2, n = noise(x × 0.04, rise) − 0.5, m = noise(x × 0.09 + 10, rise × 1.7) − 0.5, weight = 0.35 + 0.65 × y / height (stronger at the bottom), and returns position + ((n + 0.5m) × strength × weight, n × strength × 0.3 × weight). With Reduce Motion on, use strength 0.
            """#
        ) { HeatHazeDemo() },

        MotionEffect(
            id: "noise-dissolve",
            name: "Noise Dissolve",
            summary: "The view burns away in organic blotches with a glowing edge.",
            component: .shader,
            triggers: [.change],
            sourceFile: "MotionShaders/NoiseDissolve.swift",
            api: ".noiseDissolve(_:) / .transition(.noiseDissolve)",
            usage: #"""
            import MotionShaders

            Card()
                .noiseDissolve(isDeleting ? 1 : 0)
                .animation(.easeIn(duration: 1), value: isDeleting)

            if !isDeleted {
                NoteCard().transition(.noiseDissolve)
            }
            """#,
            prompt: #"""
            Create a SwiftUI .noiseDissolve(_ progress:scale:edge:) view modifier (iOS 17+) as an Animatable ViewModifier over progress, applying .colorEffect(ShaderLibrary.motionDissolve(.float(progress), .float(scale), .color(edge)), isEnabled: progress > 0) with scale 18 pt and an orange edge, plus a NoiseDissolveTransition (.noiseDissolve) that uses progress 1 when not identity. The Metal [[stitchable]] colour shader (float2 position, half4 color, float progress, float scale, half4 edge): n = 0.7 × noise(position / scale) + 0.3 × noise(position / (0.35 × scale)) using smooth value noise; threshold = progress × 1.1 − 0.05; return transparent where n < threshold, and mix towards edge × alpha by 1 − smoothstep(threshold, threshold + 0.06, n) so a thin band glows just before it burns. With Reduce Motion on, the transition fades instead.
            """#
        ) { NoiseDissolveDemo() },
    ]
}
