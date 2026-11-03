#!/usr/bin/env bash
# Records README GIFs from the gallery demos running in the iOS Simulator, for
# effects the off-screen macOS recorder can't capture (it can't animate
# scrolling). Uses the demo app in Examples/MotionLibraryDemo.
#
#   Scripts/record-simulator-gifs.sh              # the scroll-driven effects
#   Scripts/record-simulator-gifs.sh stacking-cards
#
# Needs Xcode, an iOS Simulator runtime and ffmpeg (`brew install ffmpeg`).
# Uses the booted simulator, or boots the first available iPhone. Set
# SIMULATOR=<udid> to pick one.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/Docs/gifs"
DERIVED="$ROOT/.build/demo-app"
BUNDLE_ID="io.github.bigtsung.MotionLibraryDemo"
# Seconds of video per effect: long enough for two loops of the demo.
SECONDS_PER_EFFECT="${SECONDS_PER_EFFECT:-16}"

if [ -z "${DEVELOPER_DIR:-}" ] && [ -d /Applications/Xcode.app ]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi
command -v ffmpeg >/dev/null || { echo "ffmpeg not found (brew install ffmpeg)"; exit 1; }

ids=("$@")
[ ${#ids[@]} -gt 0 ] || ids=(stacking-cards shrinking-header stretchy-header reading-progress)

udid="${SIMULATOR:-}"
if [ -z "$udid" ]; then
    udid="$(xcrun simctl list devices booted | grep -Eo '[0-9A-F-]{36}' | head -1 || true)"
fi
if [ -z "$udid" ]; then
    udid="$(xcrun simctl list devices available | grep -E '^ +iPhone' | grep -Eo '[0-9A-F-]{36}' | head -1 || true)"
    [ -n "$udid" ] || { echo "no iPhone simulator found"; exit 1; }
    echo "Booting simulator $udid…"
    xcrun simctl boot "$udid"
    xcrun simctl bootstatus "$udid" >/dev/null
fi

echo "Building the demo app…"
status=0
out="$(xcodebuild build -project "$ROOT/Examples/MotionLibraryDemo/MotionLibraryDemo.xcodeproj" \
    -scheme MotionLibraryDemo -destination "id=$udid" -derivedDataPath "$DERIVED" \
    CODE_SIGNING_ALLOWED=NO 2>&1)" || status=$?
[ "$status" -eq 0 ] || { echo "$out" | grep -E "error:" | sort -u; echo "build failed"; exit 1; }
xcrun simctl install "$udid" "$DERIVED/Build/Products/Debug-iphonesimulator/MotionLibraryDemo.app"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$OUT"

for id in "${ids[@]}"; do
    video="$WORK/$id.mp4"
    xcrun simctl terminate "$udid" "$BUNDLE_ID" >/dev/null 2>&1 || true
    SIMCTL_CHILD_GIF_EFFECT="$id" xcrun simctl launch "$udid" "$BUNDLE_ID" >/dev/null
    sleep 2
    xcrun simctl io "$udid" recordVideo --force "$video" >/dev/null 2>&1 &
    recorder=$!
    sleep "$SECONDS_PER_EFFECT"
    kill -INT "$recorder"
    wait "$recorder" || true
    xcrun simctl terminate "$udid" "$BUNDLE_ID" >/dev/null 2>&1 || true

    # The app draws the 360 × 220 pt stage on black, so cropdetect finds it.
    crop="$(ffmpeg -i "$video" -t 2 -vf cropdetect=limit=0.1:round=2:reset=0 -f null - 2>&1 \
        | grep -Eo 'crop=[0-9:]+' | tail -1)"
    [ -n "$crop" ] || { echo "  $id: couldn't find the stage"; continue; }

    # Loop exactly one demo cycle: from one long pause (the demo resting at
    # the top) to the next. Falls back to the whole recording.
    freezes="$(ffmpeg -i "$video" -vf "$crop,freezedetect=n=0.001:d=1.3" -map 0:v -f null - 2>&1 \
        | grep -Eo 'freeze_start: [0-9.]+' | awk '{print $2}' | awk '$1 >= 1')"
    first="$(echo "$freezes" | sed -n 1p)"
    second="$(echo "$freezes" | sed -n 2p)"
    if [ -n "$first" ] && [ -n "$second" ]; then
        start="$(echo "$first + 0.3" | bc)"
        length="$(echo "$second - $first" | bc)"
    else
        start=0
        length="$SECONDS_PER_EFFECT"
    fi

    # Same look as Scripts/record-readme-gifs.sh: 720 × 440 px (2x), 25 fps.
    filter="$crop,scale=720:440:flags=lanczos,fps=25,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle"
    ffmpeg -loglevel error -y -ss "$start" -t "$length" -i "$video" -vf "$filter" -loop 0 "$OUT/$id.gif"
    echo "  $OUT/$id.gif ($(du -h "$OUT/$id.gif" | cut -f1), ${length}s loop)"
done
