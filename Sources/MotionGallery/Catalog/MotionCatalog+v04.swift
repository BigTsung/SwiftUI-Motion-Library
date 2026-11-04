import SwiftUI
import MotionLibrary

// Catalog entries added in v0.4, appended to each component's list in
// `MotionCatalog.all`.

extension MotionCatalog {

    // MARK: - Text

    static let textV04: [MotionEffect] = [
        MotionEffect(
            id: "morphing-text",
            name: "Morphing Text",
            summary: "Words melt into each other with a gooey, liquid morph.",
            component: .text,
            triggers: [.loop],
            sourceFile: "Text/MorphingText.swift",
            api: "MorphingText([…])",
            usage: #"""
            MorphingText(["Design", "Build", "Ship"])
                .font(.system(size: 44, weight: .black, design: .rounded))
            """#,
            prompt: #"""
            Create a SwiftUI MorphingText(_ words:interval:morphDuration:color:) view (iOS 17+) that cycles through words with a gooey morph. Size it with hidden copies of every word in a ZStack and draw in an overlay Canvas padded out by 12 pt. In TimelineView(.animation), word index = Int(time / interval) % count; the morph runs over the last morphDuration (0.9 s) of each interval (2.2 s) with smoothstep progress p. In the Canvas, add .alphaThreshold(min: 0.3, color: color) then .blur(radius: 1.5), and inside drawLayer draw the outgoing word (resolved symbol, tagged by index) with its own .blur(radius: 6 × p) and opacity min(1, 2(1 − p)), and the incoming word with blur 6 × (1 − p) and opacity min(1, 2p), both centred; keeping both opaque through the middle stops the blob thinning out below the threshold. The threshold turns the overlapping blurry glyphs into one liquid shape. With Reduce Motion on, cross-fade plain Text views on a TimelineView(.periodic). Set the accessibility label to the words.
            """#
        ) { MorphingTextDemo() },

        MotionEffect(
            id: "neon",
            name: "Neon Flicker",
            summary: "A glowing neon tube that stutters on and glitches now and then.",
            component: .text,
            triggers: [.loop],
            sourceFile: "Text/NeonFlicker.swift",
            api: ".neon(color:flicker:)",
            usage: #"""
            Text("OPEN")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .neon(color: .pink)
            """#,
            prompt: #"""
            Create a SwiftUI .neon(color:flicker:) view modifier (iOS 17+) for text or symbols on a dark background. Draw the content white when lit (or the colour at 55 % opacity when it drops out) and stack three shadows in the colour: radius 2 (opacity = level), 8 (0.9 × level) and 18 (0.7 × level), with overall opacity 0.35 + 0.65 × level. With flicker on, drive level from TimelineView(.animation) over a 6 s cycle: a stuttering switch-on with dips to 0.1 (0–0.08 s), 0.2 (0.14–0.18 s), 0.15 (0.26–0.30 s) and 0.5 (0.38–0.40 s), a glitch at 4.20–4.45 s (0.3, 0.15, 0.6), otherwise a faint hum of 0.94 + 0.06 × sin(time × 40). With Reduce Motion on, keep a steady glow with no flicker.
            """#
        ) { NeonDemo() },

        MotionEffect(
            id: "karaoke-text",
            name: "Karaoke Text",
            summary: "A line fills with colour left to right as progress goes from 0 to 1.",
            component: .text,
            triggers: [.change, .scroll],
            sourceFile: "Text/KaraokeText.swift",
            api: "KaraokeText(_:progress:)",
            usage: #"""
            KaraokeText("Never gonna stop the music", progress: playback, highlight: .pink)
                .font(.title2.bold())
            """#,
            prompt: #"""
            Create a SwiftUI KaraokeText(_:progress:highlight:base:feather:) view (iOS 17+): a single-line Text in the base colour (secondary at 50 %) with an overlay of the same Text in the highlight colour, masked (alignment .leading) by an HStack in a GeometryReader: a Rectangle of width max(0, (width + feather) × progress − feather) followed by a LinearGradient black → clear of width feather (14 pt), so progress 0 shows nothing, 1 shows everything and the leading edge is soft. progress is clamped to 0…1 and changes to it animate because the frame width animates. Hide the overlay from accessibility.
            """#
        ) { KaraokeDemo() },

        MotionEffect(
            id: "weight-wave",
            name: "Weight Wave",
            summary: "Letters swell from thin to black and back in a travelling wave.",
            component: .text,
            triggers: [.loop],
            sourceFile: "Text/WeightWaveText.swift",
            api: "WeightWaveText(_:)",
            usage: #"""
            WeightWaveText("Variable weight")
                .font(.system(size: 36, design: .rounded))
            """#,
            prompt: #"""
            Create a SwiftUI WeightWaveText(_:speed:wavelength:) view (iOS 17+) that lays the characters out in an HStack(spacing: 0) inside TimelineView(.animation). Each character gets .fontWeight from the nine weights ultraLight…black, indexed by level = (sin(2π × (index / wavelength − time × speed)) + 1) / 2 (wavelength 8 letters, 0.6 waves/s × speed, a multiplier defaulting to 1), so a swell of bold travels through the word. The font comes from the environment. With Reduce Motion on, pause the timeline and use .regular. Combine into one accessibility element labelled with the string.
            """#
        ) { WeightWaveDemo() },

        MotionEffect(
            id: "exploding-text",
            name: "Exploding Text",
            summary: "Letters blast apart spinning and spring back into place.",
            component: .text,
            triggers: [.change, .tap],
            requirement: .ios18,
            sourceFile: "Text/ExplodingText.swift",
            api: "ExplodingText(_:isExploded:)",
            usage: #"""
            ExplodingText("Kaboom!", isExploded: exploded)
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .onTapGesture { exploded.toggle() }
            """#,
            prompt: #"""
            Create a SwiftUI ExplodingText(_:isExploded:distance:) view (iOS 18+) using a TextRenderer that is Animatable over progress (0 = assembled, 1 = scattered). Its displayPadding is distance on every side (60 pt). In draw(layout:in:), for each glyph (counted across lines and runs) take three stable pseudo-random values r0, r1, r2 from a hash of its index; translate by (cos, sin)(r0 × 2π) × distance × (0.5 + 0.5 × r1) × progress, rotate around the glyph's typographic-bounds centre by (r2 − 0.5) × 540° × progress, and set opacity 1 − 0.7 × progress. Animate with .easeOut(0.45 s) when exploding and .spring(duration: 0.8, bounce: 0.35) when reassembling. With Reduce Motion on, use distance 0 (just a fade) and a 0.3 s ease. Keep the string as the accessibility label.
            """#
        ) { ExplodingTextDemo() },
    ]

    // MARK: - Button

    static let buttonV04: [MotionEffect] = [
        MotionEffect(
            id: "gooey-menu",
            name: "Gooey Menu",
            summary: "A round button splits into a fan of buttons like a drop of liquid.",
            component: .button,
            triggers: [.tap],
            sourceFile: "Button/GooeyMenu.swift",
            api: "GooeyMenu(symbols:action:)",
            usage: #"""
            GooeyMenu(symbols: ["camera.fill", "photo.fill", "mic.fill"], color: .indigo) { index in
                attach(index)
            }
            """#,
            prompt: #"""
            Create a SwiftUI GooeyMenu(symbols:color:distance:action:) view (iOS 17+). Frame: width 2 × distance + 60, height distance + 66 (distance 76). Behind the buttons, a Canvas adds .alphaThreshold(min: 0.5, color: color) and .blur(radius: 7) and, in drawLayer, draws resolved symbols at the main button's centre (bottom centre, 8 pt up): a 56 pt Circle (tag −1) and one 44 pt Circle per item (tags 0…n−1) offset to its fan position, so the circles fuse like liquid while they separate. Item i of n sits at angle π + π × (i + 1) / (n + 1) on a half-circle of radius distance above the button, or at the centre when closed. Each item animates with .spring(duration: 0.55, bounce: 0.35) delayed 0.04 s × its order (reversed when closing). On top of the canvas, place real Buttons with white SF Symbols at the same offsets (opacity 0 and no hit testing when closed) and the main button with a "plus" that rotates 45° when open. Tapping an item calls action(index) and closes the menu. With Reduce Motion on, hide the goo, draw plain circles and fade items in place.
            """#
        ) { GooeyMenuDemo() },

        MotionEffect(
            id: "slide-to-confirm",
            name: "Slide to Confirm",
            summary: "Drag the knob all the way across to run the action; let go early and it springs back.",
            component: .button,
            triggers: [.drag],
            sourceFile: "Button/SlideToConfirm.swift",
            api: "SlideToConfirm(_:action:)",
            usage: #"""
            SlideToConfirm("Slide to pay", color: .green) {
                pay()
            }
            .frame(width: 280)
            """#,
            prompt: #"""
            Create a SwiftUI SlideToConfirm(_ title:color:resetAfter:action:) control (iOS 17+), 56 pt tall. In a GeometryReader ZStack(alignment: .leading): a Capsule track (secondary 15 %), the title (headline, secondary) whose opacity is 1 − progress × 1.6, a Capsule fill of width offset + knob + 8 in the colour at 35 %, and a 48 pt knob Circle (inset 4 pt) with a white "chevron.right.2" (or "checkmark" once confirmed, using contentTransition(.symbolEffect(.replace))) and a coloured shadow. A DragGesture on the knob sets offset = clamp(translation.width, 0, maxOffset). On release past 85 % of maxOffset: snap to the end with a 0.3 s spring, mark confirmed, call action and play a success haptic; then after resetAfter (1.5 s, or never if nil) spring back. Otherwise spring back with .spring(duration: 0.45, bounce: 0.35). Expose it to accessibility as a button whose action confirms.
            """#
        ) { SlideToConfirmDemo() },

        MotionEffect(
            id: "download-button",
            name: "Download Button",
            summary: "A capsule shrinks into a progress ring, then pops into a checkmark.",
            component: .button,
            triggers: [.tap, .change],
            sourceFile: "Button/DownloadButton.swift",
            api: "DownloadButton(progress:) { }",
            usage: #"""
            DownloadButton(progress: download.progress) {
                download.start()
            }
            """#,
            prompt: #"""
            Create a SwiftUI DownloadButton(_ title:progress:color:action:) (iOS 17+) with three phases from progress: nil = idle, 0..<1 = loading, ≥ 1 = done. It's a ZStack whose frame is 150 × 44 when idle and 44 × 44 otherwise, over a Capsule filled with the colour (idle), secondary 12 % (loading) or green (done). Idle shows a white Label(title, systemImage: "arrow.down") with a scale 0.8 + opacity transition; loading shows a Circle trimmed to progress, stroked 4 pt with round caps, rotated −90°, padded 3 pt, and a small "stop.fill"; done shows a white "checkmark" with a scale-from-0.2 + opacity transition. Animate phase changes with .spring(duration: 0.5, bounce: 0.35) so the capsule visibly shrinks into the ring, and play a success haptic when it finishes. The action only runs from the idle phase. With Reduce Motion on, use a 0.25 s ease instead of the spring.
            """#
        ) { DownloadButtonDemo() },

        MotionEffect(
            id: "star-rating",
            name: "Star Rating",
            summary: "Stars fill one after another with a springy pop and a burst of sparks.",
            component: .button,
            triggers: [.tap, .change],
            sourceFile: "Button/StarRating.swift",
            api: "StarRating(rating:)",
            usage: #"""
            StarRating(rating: $rating)
            """#,
            prompt: #"""
            Create a SwiftUI StarRating(rating: Binding<Int>, maximum:color:size:) control (iOS 17+): an HStack (spacing size × 0.25) of SF Symbols "star.fill" (filled, yellow) or "star" (secondary 50 %), size 28 pt. Tapping star i sets rating = i. Each filled star runs keyframeAnimator(initialValue: 1, trigger: rating) on its scale: hold 1 for (i − 1) × 0.06 s, SpringKeyframe to 1.4 (0.15 s, .snappy), then to 1 (0.4 s, .bouncy), so they pop in sequence. Behind the tapped star, eight 4 pt dots at 45° steps fly out from size × 0.3 to size × 0.95 over 0.45 s while fading (after the same delay). Play a light haptic on change. Make the whole control one adjustable accessibility element ("Rating", "3 of 5"). With Reduce Motion on, skip the pops and sparks.
            """#
        ) { StarRatingDemo() },

        MotionEffect(
            id: "bouncy-tab-bar",
            name: "Bouncy Tab Bar",
            summary: "A pill glides to the selected tab and its icon squashes and hops.",
            component: .button,
            triggers: [.tap, .change],
            sourceFile: "Button/BouncyTabBar.swift",
            api: "BouncyTabBar(selection:items:)",
            usage: #"""
            BouncyTabBar(selection: $tab, items: [
                .init("house.fill", "Home"),
                .init("magnifyingglass", "Search"),
                .init("person.fill", "Profile"),
            ])
            """#,
            prompt: #"""
            Create a SwiftUI BouncyTabBar(selection: Binding<Int>, items:color:) (iOS 17+) where each item is an SF Symbol and a title. Lay the tabs out in an HStack (spacing 4, padding 6) on a .regularMaterial Capsule with a soft shadow. Each tab is a plain Button with a VStack of the 18 pt semibold symbol and a caption2 title, tinted with the colour when selected (secondary otherwise), and a Capsule at 15 % of the colour behind the selected tab, shared with matchedGeometryEffect so it glides; selection changes use .spring(duration: 0.4, bounce: 0.3). The selected icon runs keyframeAnimator(trigger: selection), anchored at the bottom: scaleX 1.25 → 0.9 → spring 1, scaleY 0.75 → 1.12 → spring 1, y 0 → −7 → spring 0 (0.08 s, 0.14 s, 0.3 s .bouncy). Play a light haptic. With Reduce Motion on, skip the hop.
            """#
        ) { BouncyTabBarDemo() },
    ]

    // MARK: - Card & Group

    static let cardV04: [MotionEffect] = [
        MotionEffect(
            id: "scratch-card",
            name: "Scratch Card",
            summary: "Rub away a scratch-off cover to reveal what's underneath.",
            component: .card,
            triggers: [.drag],
            sourceFile: "Card/ScratchCard.swift",
            api: ".scratchToReveal(_:onReveal:)",
            usage: #"""
            PrizeView()
                .scratchToReveal(Color.gray) {
                    didReveal = true
                }
            """#,
            prompt: #"""
            Create a SwiftUI .scratchToReveal(_ cover:lineWidth:threshold:onReveal:) view modifier (iOS 17+). Overlay a Rectangle filled with the cover style (with a faint "hand.draw.fill" hint until the first stroke) and mask it with a compositingGroup of a full Rectangle plus a stroked Path of every finger stroke (lineWidth 34, round caps and joins) using .blendMode(.destinationOut), so strokes punch holes in the cover. A DragGesture(minimumDistance: 0) starts a new stroke when translation is zero and appends locations otherwise. Track coverage on a 12 × 12 grid: mark every cell within lineWidth / 2 of each point; once 55 % of cells are marked, fade the cover out over 0.4 s, disable its hit testing and call onReveal once. Give the view a new .id to reset it. Accessibility: a button whose action reveals.
            """#
        ) { ScratchCardDemo() },

        MotionEffect(
            id: "stacking-cards",
            name: "Stacking Cards",
            summary: "Cards stick at the top while scrolling and shrink as the next one covers them.",
            component: .card,
            triggers: [.scroll],
            sourceFile: "Card/StackingCards.swift",
            api: ".stackingCard()",
            usage: #"""
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(cards) { card in
                        CardView(card).stackingCard()
                    }
                }
            }
            """#,
            prompt: #"""
            Create a SwiftUI .stackingCard(top:scale:) view modifier (iOS 17+) for cards in a VStack inside a vertical ScrollView, built with visualEffect so it needs no layout passes. From proxy.frame(in: .scrollView): overshoot = max(0, top − minY) (top 16 pt), covered = min(1, overshoot / height), gone = clamp(overshoot / height − 1, 0, 1). Apply offset(y: overshoot) so the card sticks at the top, scaleEffect(1 − (1 − scale) × covered, anchor: .top) with scale 0.88, brightness(−0.25 × covered) and opacity(1 − gone). Later cards naturally draw on top in the VStack, so they slide over the pinned ones like a wallet. With Reduce Motion on, skip the scaling.
            """#
        ) { StackingCardsDemo() },

        MotionEffect(
            id: "deck-shuffle",
            name: "Deck Shuffle",
            summary: "A deck splits in two, mixes, and springs back into a messy stack.",
            component: .card,
            triggers: [.change, .tap],
            sourceFile: "Card/DeckShuffle.swift",
            api: "DeckShuffle(items, trigger:) { item in }",
            usage: #"""
            DeckShuffle(cards, trigger: shuffles) { card in
                CardFace(card)
            }
            .onTapGesture { shuffles += 1 }
            """#,
            prompt: #"""
            Create a generic SwiftUI DeckShuffle(_ items:trigger:spread:content:) view (iOS 17+) for Identifiable items. Keep the order as @State [ID]. Draw the cards in a ZStack with zIndex = stack position, offset y = −2 pt × position and a small hand-made tilt per position (0, −2.5, 2, −1, 3, −2, 1.5, −3°). When trigger changes: animate isSplit = true with .easeOut(0.28 s), which moves even positions to x −spread (70 pt) rotated −8° and odd ones to +spread rotated +8°; after 0.3 s, in one .spring(duration: 0.55, bounce: 0.3) animation, shuffle the order and set isSplit = false, so cards change sides and visibly cross over as they come together. With Reduce Motion on, just re-order with a 0.3 s ease.
            """#
        ) { DeckShuffleDemo() },

        MotionEffect(
            id: "looping-carousel",
            name: "Looping Carousel",
            summary: "A paging carousel that wraps around forever, with peeking neighbours.",
            component: .card,
            triggers: [.drag, .loop],
            sourceFile: "Card/LoopingCarousel.swift",
            api: "LoopingCarousel(items) { item in }",
            usage: #"""
            LoopingCarousel(banners, autoplay: 3) { banner in
                BannerCard(banner)
            }
            .frame(height: 200)
            """#,
            prompt: #"""
            Create a SwiftUI LoopingCarousel(_ items:spacing:peek:autoplay:content:) view (iOS 17+). Inside a horizontal ScrollView, a LazyHStack(spacing: 12) lays the items out three times (index 0..<3n, item = items[index % n]), each .containerRelativeFrame(.horizontal) with .scrollTransition(.interactive) scaling to 1 − |phase| × 0.12 and fading to 1 − |phase| × 0.4, and .id(index). Use .scrollTargetLayout(), .scrollTargetBehavior(.viewAligned), .contentMargins(.horizontal, peek + spacing) (peek 36 pt) and .scrollPosition(id:), starting at n (the middle copy). In .task(id: position), wait 0.45 s for scrolling to settle; if the position is outside the middle copy, jump to n + position % n inside a transaction with animations disabled, which looks identical. For autoplay, loop: sleep autoplay seconds, then position += 1 with .spring(duration: 0.6, bounce: 0.15). With Reduce Motion on, skip the scaling.
            """#
        ) { LoopingCarouselDemo() },

        MotionEffect(
            id: "drag-to-dismiss",
            name: "Drag to Dismiss",
            summary: "Fling a card away; it flies off with your throw or springs back.",
            component: .card,
            triggers: [.drag],
            sourceFile: "Card/DragToDismiss.swift",
            api: ".dragToDismiss(isPresented:)",
            usage: #"""
            if showPhoto {
                PhotoView()
                    .dragToDismiss(isPresented: $showPhoto)
            }
            """#,
            prompt: #"""
            Create a SwiftUI .dragToDismiss(isPresented:threshold:) view modifier (iOS 17+). While dragging, offset the view by the translation, scale it to 1 − min(0.2, distance / 1200) and rotate it by translation.width / 25 degrees. On release, if the drag distance exceeds threshold (120 pt) or the predicted end translation exceeds 2.5 × threshold, fly it off along the predicted direction normalised to 700 pt with .easeOut(0.3 s) while fading out, then set isPresented = false and reset the offset without animation. Otherwise spring back with .spring(duration: 0.45, bounce: 0.4). Add an accessibility action "Dismiss". With Reduce Motion on, skip the scale and rotation.
            """#
        ) { DragToDismissDemo() },

        MotionEffect(
            id: "shrinking-header",
            name: "Shrinking Header",
            summary: "The header sticks to the top and shrinks as content scrolls under it.",
            component: .card,
            triggers: [.scroll],
            sourceFile: "Card/ScrollHeaders.swift",
            api: ".shrinkingHeader()",
            usage: #"""
            ScrollView {
                VStack(spacing: 0) {
                    ProfileHeader().shrinkingHeader()
                    ForEach(posts) { PostRow($0) }
                }
            }
            """#,
            prompt: #"""
            Create a SwiftUI .shrinkingHeader(minScale:) view modifier (iOS 17+) for the first view in a vertical ScrollView, built with visualEffect. From proxy.frame(in: .scrollView): scrolled = max(0, −minY), progress = min(1, scrolled / (height × (1 − minScale))). Apply scaleEffect(1 − (1 − minScale) × progress, anchor: .top) with minScale 0.6 first, then offset(y: scrolled) so it stays pinned at the top (offset first and the scale would shrink the offset too, letting the header drift away), and give the view .zIndex(1) so the content scrolls underneath it. With Reduce Motion on, pin it without scaling.
            """#
        ) { ShrinkingHeaderDemo() },

        MotionEffect(
            id: "stretchy-header",
            name: "Stretchy Header",
            summary: "A header image stretches when pulled down and drifts with parallax when scrolled.",
            component: .card,
            triggers: [.scroll],
            sourceFile: "Card/ScrollHeaders.swift",
            api: ".stretchyHeader()",
            usage: #"""
            ScrollView {
                Image("cover")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 260)
                    .clipped()
                    .stretchyHeader()
                ArticleBody()
            }
            """#,
            prompt: #"""
            Create a SwiftUI .stretchyHeader(parallax:) view modifier (iOS 17+) for a header image at the top of a vertical ScrollView, built with visualEffect. From proxy.frame(in: .scrollView): when pulled past the top (minY > 0), scaleEffect(1 + minY / height, anchor: .bottom) so it grows upward to fill the gap; when scrolled up (minY < 0), offset(y: minY × −parallax) with parallax 0.5 so it moves at half speed. With Reduce Motion on, skip the parallax.
            """#
        ) { StretchyHeaderDemo() },
    ]

    // MARK: - Shape

    static let shapeV04: [MotionEffect] = [
        MotionEffect(
            id: "reading-progress",
            name: "Reading Progress",
            summary: "A bar along the top fills as you scroll through the content.",
            component: .shape,
            triggers: [.scroll],
            sourceFile: "Shape/ReadingProgress.swift",
            api: "ReadingProgressScrollView { … }",
            usage: #"""
            ReadingProgressScrollView(color: .pink) {
                ArticleBody()
            }
            """#,
            prompt: #"""
            Create a SwiftUI ReadingProgressScrollView(color:height:content:) (iOS 17+): a vertical ScrollView whose content gets a top overlay holding a Color.clear layer with a Capsule (4 pt tall, the colour, a soft glow shadow) at its top-leading edge. Drive the layer with visualEffect, not state or a PreferenceKey (preferences don't reliably leave an iOS scroll view): frame = proxy.frame(in: .scrollView), viewport = proxy.bounds(of: .scrollView)?.size, progress = clamp(−frame.minY / (frame.height − viewport.height), 0, 1); scaleEffect(x: viewport.width × progress / frame.width, anchor: .topLeading), then offset(x: −frame.minX, y: −frame.minY) to pin it to the top. Disable hit testing.
            """#
        ) { ReadingProgressDemo() },
    ]

    // MARK: - Background

    static let backgroundV04: [MotionEffect] = [
        MotionEffect(
            id: "lava-lamp",
            name: "Lava Lamp",
            summary: "Soft blobs drift up and down, stretching and merging like hot wax.",
            component: .background,
            triggers: [.loop],
            sourceFile: "Background/LavaLamp.swift",
            api: "LavaLamp()",
            usage: #"""
            LavaLamp(colors: [.yellow, .orange, .pink])
                .ignoresSafeArea()
            """#,
            prompt: #"""
            Create a SwiftUI LavaLamp(colors:background:blobs:speed:) view (iOS 17+). In TimelineView(.animation), fill a vertical LinearGradient of the colours, masked by a Canvas that adds .alphaThreshold(min: 0.5, color: .black) then .blur(radius: 7 % of the smaller side), and in drawLayer fills 7 black ellipses: blob i (seed = i × 1.618) at x = width × (0.2 + 0.6 × (0.5 + 0.5 sin(seed × 3.1 + t × 0.13))), y = height × (0.5 + 0.48 sin(t × (0.18 + 0.05 × (i % 3)) + seed × 2.3)), radius = min side × (0.11 + 0.07 × (0.5 + 0.5 sin(seed × 5.7))), stretched vertically by 1 + 0.25 |cos(t × 0.2 + seed × 2.3)|, plus wide pools of wax at the bottom and top. The threshold fuses the blurred blobs into liquid shapes (metaballs). Put the background colour (deep purple) behind. With Reduce Motion on, show one still frame.
            """#
        ) { LavaLampDemo() },

        MotionEffect(
            id: "matrix-rain",
            name: "Matrix Rain",
            summary: "Columns of glyphs rain down with bright heads and fading trails.",
            component: .background,
            triggers: [.loop],
            sourceFile: "Background/MatrixRain.swift",
            api: "MatrixRain()",
            usage: #"""
            MatrixRain(color: .green)
                .background(.black)
                .ignoresSafeArea()
            """#,
            prompt: #"""
            Create a SwiftUI MatrixRain(color:fontSize:speed:) view (iOS 17+) drawn in a Canvas inside TimelineView(.animation). Resolve every glyph (half-width katakana plus digits, monospaced, 14 pt) once per frame in the trail colour and in white. Columns are fontSize × 0.9 wide, rows fontSize × 1.1 tall. For each column, a stable random seed sets the trail length (8–22), the speed (6–16 rows/s) and a phase; the head row = (time × speed + seed × 97) mod (rows + length). Draw the head white at full opacity and each trail cell below it with opacity 0.85 × (1 − offset / length), picking the glyph from a hash of (column, row, floor(time × (2 + seed × 4))) so characters flicker. With Reduce Motion on, show one still frame.
            """#
        ) { MatrixRainDemo() },

        MotionEffect(
            id: "dot-grid",
            name: "Interactive Dot Grid",
            summary: "A grid of dots scatters away from your finger and eases back.",
            component: .background,
            triggers: [.drag, .hover, .loop],
            sourceFile: "Background/InteractiveDotGrid.swift",
            api: "InteractiveDotGrid()",
            usage: #"""
            InteractiveDotGrid(spacing: 18)
                .ignoresSafeArea()
            """#,
            prompt: #"""
            Create a SwiftUI InteractiveDotGrid(spacing:color:highlight:radius:) view (iOS 17+). Track the pointer from a DragGesture(minimumDistance: 0) and onContinuousHover (nil when released). In a Canvas inside TimelineView(.animation), smooth the pointer and a 0…1 strength each frame with exponential easing (k = 1 − e^(−14 dt) while active, strength decays with e^(−6 dt) after release) in a plain reference-type model. Draw a centred grid of dots every spacing points (18 pt): within radius (70 pt) of the pointer, near = (1 − d / radius)² × strength; push the dot away by near × spacing × 1.6, grow it by 2 × near and tint it with the highlight colour above 0.15. At rest, a faint wave sin((column + row) × 0.45 − time × 2) varies the radius by 0.5 pt. With Reduce Motion on, keep the highlight but don't move dots or run the wave.
            """#
        ) { DotGridDemo() },

        MotionEffect(
            id: "meteors",
            name: "Meteors",
            summary: "Meteors streak across a starry sky with glowing heads and fading tails.",
            component: .background,
            triggers: [.loop],
            sourceFile: "Background/Meteors.swift",
            api: "Meteors()",
            usage: #"""
            Meteors(count: 10)
                .background(Color(red: 0.03, green: 0.04, blue: 0.12))
                .ignoresSafeArea()
            """#,
            prompt: #"""
            Create a SwiftUI Meteors(count:angle:color:showsStars:) view (iOS 17+) drawn in a Canvas inside TimelineView(.animation). Scatter 60 faint static stars (0.4–1.2 pt, 25–65 % opacity) from a stable hash. Each meteor i has a flight time of 1.6–3.8 s and a pause of 0.5–3 s; when in flight, its head moves from a start point spread along the top edge and the side it comes from along the direction (angle 135° in y-down coordinates, so they travel down and to the left) by (width + height) × 1.2 × progress. Stroke its 50–110 pt tail from the tail point to the head with a linear gradient clear → 90 % colour, 1.5 pt wide, round caps, and draw a 5 pt head with a 2 pt blur. With Reduce Motion on, draw the stars only.
            """#
        ) { MeteorsDemo() },

        MotionEffect(
            id: "flow-field",
            name: "Flow Field",
            summary: "Generative curves follow a shifting vector field with dashes flowing along them.",
            component: .background,
            triggers: [.loop],
            sourceFile: "Background/FlowField.swift",
            api: "FlowField()",
            usage: #"""
            FlowField(colors: [.cyan, .blue, .purple, .pink])
                .background(Color(white: 0.06))
                .ignoresSafeArea()
            """#,
            prompt: #"""
            Create a SwiftUI FlowField(lines:colors:speed:) view (iOS 17+) drawn in a Canvas inside TimelineView(.animation). Define a flow angle field(x, y, t) = (sin(x × 0.012 + t) × cos(y × 0.014 − 0.7t) + sin((x + y) × 0.007 + 0.5t)) × π, with coordinates scaled so the smaller side maps to about 220 units and t = time × 0.25. For each of 140 lines, start at a stable random point and integrate 22 steps of 3.2 pt along the field into a Path. Stroke it in a colour picked from the list at 18 % opacity, then again at 85 % with a dash [5, 40] and dashPhase −((time × 30 + random × 45) mod 45), so short dashes travel along the curves (wrap the phase: a huge dash phase makes Core Graphics hang). With Reduce Motion on, show one still frame.
            """#
        ) { FlowFieldDemo() },
    ]

    // MARK: - Number

    static let numberV04: [MotionEffect] = [
        MotionEffect(
            id: "split-flap",
            name: "Split-Flap Display",
            summary: "Characters flip through the alphabet like an airport departures board.",
            component: .number,
            triggers: [.change],
            sourceFile: "Number/SplitFlap.swift",
            api: "SplitFlapText(_:)",
            usage: #"""
            SplitFlapText(departure.time)   // "12:45"
            """#,
            prompt: #"""
            Create a SwiftUI SplitFlapText(_ text:size:tile:ink:) view (iOS 17+), upper-casing the text, with one flap cell per character in an HStack. Each cell is size × 0.78 wide and size × 1.3 tall (size 36), drawn from four halves of a monospaced bold character on a rounded dark tile, each half clipped to the top or bottom half: static top = next character, static bottom = current, a top flap showing current rotated with rotation3DEffect about the x axis anchored at .bottom, and a bottom flap showing next anchored at .top; a thin dark line covers the seam. When the target changes, after a 0.05 s × index delay, step through the characters of the board alphabet " A…Z0…9:.-/" from current towards the target (at most the last 6 steps); each step folds the top flap 0 → −90° (.easeIn, 0.07 s), then the bottom flap 90° → 0 (.easeOut, 0.07 s), then commits next as current and resets the angles without animation. With Reduce Motion on, change instantly.
            """#
        ) { SplitFlapDemo() },

        MotionEffect(
            id: "slot-machine",
            name: "Slot Machine",
            summary: "Number reels spin with motion blur and land one after another.",
            component: .number,
            triggers: [.change],
            sourceFile: "Number/SlotMachineNumber.swift",
            api: "SlotMachineNumber(value:)",
            usage: #"""
            SlotMachineNumber(value: score, digits: 3)
            """#,
            prompt: #"""
            Create a SwiftUI SlotMachineNumber(value:digits:size:) view (iOS 17+) that zero-pads the value and shows one reel per digit. A reel is a VStack of 40 rows (row % 10, heavy rounded monospaced digits, size × 1.25 tall) offset by −index × rowHeight and clipped to one row, on a rounded secondary-12 % tile with a top/bottom shading gradient like a drum. When its digit changes from old to new: jump (no animation) to index old, set a blur of size × 0.06, and animate index to 30 + new with .timingCurve(0.3, 0, 0.2, 1.08) over 0.9 s + 0.25 s × reel order, so reels land left to right with a small overshoot; ease the blur off over the last 30 %, and on completion jump back to index new without animation. With Reduce Motion on, animate straight to the new digit in 0.3 s.
            """#
        ) { SlotMachineDemo() },

        MotionEffect(
            id: "price-ticker",
            name: "Price Ticker",
            summary: "Digits roll to the new price as the background flashes green or red.",
            component: .number,
            triggers: [.change],
            sourceFile: "Number/PriceTicker.swift",
            api: "PriceTicker(value:)",
            usage: #"""
            PriceTicker(value: stock.price)
                .font(.title2.bold())
            """#,
            prompt: #"""
            Create a SwiftUI PriceTicker(value:fractionDigits:prefix:) view (iOS 17+): an HStack of a 10 pt "arrowtriangle.up.fill" / "arrowtriangle.down.fill" (hidden when flat) and the prefix + value formatted with fractionDigits decimals, monospacedDigit, with .contentTransition(.numericText(value:)) and .snappy(0.35 s) animation so digits roll. On change, record the direction (green up, red down) for the arrow and text colour, and bump a counter that drives keyframeAnimator on a rounded background in that colour: opacity 0 → 0.3 (0.05 s) → 0 (0.9 s), a quick flash. With Reduce Motion on, skip the roll animation and the flash.
            """#
        ) { PriceTickerDemo() },

        MotionEffect(
            id: "animated-chart",
            name: "Animated Chart",
            summary: "Bars grow up one after another; a line draws itself left to right.",
            component: .number,
            triggers: [.appear, .change],
            sourceFile: "Number/AnimatedChart.swift",
            api: "GrowingBarChart(values:) / DrawingLineChart(values:)",
            usage: #"""
            GrowingBarChart(values: weekly)
                .frame(height: 120)

            DrawingLineChart(values: trend, color: .pink)
                .frame(height: 120)
            """#,
            prompt: #"""
            Create two SwiftUI chart views without Swift Charts (iOS 17+). GrowingBarChart(values:color:spacing:): in a GeometryReader, an HStack(alignment: .bottom) of bars with top-rounded UnevenRoundedRectangles filled with the colour's gradient, bar width = width / (n + (n − 1) × spacing) with spacing 0.35; heights are 0 until onAppear sets grown, then height × value / max with .spring(duration: 0.6, bounce: 0.3) delayed 0.06 s × index, and springing to new heights when values change. DrawingLineChart(values:color:duration:): map values into the rect (5–6 pt inset), smooth with midpoint quadratic curves, stroke it 3 pt with round caps trimmed to progress, fill the closed area under it with a colour 35 % → clear gradient at opacity progress, and pop a 9 pt dot with a white ring onto the last point with a bouncy spring once progress reaches 1. In .task(id: values), reset progress to 0 without animation and animate to 1 with .easeInOut(1.2 s). With Reduce Motion on, use short eases.
            """#
        ) { AnimatedChartDemo() },

        MotionEffect(
            id: "needle-gauge",
            name: "Needle Gauge",
            summary: "A speedometer needle swings to the value, overshoots and settles.",
            component: .number,
            triggers: [.change],
            sourceFile: "Number/NeedleGauge.swift",
            api: "NeedleGauge(value:)",
            usage: #"""
            NeedleGauge(value: cpuLoad)
                .frame(width: 200, height: 200)
            """#,
            prompt: #"""
            Create a SwiftUI NeedleGauge(value:colors:label:) view (iOS 17+), value 0…1, square. Draw a 240° arc (from 150° to 30° clockwise, radius 42 % of the side, line width 8 %, round caps): a secondary-15 % track, and on top an animatable arc Shape trimmed to the value and stroked with an AngularGradient of green, yellow, red over the same angles. Add 11 tick capsules (longer every fifth) rotated from −120° to +120°, a primary-coloured needle capsule rotated −120° + 240° × value, and a hub circle. Animate the needle with .spring(duration: 0.9, bounce: 0.45) so it overshoots and settles. Below the hub, show the label or the percentage with .contentTransition(.numericText). With Reduce Motion on, use a 0.3 s ease.
            """#
        ) { NeedleGaugeDemo() },
    ]

    // MARK: - Particle & 3D

    static let particleV04: [MotionEffect] = [
        MotionEffect(
            id: "physics-emoji",
            name: "Physics Emoji",
            summary: "Emoji tumble in with gravity, bounce off each other and pile up.",
            component: .particle,
            triggers: [.change, .tap],
            sourceFile: "Particle/PhysicsEmoji.swift",
            api: "PhysicsEmoji(trigger:)",
            usage: #"""
            PhysicsEmoji(trigger: drops)
                .frame(height: 300)
                .onTapGesture { drops += 1 }
            """#,
            prompt: #"""
            Create a SwiftUI PhysicsEmoji(trigger:emojis:batch:size:) view (iOS 17+) with a tiny physics world in a plain reference type stepped from a Canvas inside TimelineView(.animation). Each change of trigger drops batch (6) bodies of radius size / 2 (30 pt emoji) at random x above the top with small random velocities and spin; keep at most 36, removing the oldest. Each frame (dt capped at 1/30 s, two substeps): add gravity 1400 pt/s², integrate, bounce off the floor with restitution 0.45 (stopping tiny bounces below 30 pt/s), damp sideways speed by 0.9 and make spin follow rolling speed (vx / r), bounce off the side walls, then resolve circle–circle overlaps by pushing pairs apart along the normal and exchanging the normal impulse −(1 + e) × relative / 2. Decay spin by 0.97 per frame. Draw each emoji (resolved once per frame) translated and rotated. Disable hit testing and hide from accessibility. With Reduce Motion on, place new emoji directly on the floor without falling.
            """#
        ) { PhysicsEmojiDemo() },

        MotionEffect(
            id: "shatter",
            name: "Shatter",
            summary: "The view breaks into triangular shards that fly, spin and fall away.",
            component: .particle,
            triggers: [.change],
            sourceFile: "Particle/Shatter.swift",
            api: ".transition(.shatter)",
            usage: #"""
            if !isBroken {
                GlassPane()
                    .transition(.shatter)
            }
            """#,
            prompt: #"""
            Create a SwiftUI ShatterTransition (iOS 17+, Transition) with a static .shatter accessor. Build shards in unit coordinates from a 4 × 3 grid whose interior points are jittered by ±30 % of a cell, splitting each cell into two triangles along alternating diagonals. Removal applies an Animatable ViewModifier with progress 0 → 1 that renders the plain content at 0 (so an intact view isn't drawn once per shard) and otherwise a ZStack of the content masked by each triangle Shape (with a 0.8 pt stroke bleed to hide seams), rotated around its centroid by (r − 0.5) × 220° × p, offset along the centre-to-centroid direction by 110 pt × (0.6 + 0.6r) × p horizontally and 0.6 × 110 × p plus a falling 0.9 × 110 × p² vertically, with opacity 1 − p². Insertion just scales up from 0.9 and fades in. Read Reduce Motion in an inner View (Transition structs can't hold @Environment) and then use distance and spin 0 so shards only fade.
            """#
        ) { ShatterDemo() },

        MotionEffect(
            id: "cube",
            name: "3D Cube",
            summary: "Views swap by turning a cube: one face folds away as the next rotates in.",
            component: .particle,
            triggers: [.change],
            sourceFile: "Particle/CubeTransition.swift",
            api: ".transition(.cube)",
            usage: #"""
            ZStack {
                PageView(page)
                    .id(page)
                    .transition(.cube)
            }
            .clipped()
            """#,
            prompt: #"""
            Create a SwiftUI CubeTransition (iOS 17+, Transition) with .cube and .cube(edge:) accessors. Map the phase to a position: willAppear = +1 (waiting on the trailing side), identity = 0, didDisappear = −1 (flip the signs for edge .leading). Inside visualEffect (to read the view's width), apply offset(x: width × position) and rotation3DEffect(90° × position, axis y, anchor .leading when position > 0 else .trailing, perspective 0.5). Halfway through, the outgoing face's trailing edge and the incoming face's leading edge meet in the middle like two faces of a cube. Read Reduce Motion in an inner View and cross-fade instead.
            """#
        ) { CubeDemo() },

        MotionEffect(
            id: "dot-globe",
            name: "Dot Globe",
            summary: "A globe of evenly spread dots spins on a tilted axis, with pulsing cities.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/DotGlobe.swift",
            api: "DotGlobe()",
            usage: #"""
            DotGlobe(dots: 700, color: .cyan)
                .frame(width: 260, height: 260)
            """#,
            prompt: #"""
            Create a SwiftUI DotGlobe(dots:color:accent:speed:) view (iOS 17+), square, drawn in a Canvas inside TimelineView(.animation). Place 700 points on a unit sphere with the Fibonacci method (y = 1 − 2(i + 0.5)/n, ring = √(1 − y²), θ = golden angle × i + time × 0.6), tilt them 0.35 rad around the x axis, and project orthographically onto a circle of radius 45 % of the side. With depth = (z + 1) / 2, draw each dot with radius (0.6 + 1.2 × depth) and opacity 0.12 + 0.88 × depth², so the back is faint. Every 61st dot is a "city" in the accent colour (on the front half) whose radius pulses with sin(time × 3 + i). Add a faint 15 % rim circle. With Reduce Motion on, don't rotate.
            """#
        ) { DotGlobeDemo() },

        MotionEffect(
            id: "bubbles",
            name: "Bubbles",
            summary: "Soap bubbles rise and wobble with rainbow rims and glossy highlights.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/Bubbles.swift",
            api: "Bubbles()",
            usage: #"""
            Bubbles(count: 18)
                .background(LinearGradient(colors: [.blue.opacity(0.5), .indigo], startPoint: .top, endPoint: .bottom))
            """#,
            prompt: #"""
            Create a SwiftUI Bubbles(count:color:speed:) view (iOS 17+) drawn in a Canvas inside TimelineView(.animation). Each of 18 bubbles has a stable random radius (6–22 pt), rise time (4–8 s), phase and x; progress = ((time + phase) / duration) mod 1 moves it from below the bottom to above the top while x wobbles by 14 pt × sin(time × (1 + r) + i). Fade in over the first ~17 % and out over the last 20 %. Fill each with a radial gradient (2 % → 12 % → 35 % of the tint, transparent centre), stroke a 1 pt rim with a diagonal pink → tint → purple gradient, and add a small white oval highlight at the top-left. With Reduce Motion on, show one still frame.
            """#
        ) { BubblesDemo() },

        MotionEffect(
            id: "fireflies",
            name: "Fireflies",
            summary: "Glowing fireflies drift lazily and blink on their own rhythms.",
            component: .particle,
            triggers: [.loop],
            sourceFile: "Particle/Fireflies.swift",
            api: "Fireflies()",
            usage: #"""
            Fireflies(count: 24)
                .background(Color(red: 0.02, green: 0.06, blue: 0.05))
            """#,
            prompt: #"""
            Create a SwiftUI Fireflies(count:color:speed:) view (iOS 17+) drawn in a Canvas inside TimelineView(.animation). Each firefly has three stable random values a, b, c; its position is the view centre plus two layered sines per axis (x: 0.38 sin(t(0.13 + 0.12a) + 20a) + 0.1 sin(t(0.5 + 0.3b) + 9b); y: 0.36 sin(t(0.11 + 0.1b) + 17b) + 0.1 cos(t(0.45 + 0.3c) + 5c), as fractions of the size), giving slow wandering loops. Its blink = (0.5 + 0.5 sin(t(0.8 + 1.6c) + 30a))³. Draw a glow circle 8 × r wide in a context with .blur(radius: 6) at opacity 0.25 + 0.75 × blink, then a white core of radius r (1.6–2.8 pt) at 0.35 + 0.65 × blink. Warm yellow by default. With Reduce Motion on, freeze positions but keep the blinking.
            """#
        ) { FirefliesDemo() },
    ]

    // MARK: - Transition

    static let transitionV04: [MotionEffect] = [
        MotionEffect(
            id: "circular-reveal",
            name: "Circular Reveal",
            summary: "New content spreads out in a circle from where you tapped.",
            component: .transition,
            triggers: [.tap, .change],
            sourceFile: "Transition/CircularReveal.swift",
            api: "CircularReveal(value:) { value in }",
            usage: #"""
            CircularReveal(value: isDark, origin: tapPoint) { dark in
                ThemePreview(dark: dark)
            }
            """#,
            prompt: #"""
            Create a generic SwiftUI CircularReveal(value:origin:duration:content:) view (iOS 17+) where origin is a UnitPoint. Keep @State shown (initially value), incoming (optional) and progress. When value changes: if a reveal is in flight, commit it; set incoming = new and progress = 0 without animation, then animate progress to 1 with .easeInOut(0.7 s) and, on completion, set shown = new and incoming = nil without animation. Render ZStack { content(shown); content(incoming) masked by an animatable circle Shape centred at origin whose radius is progress × the distance to the furthest corner }, with hit testing off on the incoming layer. To start at a tap, convert the location with UnitPoint(x: x / width, y: y / height). With Reduce Motion on, cross-fade the incoming layer instead of growing the circle.
            """#
        ) { CircularRevealDemo() },

        MotionEffect(
            id: "liquid-swipe",
            name: "Liquid Swipe",
            summary: "The next page pours in from the edge behind a bulging liquid wave.",
            component: .transition,
            triggers: [.change],
            sourceFile: "Transition/LiquidSwipe.swift",
            api: ".transition(.liquidSwipe)",
            usage: #"""
            ZStack {
                OnboardingPage(page)
                    .id(page)
                    .transition(.liquidSwipe)
            }
            """#,
            prompt: #"""
            Create a SwiftUI LiquidSwipeTransition (iOS 17+, Transition) with a .liquidSwipe accessor. Mask the content with an animatable Shape whose progress is 0 on willAppear and 1 otherwise: at progress p it covers the view from the trailing edge to edge = maxX − (width + a) × p, where the bulge a = 0.35 × width × sin(πp); the leading boundary is straight except for a wave from midY − 0.45h to midY + 0.45h drawn with two cubic curves that bulge out to edge − a at midY. Darken the outgoing view with brightness −0.15 and give the incoming view zIndex 1 so it draws on top. Read Reduce Motion in an inner View and use no bulge.
            """#
        ) { LiquidSwipeDemo() },

        MotionEffect(
            id: "page-turn",
            name: "Page Turn",
            summary: "The old page swings away like a book page, revealing the next one.",
            component: .transition,
            triggers: [.change],
            sourceFile: "Transition/PageTurn.swift",
            api: ".transition(.pageTurn)",
            usage: #"""
            ZStack {
                ChapterView(chapter)
                    .id(chapter)
                    .transition(.pageTurn)
            }
            """#,
            prompt: #"""
            Create a SwiftUI PageTurnTransition (iOS 17+, Transition) with a .pageTurn accessor. The outgoing view gets zIndex 1 and an Animatable ViewModifier with progress 0 → 1: rotation3DEffect(−90° × p, axis y, anchor .leading, perspective 0.6), an overlay LinearGradient from clear to black at 45 % × p (leading → trailing) so the free edge darkens as it turns, a shadow of opacity 0.3 × sin(πp), radius 12, x 6, and opacity 0 at the very end. The incoming view sits underneath and brightens from −0.25 to 0. Read Reduce Motion in an inner View and simply fade the page out.
            """#
        ) { PageTurnDemo() },

        MotionEffect(
            id: "glitch-transition",
            name: "Glitch Transition",
            summary: "The view breaks up like a bad signal on its way in or out.",
            component: .transition,
            triggers: [.change],
            sourceFile: "Transition/GlitchTransition.swift",
            api: ".transition(.glitch)",
            usage: #"""
            if showAlert {
                AlertBanner()
                    .transition(.glitch)
            }
            """#,
            prompt: #"""
            Create a SwiftUI GlitchTransition (iOS 17+, Transition) with .glitch and .glitch(slices:) accessors that applies an Animatable ViewModifier with amount 0 (identity) → 1 (inserted or removed). At 0 render the content as is. Otherwise, with frame = Int(amount × 16) so the pattern changes in steps: stack a red copy (colorMultiply(.red), offset x −amount × 10, 60 %), a cyan copy (offset +amount × 10, 60 %) and 7 horizontal slices of the content, each masked to its band and offset sideways by (random(slice, frame) − 0.5) × 60 × amount; composite them and set opacity to 1 − 0.6 × amount, or 0.15 when random(frame) ≤ 0.9 × amount, reaching 0 at the end. Read Reduce Motion in an inner View and fade instead.
            """#
        ) { GlitchTransitionDemo() },

        MotionEffect(
            id: "origami",
            name: "Origami Fold",
            summary: "The view folds up into creased panels like a paper map.",
            component: .transition,
            triggers: [.change],
            sourceFile: "Transition/OrigamiFold.swift",
            api: ".transition(.origami)",
            usage: #"""
            if showTicket {
                TicketView()
                    .transition(.origami)
            }
            """#,
            prompt: #"""
            Create a SwiftUI OrigamiTransition (iOS 17+, Transition) with .origami and .origami(folds:) accessors applying an Animatable ViewModifier with progress 0 (flat) → 1 (folded). At 0 render the content. Otherwise keep the footprint with content.hidden() and, in a top-aligned overlay GeometryReader, draw 4 copies of the content, each masked to its horizontal panel. With angle = 90° × p and c = cos(angle): even panels hinge on their top edge (rotation3DEffect +angle about x, anchor at y = i / n), odd panels on their bottom edge (−angle, anchor (i + 1) / n), and each is offset by hinge × panelHeight × (c − 1) so it starts where the previous one ends, collapsing like an accordion towards the top. Shade panels with black at (0.1 even, 0.4 odd) × (1 − c), perspective 0.4, and fade out over the last 15 %. Read Reduce Motion in an inner View and fade instead.
            """#
        ) { OrigamiDemo() },
    ]
}
