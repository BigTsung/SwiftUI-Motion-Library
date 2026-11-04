#!/usr/bin/env bash
# Records a GIF of every gallery demo into Docs/gifs/ for the README.
#
#   Scripts/record-readme-gifs.sh            # all effects
#   Scripts/record-readme-gifs.sh tilt burst # just these catalog ids
#
# Needs macOS, a Swift toolchain and ffmpeg (`brew install ffmpeg`). Renders
# in a fully transparent off-screen window, so nothing appears on screen.
#
# Builds from the preview-stripped copy made by Scripts/stage-package.sh, so
# full Xcode isn't needed.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Prefer a full Xcode when one is installed: its toolchain can compile the
# Metal shaders in MotionShaders (the Command Line Tools can't).
if [ -z "${DEVELOPER_DIR:-}" ] && [ -d /Applications/Xcode.app ] \
    && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun metal -v >/dev/null 2>&1; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi
OUT="$ROOT/Docs/gifs"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

command -v ffmpeg >/dev/null || { echo "ffmpeg not found (brew install ffmpeg)"; exit 1; }

PKG="$("$ROOT/Scripts/stage-package.sh" Recorder=Scripts/ReadmeGIFs)"

echo "Building recorder…"
status=0
out="$(swift build --package-path "$PKG" -c release --product Recorder 2>&1)" || status=$?
[ "$status" -eq 0 ] || { echo "$out" | grep -E "error:" | sort -u; echo "build failed"; exit 1; }

# Set KEEP_FRAMES=/some/dir to keep the raw PNG frames for debugging.
FRAMES="${KEEP_FRAMES:-$WORK/frames}"
"$PKG/.build/release/Recorder" "$FRAMES" "$@"

mkdir -p "$OUT"
for dir in "$FRAMES"/*/; do
    id="$(basename "$dir")"
    ls "$dir"/*.png >/dev/null 2>&1 || continue
    # Captured at 2x and kept at 2x for crisp text on retina screens (the README
    # shows them at 1x). Soft gradients band badly with ordered dithering, so
    # the aurora is downscaled to its 240 pt display width and error-diffused
    # instead; it is all blur, so the lower resolution doesn't show.
    case "$id" in
        aurora) filter="fps=15,scale=iw/3:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=96:stats_mode=full[p];[b][p]paletteuse=dither=sierra2_4a" ;;
        # Whole-frame motion (every pixel changes every frame) makes huge GIFs
        # at 2x; at 1x they still look sharp at the 240 pt README size.
        particle-field|starfield|parallax-carousel|fireworks|snowfall|warp-tunnel|retro-grid|waves|grain|mesh-gradient|spotlight-card|flashlight|neon|fireflies|dot-globe|flow-field|bubbles|crt|heat-haze|matrix-rain|lava-lamp|meteors|water-ripple|pixellate|physics-emoji|shatter|network|topographic|day-night-sky|ink-trail|marquee-wall|kaleidoscope|halftone|flag-wave|voronoi)
                filter="fps=15,scale=iw/2:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=64:stats_mode=diff[p];[b][p]paletteuse=dither=none:diff_mode=rectangle" ;;
        *)      filter="fps=25,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" ;;
    esac
    ffmpeg -loglevel error -y -framerate 30 -i "$dir/%04d.png" -vf "$filter" -loop 0 "$OUT/$id.gif"
    echo "  $OUT/$id.gif ($(du -h "$OUT/$id.gif" | cut -f1))"
    # Every effect moves, so a GIF whose frames are all identical means the
    # synthetic taps or drags missed. Hashes the frames in memory.
    distinct="$(ffmpeg -loglevel error -i "$OUT/$id.gif" -f framemd5 - | grep -v '^#' | awk -F, '{print $6}' | sort -u | wc -l | tr -d ' ')"
    [ "$distinct" -gt 1 ] || frozen="${frozen:-} $id"
done

if [ -n "${frozen:-}" ]; then
    echo "FROZEN (every frame identical, record again):$frozen"
    exit 1
fi
