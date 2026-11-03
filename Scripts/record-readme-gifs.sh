#!/usr/bin/env bash
# Records a GIF of every gallery demo into Docs/gifs/ for the README.
#
#   Scripts/record-readme-gifs.sh            # all effects
#   Scripts/record-readme-gifs.sh tilt burst # just these catalog ids
#
# Needs macOS, a Swift toolchain and ffmpeg (`brew install ffmpeg`). A small
# window appears on screen while each effect is recorded. Don't move the mouse
# or click until it finishes: real input can cancel the simulated taps and drags.
#
# The sources are copied into a temporary package with their `#Preview` blocks
# removed, because the Previews macro plugin only ships with full Xcode.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/Docs/gifs"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

command -v ffmpeg >/dev/null || { echo "ffmpeg not found (brew install ffmpeg)"; exit 1; }

PKG="$WORK/pkg"
mkdir -p "$PKG/Sources/Recorder"
(cd "$ROOT" && find Sources -name '*.swift') | while read -r file; do
    mkdir -p "$PKG/$(dirname "$file")"
    # Every #Preview is the last declaration in its file.
    awk '/^#Preview/{exit} {print}' "$ROOT/$file" > "$PKG/$file"
done
cp "$ROOT/Scripts/ReadmeGIFs/main.swift" "$PKG/Sources/Recorder/main.swift"

cat > "$PKG/Package.swift" <<'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReadmeGIFs",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "MotionLibrary"),
        .target(name: "MotionGallery", dependencies: ["MotionLibrary"]),
        .executableTarget(name: "Recorder", dependencies: ["MotionGallery"]),
    ]
)
EOF

echo "Building recorder…"
swift build --package-path "$PKG" -c release --product Recorder 2>&1 | grep -E "error|warning: unre" || true
[ -x "$PKG/.build/release/Recorder" ] || { echo "build failed"; exit 1; }

# Set KEEP_FRAMES=/some/dir to keep the raw PNG frames for debugging.
FRAMES="${KEEP_FRAMES:-$WORK/frames}"
"$PKG/.build/release/Recorder" "$FRAMES" "$@"

mkdir -p "$OUT"
for dir in "$FRAMES"/*/; do
    id="$(basename "$dir")"
    ls "$dir"/*.png >/dev/null 2>&1 || continue
    # Captured at 2x and kept at 2x for crisp text on retina screens (the README
    # shows them at 1x). Soft gradients band badly with ordered dithering, so
    # the aurora is downscaled and error-diffused instead.
    case "$id" in
        aurora) filter="fps=20,scale=iw/2:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=full[p];[b][p]paletteuse=dither=sierra2_4a" ;;
        *)      filter="fps=25,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" ;;
    esac
    ffmpeg -loglevel error -y -framerate 30 -i "$dir/%04d.png" -vf "$filter" -loop 0 "$OUT/$id.gif"
    echo "  $OUT/$id.gif ($(du -h "$OUT/$id.gif" | cut -f1))"
done
