// The animated mosaic at the top of the README (Docs/hero.gif), recorded with
// `Scripts/record-readme-gifs.sh hero`. Every tile is full-bleed and driven by
// the clock, so it loops without any input.

import MotionLibrary
import MotionShaders
import SwiftUI

let heroTile = CGSize(width: 260, height: 160)
let heroGap: CGFloat = 14
let heroPadding: CGFloat = 18
let heroStage = CGSize(
    width: heroPadding * 2 + heroTile.width * 3 + heroGap * 2,
    height: heroPadding * 2 + heroTile.height * 2 + heroGap
)
/// Length of one loop; the GIF is exactly this long.
let heroLoop = 4.0

struct HeroScene: View {
    private let start = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSince(start).truncatingRemainder(dividingBy: heroLoop)
            Grid(horizontalSpacing: heroGap, verticalSpacing: heroGap) {
                GridRow {
                    tile("LavaLamp()") { LavaLamp() }
                    tile(".disintegrate()") { disintegrate(t) }
                    tile("WarpTunnel()") { WarpTunnel(sides: 6).background(.black) }
                }
                GridRow {
                    tile("RetroGrid()") { synthwave }
                    tile("LiquidFillText()") { liquidText(t) }
                    tile("VoronoiCells()") { VoronoiCells(cellSize: 40) }
                }
            }
            .padding(heroPadding)
        }
        .frame(width: heroStage.width, height: heroStage.height)
        // GitHub's dark page colour, so the panel blends in there and reads as
        // a dark card on the light theme.
        .background(Color(red: 0.05, green: 0.07, blue: 0.09))
        .environment(\.colorScheme, .dark)
    }

    private func tile(_ api: String, @ViewBuilder _ content: () -> some View) -> some View {
        content()
            .frame(width: heroTile.width, height: heroTile.height)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                Text(api)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(.black.opacity(0.55), in: Capsule())
                    .padding(8)
            }
    }

    /// Holds, crumbles away on the wind, holds, then reforms.
    private func disintegrate(_ t: Double) -> some View {
        let progress: Double = switch t {
        case ..<0.7: 0
        case ..<1.8: ease((t - 0.7) / 1.1)
        case ..<2.4: 1
        case ..<3.4: 1 - ease((t - 2.4) / 1.0)
        default: 0
        }
        return ZStack {
            Color(red: 0.12, green: 0.10, blue: 0.20)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(Image(systemName: "person.fill").font(.system(size: 44)).foregroundStyle(.white))
                .frame(width: 104, height: 104)
                .disintegrate(progress, wind: CGVector(dx: 90, dy: -40), grain: 1.5)
        }
    }

    /// Fills up, then drains, once per loop. The level only changes twice so
    /// the view's own spring can carry it (a new target every frame keeps
    /// restarting the spring).
    private func liquidText(_ t: Double) -> some View {
        ZStack {
            Color(red: 0.06, green: 0.12, blue: 0.22)
            LiquidFillText("MOTION", progress: (0.3..<2.3).contains(t) ? 0.62 : 0.12, color: .cyan, waveHeight: 5)
                .font(.system(size: 54, weight: .black, design: .rounded))
        }
    }

    private var synthwave: some View {
        RetroGrid(color: .pink, spacing: 30, speed: 1.25)
            .background(
                LinearGradient(colors: [Color(red: 0.1, green: 0.02, blue: 0.2), Color(red: 0.28, green: 0.05, blue: 0.32)], startPoint: .top, endPoint: .bottom)
            )
            .overlay(alignment: .top) {
                Circle()
                    .fill(LinearGradient(colors: [.yellow, .pink], startPoint: .top, endPoint: .bottom))
                    .frame(width: 62, height: 62)
                    .padding(.top, 14)
            }
    }

    private func ease(_ x: Double) -> Double {
        let x = min(max(x, 0), 1)
        return x * x * (3 - 2 * x)
    }
}
