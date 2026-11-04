// Renders Docs/social-preview.png (1280×640), the image GitHub shows when the
// repo link is shared. Upload it in Settings → General → Social preview.
//   swift Scripts/make-social-preview.swift
import AppKit
import ImageIO
import SwiftUI

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()

/// The frame of Docs/hero.gif to show: the card is mid-crumble and the
/// liquid is rising.
let heroFrame = 22

func gifFrame(_ path: String, _ index: Int) -> NSImage? {
    let url = root.appendingPathComponent(path)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    let i = min(index, CGImageSourceGetCount(source) - 1)
    guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else { return nil }
    return NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
}

struct Preview: View {
    var body: some View {
        VStack(spacing: 26) {
            VStack(spacing: 10) {
                Text("SwiftUI Motion Library")
                    .font(.system(size: 62, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Drop-in motion effects for iOS, macOS & visionOS · Copy, paste, ship")
                    .font(.system(size: 26, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            // Shown at its native 1x size so it stays sharp.
            if let hero = gifFrame("Docs/hero.gif", heroFrame) {
                Image(nsImage: hero)
                    .frame(width: hero.size.width, height: hero.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        }
        .frame(width: 1280, height: 640)
        .background(
            LinearGradient(colors: [Color(red: 0.05, green: 0.07, blue: 0.09), Color(red: 0.13, green: 0.08, blue: 0.22)],
                           startPoint: .top, endPoint: .bottom)
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
