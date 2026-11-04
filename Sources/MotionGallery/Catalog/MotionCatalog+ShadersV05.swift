import SwiftUI
import MotionShaders

// Shader effects added in v0.5, from the optional `MotionShaders` product.

extension MotionCatalog {
    static let shaderV05: [MotionEffect] = [
        MotionEffect(
            id: "disintegrate",
            name: "Disintegrate",
            summary: "The view crumbles into grains of sand that blow away on the wind.",
            component: .shader,
            triggers: [.change],
            sourceFile: "MotionShaders/Disintegrate.swift",
            api: ".disintegrate(_:) / .transition(.disintegrate)",
            usage: #"""
            import MotionShaders

            Avatar()
                .disintegrate(isGone ? 1 : 0)
                .animation(.easeIn(duration: 1.6), value: isGone)

            if !isDeleted {
                MessageRow().transition(.disintegrate)
            }
            """#,
            prompt: #"""
            Create a SwiftUI .disintegrate(_ progress:wind:grain:) view modifier and matching Transition (iOS 17+) using a Metal [[stitchable]] layer shader with (position, layer, float2 size, float progress, float grain, float2 wind). Split the view into grain-sized cells (2 pt) with two hashes n, n2 per cell. along = dot(position / size, normalize(wind)) × 0.5 + 0.5; delay = (1 − along) × 0.55 + 0.3n; local = clamp((1.4 × progress − delay) / 0.5, 0, 1). If local is 0, return the layer unchanged; if n2 < 1.15 × local, return clear (the grain is gone); otherwise sample the layer at position − (wind × local² + (sin 40n, cos 31n) × local × 6 × grain) and multiply by 1 − local. Apply it through .visualEffect so the shader gets the size, with maxSampleOffset |wind| + 6 × grain, in an Animatable modifier on progress. The transition maps identity to 0 and removal/insertion to 1 (default wind (140, −60)); with Reduce Motion on it fades instead.
            """#
        ) { DisintegrateDemo() },

        MotionEffect(
            id: "genie",
            name: "Genie",
            summary: "The view pinches and pours into a point below it, like minimising a window.",
            component: .shader,
            triggers: [.change],
            sourceFile: "MotionShaders/Genie.swift",
            api: ".genie(_:toward:) / .transition(.genie)",
            usage: #"""
            import MotionShaders

            Panel()
                .genie(isMinimised ? 1 : 0, toward: 0.8)
                .animation(.easeInOut(duration: 0.7), value: isMinimised)
            """#,
            prompt: #"""
            Create a SwiftUI .genie(_ progress:toward:) view modifier and matching Transition (iOS 17+) using a Metal [[stitchable]] distortion shader (position, float2 size, float progress, float target) that returns where to sample. pinch = clamp(2p, 0, 1), slide = clamp(2p − 1, 0, 1). Return an off-view point below the bottom edge (that part has gone into the target, and maxSampleOffset widens the drawn area). y = position.y − slide × height (return an off-view point if y < 0). bend = smoothstep(0, 1, clamp(y / height + slide, 0, 1)) and squeeze = pinch × bend; the row's edges move from 0 and width towards target × width ∓ 3 pt by squeeze. Return off-view for x outside them, else x = (position.x − left) / (right − left) × width. So the bottom first pinches towards the target in an S-curve, then the whole shape slides down into it. Apply through .visualEffect for the size, maxSampleOffset = size, in an Animatable modifier on progress. The transition defaults to the middle of the bottom edge; with Reduce Motion on it fades instead.
            """#
        ) { GenieDemo() },

        MotionEffect(
            id: "glass-lens",
            name: "Glass Lens",
            summary: "A round glass lens magnifies what's under it, bending light at its rim.",
            component: .shader,
            triggers: [.drag, .hover],
            sourceFile: "MotionShaders/GlassLens.swift",
            api: ".glassLensOnDrag() / .glassLens(at:)",
            usage: #"""
            import MotionShaders

            ArticleView()
                .glassLensOnDrag(radius: 60)
            """#,
            prompt: #"""
            Create SwiftUI .glassLens(at:radius:magnification:) and .glassLensOnDrag() view modifiers (iOS 17+) using a Metal [[stitchable]] layer shader (position, layer, float2 centre, float radius, float magnification). u = distance from centre / radius. Outside (u ≥ 1), darken the layer by up to 22 % in a soft ring that fades out by u = 1.12. Inside, sample at centre + offset × scale with scale = mix(1 / magnification, 1, u³), so the middle is magnified (1.8×) and the rim isn't; sample red at scale + 0.035u⁴ and blue at scale − 0.035u⁴ for colour fringing. Brighten towards white by a rim term smoothstep(0.86, 1, u) × 0.35 plus a specular spot centred at (−0.38, −0.42) × radius that fades over 0.32 × radius. maxSampleOffset = radius. The drag version follows a DragGesture(minimumDistance: 0) and the hover location, starting in the middle.
            """#
        ) { GlassLensDemo() },

        MotionEffect(
            id: "swirl",
            name: "Swirl",
            summary: "The view twists around a point like water going down a drain.",
            component: .shader,
            triggers: [.drag, .change],
            sourceFile: "MotionShaders/Swirl.swift",
            api: ".swirlOnDrag() / .swirl(at:strength:)",
            usage: #"""
            import MotionShaders

            Image("galaxy")
                .swirlOnDrag()

            Logo()
                .swirl(at: centre, strength: isStirred ? 4 : 0)
                .animation(.spring(duration: 1), value: isStirred)
            """#,
            prompt: #"""
            Create SwiftUI .swirl(at:radius:strength:) and .swirlOnDrag(radius:strength:) view modifiers (iOS 17+) using a Metal [[stitchable]] distortion shader (position, float2 centre, float radius, float strength): within radius (110 pt), rotate the offset from the centre by strength × t² where t = 1 − distance / radius, so it twists most at the centre and not at all at the edge; outside, return the position unchanged. Animate strength in an Animatable modifier, maxSampleOffset = radius. The drag version moves the centre to the finger and sets strength to 4 × min(1, 0.35 + travel / 160) with an interactive spring, then springs back to 0 with .spring(duration: 0.8, bounce: 0.45) on release. With Reduce Motion on, the drag doesn't twist.
            """#
        ) { SwirlDemo() },

        MotionEffect(
            id: "kaleidoscope",
            name: "Kaleidoscope",
            summary: "One wedge of the view mirrored round the centre, turning into new patterns.",
            component: .shader,
            triggers: [.loop, .change],
            sourceFile: "MotionShaders/Kaleidoscope.swift",
            api: ".kaleidoscope(segments:)",
            usage: #"""
            import MotionShaders

            Image("flowers")
                .kaleidoscope(segments: 8)
                .clipShape(Circle())
            """#,
            prompt: #"""
            Create a SwiftUI .kaleidoscope(segments:rotation:spins:) view modifier (iOS 17+) using a Metal [[stitchable]] layer shader (position, layer, float2 size, float segments, float rotation). Around the centre, take the polar angle modulo the wedge 2π / segments and mirror the second half of each wedge (a > wedge / 2 → wedge − a), add rotation, and sample at centre + r' × (cos a, sin a), where r' folds the radius back into the view (reach − |r mod 2 reach − reach|, reach = half the shorter side) so the corners aren't empty. Pass the size through .visualEffect with maxSampleOffset = size, in an Animatable modifier on rotation. When spins is on, add time × 0.25 rad from TimelineView(.animation) so the pattern keeps blooming. With Reduce Motion on, don't spin.
            """#
        ) { KaleidoscopeDemo() },

        MotionEffect(
            id: "halftone",
            name: "Halftone",
            summary: "The view is printed in round dots, bigger where it's darker, like newsprint.",
            component: .shader,
            triggers: [.change],
            sourceFile: "MotionShaders/Halftone.swift",
            api: ".halftone(dotSize:)",
            usage: #"""
            import MotionShaders

            Image("portrait")
                .halftone(dotSize: isPrinted ? 8 : 1)
                .animation(.easeInOut, value: isPrinted)
            """#,
            prompt: #"""
            Create a SwiftUI .halftone(dotSize:angle:paper:) view modifier (iOS 17+) using a Metal [[stitchable]] layer shader (position, layer, float dotSize, float angle, half4 paper). Rotate the position into a grid at angle (45°), find the centre of its dotSize cell (8 pt), rotate that back and sample the layer there for the dot's colour. Un-premultiply, take luminance L, coverage = (1 − 0.85L) × alpha, dot radius = √coverage × 0.72 × dotSize, and draw the dot with a 0.8 pt smoothstep edge over the paper colour, keeping the alpha of the layer at the pixel so transparent areas stay transparent. Animate dotSize in an Animatable modifier and disable the effect below 1.5 pt, so animating from 1 brings the dots in. maxSampleOffset = dotSize.
            """#
        ) { HalftoneDemo() },

        MotionEffect(
            id: "dither",
            name: "Dither",
            summary: "Chunky pixels in a few flat colours with a Bayer cross-hatch, like a retro handheld.",
            component: .shader,
            triggers: [.change],
            sourceFile: "MotionShaders/Dither.swift",
            api: ".dither(pixelSize:palette:)",
            usage: #"""
            import MotionShaders

            GameScene()
                .dither(pixelSize: 3)                             // four greens
            Avatar()
                .dither(pixelSize: 2, palette: DitherPalette.mono) // 1-bit
            """#,
            prompt: #"""
            Create a SwiftUI .dither(pixelSize:palette:) view modifier (iOS 17+) using a Metal [[stitchable]] layer shader (position, layer, float pixelSize, device const half4 *palette, int count). Sample the layer at the centre of the position's pixelSize block (3 pt), un-premultiply, take luminance, and add a 4 × 4 Bayer threshold ((bayer[i] + 0.5) / 16 − 0.5) / (levels − 1) indexed by the block coordinates mod 4. Round to the nearest of the palette's colours (darkest first) and return it premultiplied by the sample's alpha. Pass the palette with .colorArray. Ship palettes: four greens like an early handheld (0.06, 0.22, 0.06) … (0.61, 0.74, 0.06), mono black/white, and sepia. Animate pixelSize in an Animatable modifier; maxSampleOffset = pixelSize.
            """#
        ) { DitherDemo() },

        MotionEffect(
            id: "thermal",
            name: "Thermal Vision",
            summary: "Brightness turns into heat colours, from cold indigo to white hot.",
            component: .shader,
            triggers: [.change],
            sourceFile: "MotionShaders/Thermal.swift",
            api: ".thermal(_:)",
            usage: #"""
            import MotionShaders

            CameraFeed()
                .thermal(isScanning ? 1 : 0)
                .animation(.easeInOut(duration: 0.6), value: isScanning)
            """#,
            prompt: #"""
            Create a SwiftUI .thermal(_ intensity:) view modifier (iOS 17+) using a Metal [[stitchable]] colour shader (position, half4 colour, float intensity). Un-premultiply, take luminance as heat, and map it through seven evenly spaced stops: (0, 0, 0.05), (0.2, 0.05, 0.45), (0.65, 0.05, 0.6), (0.95, 0.15, 0.2), (1, 0.5, 0), (1, 0.9, 0.2), (1, 1, 1), interpolating linearly. Mix the original colour with the heat colour by intensity and premultiply again. Animate intensity in an Animatable modifier and disable the effect at 0, so the view can switch into heat vision.
            """#
        ) { ThermalDemo() },

        MotionEffect(
            id: "flag-wave",
            name: "Flag Wave",
            summary: "The view ripples like a flag on a pole, its folds catching the light.",
            component: .shader,
            triggers: [.loop],
            sourceFile: "MotionShaders/FlagWave.swift",
            api: ".flagWave()",
            usage: #"""
            import MotionShaders

            Image("banner")
                .flagWave(amplitude: 10)
            """#,
            prompt: #"""
            Create a SwiftUI .flagWave(amplitude:wavelength:speed:) view modifier (iOS 17+) using a Metal [[stitchable]] layer shader (position, layer, float2 size, float time, float amplitude, float wavelength). reach = x / width (0 at the pole on the leading edge, 1 at the free end); phase = x / wavelength × 2π − 4 × time; wave = sin(phase) + 0.35 sin(2.3 phase + 1.1). Sample at (x + 0.25 × amplitude × reach × cos(phase), y − amplitude × reach × wave) and multiply the colour by 1 + 0.18 × reach × (cos(phase) + 0.8 cos(2.3 phase + 1.1)) so slopes catch light and shade, clamped to alpha. Drive time from TimelineView(.animation), pad the view vertically by 1.4 × amplitude (and take it back with negative padding) so the ripples have room, and apply through .visualEffect for the size. With Reduce Motion on, leave the view still.
            """#
        ) { FlagWaveDemo() },

        MotionEffect(
            id: "voronoi",
            name: "Voronoi Cells",
            summary: "Slowly drifting cells like stained glass, with soft seams between them.",
            component: .shader,
            triggers: [.loop],
            sourceFile: "MotionShaders/Voronoi.swift",
            api: "VoronoiCells(colors:)",
            usage: #"""
            import MotionShaders

            VoronoiCells(colors: [.indigo, .purple, .pink, .orange, .teal])
                .ignoresSafeArea()
            """#,
            prompt: #"""
            Create a SwiftUI VoronoiCells(colors:cellSize:speed:) view (iOS 17+): a Rectangle with a Metal [[stitchable]] colour shader (position, colour, float time, float scale, device const half4 *palette, int count) driven by TimelineView(.animation). Work in cells of scale (60 pt); for the 3 × 3 neighbouring cells, the seed is cell + 0.5 + 0.4 × sin(time + 2π × hash2(cell)), so seeds drift. Track the nearest and second-nearest distances; colour the pixel with palette[hash(nearest cell) × count], darkened by smoothstep(0, 0.08, second − nearest) for soft seams and by 1 − 0.35 × nearest for a gentle glow at each seed. Pass the colours with .colorArray. With Reduce Motion on, pause the timeline. Hide it from accessibility.
            """#
        ) { VoronoiDemo() },
    ]
}
