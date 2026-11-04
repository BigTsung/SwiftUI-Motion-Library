// Renders Docs/social-preview.png (1280×640), the image GitHub shows when the
// repo link is shared. Upload it in Settings → General → Social preview.
//   swift Scripts/make-social-preview.swift
import AppKit
import ImageIO
import SwiftUI

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()

/// (effect id, frame index): a frame where the effect is mid-motion.
let tiles: [(String, Int)] = [
    ("holo-card", 30), ("disintegrate", 55), ("liquid-fill-text", 40),
    ("like-button", 14), ("dot-globe", 20), ("kaleidoscope", 30),
]

func gifFrame(_ id: String, _ index: Int) -> NSImage? {
    let url = root.appendingPathComponent("Docs/gifs/\(id).gif")
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    let i = min(index, CGImageSourceGetCount(source) - 1)
    guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else { return nil }
    return NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
}

struct Preview: View {
    var body: some View {
        HStack(spacing: 48) {
            VStack(alignment: .leading, spacing: 22) {
                Text("SwiftUI\nMotion Library")
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineSpacing(-4)
                Text("Drop-in motion effects.\nCopy, paste, ship.")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                HStack(spacing: 10) {
                    ForEach(["iOS", "macOS", "visionOS", "Metal"], id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(.white.opacity(0.12), in: Capsule())
                    }
                }
                .padding(.top, 8)
            }
            .frame(width: 470, alignment: .leading)

            Grid(horizontalSpacing: 14, verticalSpacing: 14) {
                ForEach(0..<3) { row in
                    GridRow {
                        ForEach(0..<2) { column in
                            let (id, index) = tiles[row * 2 + column]
                            if let image = gifFrame(id, index) {
                                Image(nsImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .scaleEffect(1.35)
                                    .frame(width: 290, height: 170)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 60)
        .frame(width: 1280, height: 640)
        .background(
            LinearGradient(colors: [Color(red: 0.07, green: 0.08, blue: 0.13), Color(red: 0.18, green: 0.10, blue: 0.30)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
}

@MainActor func render() {
    let renderer = ImageRenderer(content: Preview())
    renderer.scale = 1
    guard let image = renderer.cgImage,
          let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
        fatalError("render failed")
    }
    let out = root.appendingPathComponent("Docs/social-preview.png")
    try! data.write(to: out)
    print("\(out.path) (\(image.width)×\(image.height))")
}

MainActor.assumeIsolated { render() }
