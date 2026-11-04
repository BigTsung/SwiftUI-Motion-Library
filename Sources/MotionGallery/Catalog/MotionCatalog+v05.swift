import SwiftUI
import MotionLibrary

// Catalog entries added in v0.5, appended to each component's list in
// `MotionCatalog.all`. The shader entries are in MotionCatalog+ShadersV05.swift.

extension MotionCatalog {

    // MARK: - Text

    static let textV05: [MotionEffect] = [
        MotionEffect(
            id: "liquid-fill-text",
            name: "Liquid Fill Text",
            summary: "A wavy water line rises inside the letters as progress grows.",
            component: .text,
            triggers: [.change, .loop],
            sourceFile: "Text/LiquidFillText.swift",
            api: "LiquidFillText(_:progress:)",
            usage: #"""
            LiquidFillText("\(Int(level * 100))%", progress: level, color: .cyan)
                .font(.system(size: 64, weight: .black, design: .rounded))
            """#,
            prompt: #"""
            Create a SwiftUI LiquidFillText(_:progress:color:waveHeight:) view (iOS 17+). Draw the Text in the colour at 15 % opacity as an empty glass, then overlay a TimelineView(.animation) with a ZStack of two wave shapes, masked by the same Text: a back wave in the colour at 45 % (phase = time × 2.2 + 1.3, amplitude 0.8 × waveHeight) and a front wave in the full colour (phase = time × 3, amplitude waveHeight, default 6 pt). The wave Shape has level, phase and amplitude, animates level, and fills everything below y = baseline + amplitude × sin(x / width × 3π + phase). A line of text has descender room below the glyphs and space above the caps, so fill between bottom = maxY − 0.2 × height + 2 × amplitude and top = minY + 0.12 × height − 2 × amplitude: baseline = bottom − (bottom − top) × level, so 0 is empty and 1 full. Clamp progress to 0…1 and animate level changes with .spring(duration: 0.9, bounce: 0.25). With Reduce Motion on, pause the timeline (the level still animates). Hide the overlay from accessibility; the label is the text.
            """#
        ) { LiquidFillDemo() },
    ]

    // MARK: - Button

    static let buttonV05: [MotionEffect] = [
        MotionEffect(
            id: "pull-cord",
            name: "Pull Cord",
            summary: "A lamp cord toggle: pull the knob down, it clicks and springs back swinging.",
            component: .button,
            triggers: [.drag, .tap],
            sourceFile: "Button/PullCord.swift",
            api: "PullCord(isOn:)",
            usage: #"""
            HStack(alignment: .top) {
                Image(systemName: lightsOn ? "lightbulb.max.fill" : "lightbulb")
                PullCord(isOn: $lightsOn)
            }
            """#,
            prompt: #"""
            Create a SwiftUI PullCord(isOn:length:color:) toggle (iOS 17+). A VStack(spacing: 0) of a 2 pt wide Rectangle (height length + stretch, default length 70) and a 16 × 26 Capsule knob, yellow with a yellow shadow (radius 8) when on. Rotate the whole cord with .rotationEffect(swing, anchor: .top) inside a 60 pt wide frame with room below to stretch. A DragGesture(minimumDistance: 0) sets stretch = 1.6c × (1 − e^(−pull / 1.6c)) with c = 0.45 × length (rubber-band resistance) and swing = −translation.width / 6 clamped to ±18°. On release, toggle when stretch passed c or the drag was a tap (moved < 4 pt), play a light haptic, then spring stretch back to 0 with .spring(duration: 0.55, bounce: 0.6) and swing back with .spring(duration: 0.9, bounce: 0.7). With Reduce Motion on, no swing and an ease-out return. Make it one accessibility element with the button trait, value On/Off and an action that toggles.
            """#
        ) { PullCordDemo() },
    ]

    // MARK: - Card & Group

    static let cardV05: [MotionEffect] = [
        MotionEffect(
            id: "island-pill",
            name: "Island Pill",
            summary: "A black pill springs open into a card and back, its contents blurring across.",
            component: .card,
            triggers: [.tap, .change],
            sourceFile: "Card/IslandPill.swift",
            api: "IslandPill(isExpanded:) { } expanded: { }",
            usage: #"""
            IslandPill(isExpanded: showsPlayer) {
                Image(systemName: "waveform")
            } expanded: {
                NowPlayingView()
            }
            .onTapGesture { showsPlayer.toggle() }
            """#,
            prompt: #"""
            Create a SwiftUI IslandPill(isExpanded:compactSize:expandedSize:color:compact:expanded:) view (iOS 17+): a black shape that morphs between a pill (default 126 × 37, corner radius half its height) and a card (default 340 × 160, corner radius min(44, height / 2)), using a continuous RoundedRectangle as background and clip shape. Inside, a ZStack holds both contents: the compact one fades out while blurring to 8 pt and scaling to 1.6; the expanded one fades in from blur 10 pt and scale 0.6 (anchored top). Force the dark colour scheme inside. Animate every change of isExpanded with .spring(duration: 0.5, bounce: 0.32). With Reduce Motion on, skip the blur and scale and use .easeInOut(duration: 0.25).
            """#
        ) { IslandPillDemo() },

        MotionEffect(
            id: "hover-lift",
            name: "Hover Lift",
            summary: "Cards rise, grow and lean towards the pointer on iPad and Mac.",
            component: .card,
            triggers: [.hover],
            sourceFile: "Card/HoverLift.swift",
            api: ".hoverLift(isActive:)",
            usage: #"""
            LazyVGrid(columns: columns) {
                ForEach(projects) { project in
                    ProjectCard(project)
                        .hoverLift()
                }
            }
            """#,
            prompt: #"""
            Create a SwiftUI .hoverLift(scale:tilt:cornerRadius:) view modifier (iOS 17+) for pointer hover on iPad and Mac. Track the pointer with .onContinuousHover(coordinateSpace: .local) and the view size with a background GeometryReader. While hovered, scale to 1.05, offset y −4 and deepen the shadow (black 22 %, radius 18, y 12; at rest 8 %, radius 6, y 3), all with .spring(duration: 0.35, bounce: 0.3). Lean towards the pointer: with lean = location / size × 2 − 1, apply rotation3DEffect(tilt × lean.x around y) and (−tilt × lean.y around x), tilt 6°, perspective 0.6, animated with .interactiveSpring(duration: 0.25). With Reduce Motion on, don't move or scale; brighten by 0.05 instead. Add isActive (default false) to lift the view without a pointer too, for the focused or selected card. On visionOS, where apps can't see the gaze, use .contentShape(.hoverEffect, RoundedRectangle(cornerRadius:)) and the system .hoverEffect().
            """#
        ) { HoverLiftDemo() },

        MotionEffect(
            id: "marquee-wall",
            name: "Marquee Wall",
            summary: "A tilted wall of cards, columns scrolling endlessly up and down.",
            component: .card,
            triggers: [.loop],
            sourceFile: "Card/MarqueeWall.swift",
            api: "MarqueeWall(count:) { index in }",
            usage: #"""
            MarqueeWall(count: shots.count, columns: 4) { index in
                Image(shots[index]).resizable().scaledToFill()
            }
            .frame(height: 320)
            .clipped()
            """#,
            prompt: #"""
            Create a SwiftUI MarqueeWall(count:columns:itemSize:spacing:speed:angle:content:) view (iOS 17+), the scrolling showcase wall from landing pages. Each of the columns (default 4) shows perColumn = max(3, ceil(count / columns)) items twice in a VStack, cards of itemSize (110 × 140) with 14 pt continuous corners and 12 pt spacing, so the loop height is perColumn × (height + spacing). In TimelineView(.animation), distance = (time × speed × (1 + 0.15 × (column % 3))) mod loopHeight (24 pt/s × speed, a multiplier defaulting to 1); even columns offset by −distance (moving up), odd ones by distance − loopHeight (moving down). Lay the columns in an HStack, rotate the whole thing by −14° and let the caller clip it. Disable hit testing. With Reduce Motion on, pause the timeline.
            """#
        ) { MarqueeWallDemo() },

        MotionEffect(
            id: "photo-develop",
            name: "Photo Develop",
            summary: "The view develops like an instant photo, from murky dark to full colour.",
            component: .card,
            triggers: [.appear, .change],
            sourceFile: "Card/PhotoDevelop.swift",
            api: ".photoDevelop()",
            usage: #"""
            Image("snapshot")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .photoDevelop(trigger: shotCount)
            """#,
            prompt: #"""
            Create a SwiftUI .photoDevelop(trigger:duration:) view modifier (iOS 17+) that develops the view like an instant photo on appear and whenever trigger changes. Reset progress to 0 without animation, then animate it to 1 with .easeOut(duration: 3.5). Apply the look in an Animatable modifier so each quality keeps its own pace: light = min(1, 1.6p), colour = max(0, (p − 0.25) / 0.75), focus = min(1, 1.3p); .saturation(colour), .contrast(0.55 + 0.45 × light), .brightness(−0.45 × (1 − light)), .blur(radius: 5 × (1 − focus)), and an overlay LinearGradient from blue-grey (0.2, 0.25, 0.35) to brown (0.35, 0.25, 0.18) with opacity 0.75 × (1 − colour) and .blendMode(.multiply). With Reduce Motion on, develop over 0.4 s.
            """#
        ) { PhotoDevelopDemo() },
    ]

    // MARK: - Background

    static let backgroundV05: [MotionEffect] = [
        MotionEffect(
            id: "network",
            name: "Network",
            summary: "Drifting points link up with lines when close, and gather at your finger.",
            component: .background,
            triggers: [.loop, .hover, .drag],
            sourceFile: "Background/NetworkBackground.swift",
            api: "NetworkBackground()",
            usage: #"""
            NetworkBackground(color: .cyan)
                .background(.black)
                .ignoresSafeArea()
            """#,
            prompt: #"""
            Create a SwiftUI NetworkBackground(count:linkDistance:color:isInteractive:) view (iOS 17+): a plexus of drifting points. In TimelineView(.animation) + Canvas, point i starts at a hashed position, moves at 6–20 pt/s in a hashed direction, and wraps around the edges with 20 pt of slack. Join every pair closer than linkDistance (70 pt) with a line of opacity 0.55 × (1 − d / linkDistance) and width 0.6 + 0.6 × that strength, then draw each point as a 3.6 pt dot. Track the pointer with onContinuousHover and a DragGesture(minimumDistance: 0); points within 110 pt are pulled towards it by (1 − d / 110) × 0.45 of the gap, so the web gathers under the finger. With Reduce Motion on, pause the timeline. Hide it from accessibility.
            """#
        ) { NetworkDemo() },

        MotionEffect(
            id: "topographic",
            name: "Topographic Lines",
            summary: "Contour lines of a shifting landscape flow like a living map.",
            component: .background,
            triggers: [.loop],
            sourceFile: "Background/TopographicLines.swift",
            api: "TopographicLines()",
            usage: #"""
            TopographicLines(color: .green)
                .background(Color(white: 0.06))
            """#,
            prompt: #"""
            Create a SwiftUI TopographicLines(levels:scale:color:speed:) view (iOS 17+). In TimelineView(.animation(minimumInterval: 1/30)) + Canvas, sample a height field on an 8 pt grid: h = 0.65 × noise(x + t, y − 0.6t) + 0.35 × noise(2.1x − 0.8t, 2.1y + 7), with x, y in units of scale (90 pt), t = time × 0.12 × speed (a multiplier defaulting to 1), and noise a smoothstep-interpolated value noise from an integer hash. For each of levels (14) thresholds spread over 0.18…0.82, trace the contour with marching squares (16 cases, edge crossings linearly interpolated, saddles drawn as two segments) into one Path and stroke it: every fifth line at 1.4 pt and 85 % opacity, the others 0.7 pt at 45 %. With Reduce Motion on, pause the timeline.
            """#
        ) { TopographicDemo() },

        MotionEffect(
            id: "day-night-sky",
            name: "Day & Night Sky",
            summary: "A sky runs from starry night through dawn, noon and sunset, sun and moon arcing over.",
            component: .background,
            triggers: [.loop, .change],
            sourceFile: "Background/DayNightSky.swift",
            api: "DayNightSky(time:)",
            usage: #"""
            DayNightSky()                // loops a day every 16 s
                .ignoresSafeArea()

            DayNightSky(time: hour / 24) // follows the time of day
            """#,
            prompt: #"""
            Create a SwiftUI DayNightSky(time:cycle:) view (iOS 17+). time is 0…1 (0 midnight, 0.25 sunrise, 0.5 noon, 0.75 sunset); nil loops it with TimelineView every cycle (16 s). Draw an Animatable scene in a Canvas: a vertical gradient whose top and horizon colours are interpolated between stops (night navy, deep purple dawn, pink-orange sunrise horizon, bright blue noon, golden afternoon, orange sunset horizon under violet, dusk). Fade in 50 hashed stars near night, twinkling. Put the sun and moon on opposite sides of an arc: x = mid − cos(angle) × 0.45w, y = horizon − sin(angle) × 0.75h, sun angle = (t − 0.25) × 2π, each with a blurred halo; the sun turns orange near the horizon. Finish with a band of dark hills tinted from the sky colour. Animate a fixed time with .easeInOut(duration: 1.2). With Reduce Motion on, hold at early evening (0.7).
            """#
        ) { DayNightSkyDemo() },
    ]

    // MARK: - Number

    static let numberV05: [MotionEffect] = [
        MotionEffect(
            id: "contribution-grid",
            name: "Contribution Grid",
            summary: "Activity squares pop in column by column, shaded by how busy each day was.",
            component: .number,
            triggers: [.appear, .change],
            sourceFile: "Number/ContributionGrid.swift",
            api: "ContributionGrid(values:)",
            usage: #"""
            ContributionGrid(values: commitsPerDay, color: .green)
            """#,
            prompt: #"""
            Create a SwiftUI ContributionGrid(values:rows:color:cellSize:spacing:) view (iOS 17+) like a contributions calendar: values fill columns of rows (7) top to bottom, left to right, as 11 pt squares with 3 pt gaps and corner radius 0.22 × size. Shade each square by its share of the largest value, rounded up to quarters: 0 is secondary at 15 %, otherwise the colour at 0.25 + 0.75 × level. On appear, scale each square from 0.2 and fade it in with .spring(duration: 0.4, bounce: 0.45) delayed by 0.035 s per column + 0.02 s per row, so it sweeps in diagonally; changes of shade use the same staggered spring. With Reduce Motion on, no scaling and a plain 0.3 s ease. Make it one accessibility element whose value is "N of M days active".
            """#
        ) { ContributionGridDemo() },

        MotionEffect(
            id: "analog-clock",
            name: "Analog Clock",
            summary: "A clock with a sweeping second hand; set a time and the hands spring to it.",
            component: .number,
            triggers: [.loop, .change],
            sourceFile: "Number/AnalogClock.swift",
            api: "AnalogClock(date:)",
            usage: #"""
            AnalogClock()                       // live
                .frame(width: 160, height: 160)

            AnalogClock(date: meeting, accent: .pink)
            """#,
            prompt: #"""
            Create a SwiftUI AnalogClock(date:color:accent:timeZone:) view (iOS 17+) drawn in a Canvas at a 1:1 aspect ratio. Convert the date to local seconds = timeIntervalSinceReferenceDate + the zone's offset, so the hands only ever move forward. Face: a ring at 25 % opacity and 60 ticks (every fifth 2.5 pt and longer). Hands from s = seconds mod 43 200: hour angle s / 43 200 × 2π (length 0.5r, width 4.5 % of the side), minute (s mod 3600) / 3600 × 2π (0.75r, 3 %), second (s mod 60) / 60 × 2π in the accent colour with a short tail and a centre dot. With no date, update from TimelineView(.animation) so the second hand sweeps; with a date, make the face Animatable on seconds and animate changes with .spring(duration: 0.9, bounce: 0.3) so the hands turn forward to the new time. With Reduce Motion on, tick once per second with TimelineView(.periodic). Label it "Clock" with the time as its value.
            """#
        ) { AnalogClockDemo() },
    ]

    // MARK: - Particle & 3D

    static let particleV05: [MotionEffect] = [
        MotionEffect(
            id: "flock",
            name: "Flock",
            summary: "Little arrows swim together like birds or fish, and chase your finger.",
            component: .particle,
            triggers: [.loop, .drag, .hover],
            sourceFile: "Particle/Flock.swift",
            api: "Flock()",
            usage: #"""
            Flock(count: 60, color: .white)
                .background(.indigo.gradient)
            """#,
            prompt: #"""
            Create a SwiftUI Flock(count:color:speed:) view (iOS 17+) that simulates boids. Keep the boids (position, velocity) in a reference-type model stored in @State and advance it from a Canvas inside TimelineView(.animation), with dt = time since the last frame capped at 1/20 s. For each boid, look at neighbours within 46 pt: steer 5 % towards their average velocity, 1.2 % towards their centre, and away from any closer than 16 pt by 0.14 × the overlap. If there's a target (from onContinuousHover or a DragGesture(minimumDistance: 0)), add 2 % of the gap to it. Push back by 9 within 24 pt of an edge. Clamp speed between 0.6 and 1.3 × cruise (90 pt/s × speed, a multiplier defaulting to 1; 1.5× when chasing). Draw each boid as a small arrowhead path rotated to atan2 of its velocity. With Reduce Motion on, freeze them. Hide it from accessibility.
            """#
        ) { FlockDemo() },

        MotionEffect(
            id: "ink-trail",
            name: "Ink Trail",
            summary: "The pointer or finger leaves puffs of ink that swell, drift up and fade.",
            component: .particle,
            triggers: [.drag, .hover],
            sourceFile: "Particle/InkTrail.swift",
            api: ".inkTrail(color:)",
            usage: #"""
            Color.black
                .inkTrail(color: .purple)
            """#,
            prompt: #"""
            Create a SwiftUI .inkTrail(color:lifetime:size:) view modifier (iOS 17+). Record puffs (point, time, random seed) from onContinuousHover and a simultaneous DragGesture(minimumDistance: 0), skipping points closer than 0.18 × size to the last one within 50 ms and dropping puffs older than lifetime (1.2 s). Draw them in an overlay Canvas inside TimelineView(.animation) with a blur of 0.35 × size: at age a (0…1) a puff has radius size × (0.35 + 0.9a) (size 26 pt), rises 34a pt, sways sideways by sin(seed × 9 + 3a) × 14a pt, and has opacity 0.85 × (1 − a)². Disable hit testing on the overlay. With Reduce Motion on, record nothing.
            """#
        ) { InkTrailDemo() },

        MotionEffect(
            id: "rain-on-glass",
            name: "Rain on Glass",
            summary: "Raindrops cling to a window while bigger drops slide down in fits and starts.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/RainOnGlass.swift",
            api: "RainOnGlass()",
            usage: #"""
            Image("city-night")
                .blur(radius: 6)
                .overlay(RainOnGlass())
            """#,
            prompt: #"""
            Create a SwiftUI RainOnGlass(drops:color:) overlay (iOS 17+) in TimelineView(.animation) + Canvas. Scatter one static bead per 900 pt² at hashed positions with radius 0.8–2.6 pt. Each of the sliding drops (9) has a cycle of 3.5–7.5 s; its progress l through the cycle becomes stick-slip motion with five steps, (floor(5l) + frac(5l)³) / 5, carrying it from a hashed start near the top past the bottom edge, with a 3 pt sideways wobble and radius 3.2–5.8 pt, stretched 1.25× vertically. Behind it, leave a trail of tiny beads every 9 pt with hashed jitter. Draw every drop like a tiny lens: an ellipse filled with a diagonal gradient (tint 35 % → tint 5 % → black 35 %) plus a bright fleck at the top-left. Disable hit testing. With Reduce Motion on, pause the timeline.
            """#
        ) { RainOnGlassDemo() },

        MotionEffect(
            id: "orbits",
            name: "Orbits",
            summary: "Planets circle a glowing star on tilted orbits, passing behind it and in front.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/Orbits.swift",
            api: "Orbits(colors:)",
            usage: #"""
            Orbits(colors: [.orange, .cyan, .pink])
                .frame(width: 240, height: 160)
            """#,
            prompt: #"""
            Create a SwiftUI Orbits(colors:tilt:centerColor:) view (iOS 17+) in TimelineView(.animation) + Canvas. Each colour is a planet on its own orbit, radius spread from 0.38 to 1 × the largest radius that fits (an ellipse squashed vertically by tilt, 0.38). Period = 2.4 × (2r / maxR)^1.5 s so inner planets move faster; angle = time / period × 2π + 2.1 × index; position = centre + (cos a × r, sin a × r × tilt); depth = sin a. Stroke each orbit at white 14 %. Draw the planets with depth < 0 first, then the star (a 20 pt circle over a 32 pt blurred halo at 70 %), then the ones in front, so they pass behind and in front of it. Scale planets by 0.75 + 0.25 × (depth + 1) / 2 and dim the far ones. With Reduce Motion on, pause the timeline.
            """#
        ) { OrbitsDemo() },
    ]

    // MARK: - Transition

    static let transitionV05: [MotionEffect] = [
        MotionEffect(
            id: "ink-bleed",
            name: "Ink Bleed",
            summary: "New content spreads in like a blot of ink on wet paper, with a ragged edge.",
            component: .transition,
            triggers: [.change],
            sourceFile: "Transition/InkBleed.swift",
            api: ".transition(.inkBleed)",
            usage: #"""
            if showsDetail {
                DetailCard()
                    .transition(.inkBleed(origin: .topLeading))
            }
            """#,
            prompt: #"""
            Create a SwiftUI Transition .inkBleed / .inkBleed(origin: UnitPoint) (iOS 17+) that masks the content with an Animatable blot view whose progress is 1 when the phase is identity and 0 otherwise. The blot is a Canvas with .alphaThreshold(min: 0.5) and a blur of max(2, 0.06r), drawing into a layer: a circle of radius 0.82r at the origin plus 26 circles around it, at angle i / 26 × 2π + hashed jitter, distance r × (0.62–0.92) and radius r × (0.12–0.32). r = (1.25 × distance to the furthest corner + 30) × progress, so blurring then thresholding melts them into one ragged blot that clears the corners at 1. With Reduce Motion on, fade instead.
            """#
        ) { InkBleedDemo() },

        MotionEffect(
            id: "zoom-blur",
            name: "Zoom Blur",
            summary: "Content rushes in from the camera, blurred and trailed by echoes, then snaps sharp.",
            component: .transition,
            triggers: [.change],
            sourceFile: "Transition/ZoomBlur.swift",
            api: ".transition(.zoomBlur)",
            usage: #"""
            Text(title)
                .id(title)
                .transition(.zoomBlur)
            """#,
            prompt: #"""
            Create a SwiftUI Transition .zoomBlur / .zoomBlur(scale:) (iOS 17+). In an Animatable modifier with amount 0 (in place) … 1 (away), scale the content to 1 + (scale − 1) × amount (scale 1.6), blur it by 14 × amount and fade it to 1 − amount. While 0 < amount < 1, add three echo copies behind it, each a little larger (+ 0.12 × step × amount), blurrier (6 + 6 × step × amount) and fainter ((1 − amount) × 0.28 / step), as a cheap radial zoom blur. The phase maps identity to 0 and both insertion and removal to 1, so it rushes in from the camera and out past it. With Reduce Motion on, fade instead.
            """#
        ) { ZoomBlurDemo() },
    ]
}
