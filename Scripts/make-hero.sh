#!/usr/bin/env bash
# Builds Docs/hero.gif, the animated mosaic at the top of the README, from the
# effect GIFs in Docs/gifs. Re-run after re-recording any of them.
#   Scripts/make-hero.sh [id …]   (defaults to the ids below, 3 per row)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
command -v ffmpeg >/dev/null || { echo "ffmpeg not found (brew install ffmpeg)"; exit 1; }

IDS=("$@")
[ ${#IDS[@]} -gt 0 ] || IDS=(holo-card disintegrate liquid-fill-text like-button dot-globe kaleidoscope)
COLS=3
W=300; H=220; GAP=10; LENGTH=4.0

inputs=(); chains=""; layout=""
for i in "${!IDS[@]}"; do
    f="$ROOT/Docs/gifs/${IDS[$i]}.gif"
    [ -f "$f" ] || { echo "missing $f"; exit 1; }
    inputs+=(-ignore_loop 0 -i "$f")
    # The middle of each stage (where the effect is) at 1x, padded so the
    # tiles sit apart on the stage colour.
    chains+="[$i:v]fps=20,trim=duration=$LENGTH,setpts=PTS-STARTPTS,crop=ih*0.9*$W/$H:ih*0.9,scale=$W:$H:flags=lanczos,pad=$((W + GAP)):$((H + GAP)):$((GAP / 2)):$((GAP / 2)):color=0xF6F6F6,setsar=1[t$i];"
    x=$(( (i % COLS) * (W + GAP) )); y=$(( (i / COLS) * (H + GAP) ))
    layout+="${layout:+|}${x}_${y}"
done
tiles=""; for i in "${!IDS[@]}"; do tiles+="[t$i]"; done

ffmpeg -loglevel error -y "${inputs[@]}" -filter_complex \
    "${chains}${tiles}xstack=inputs=${#IDS[@]}:layout=${layout}:fill=0xF6F6F6,split[a][b];[a]palettegen=max_colors=256:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
    -loop 0 "$ROOT/Docs/hero.gif"
echo "Docs/hero.gif ($(du -h "$ROOT/Docs/hero.gif" | cut -f1))"
