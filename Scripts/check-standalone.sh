#!/usr/bin/env bash
# Checks that every MotionLibrary effect compiles on its own from the files
# listed for it in Docs/motion-catalog.json (`files`), the way someone copies
# an effect into an app without the package. Type-checks for macOS.
#
#   Scripts/check-standalone.sh            # every effect
#   Scripts/check-standalone.sh shimmer    # only these ids
#   SWIFT_FLAGS="-swift-version 6" Scripts/check-standalone.sh
#                                          # as an app in the Swift 6 language mode would
#
# Run Scripts/generate-docs.sh first if you changed which helpers an effect
# uses. MotionShaders effects are skipped: their Swift file loads the shader
# from the package bundle, which a copy doesn't have.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CATALOG="$ROOT/Docs/motion-catalog.json"
command -v jq >/dev/null || { echo "error: needs jq" >&2; exit 2; }

SDK="$(xcrun --sdk macosx --show-sdk-path)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

ids=("$@")
if [ ${#ids[@]} -eq 0 ]; then
    while IFS= read -r id; do ids+=("$id"); done < <(jq -r '.effects[] | select(.sourceFile | startswith("Sources/MotionLibrary/")) | .id' "$CATALOG")
fi

failed=()
for id in "${ids[@]}"; do
    dir="$WORK/$id"
    mkdir -p "$dir"
    # Copy each file with its #Preview stripped (the macro needs Xcode's plugin).
    while IFS= read -r file; do
        awk '/^#Preview/{exit} {print}' "$ROOT/$file" > "$dir/$(basename "$file")"
    done < <(jq -r --arg id "$id" '.effects[] | select(.id == $id) | .files[] | select(endswith(".swift"))' "$CATALOG")
    if [ -z "$(ls "$dir")" ]; then
        echo "error: unknown effect id $id" >&2
        failed+=("$id")
        continue
    fi
    if xcrun swiftc -typecheck -sdk "$SDK" -target "$(uname -m)-apple-macos14" -parse-as-library ${SWIFT_FLAGS:-} "$dir"/*.swift >"$dir.log" 2>&1; then
        echo "ok    $id"
    else
        echo "FAIL  $id"
        grep 'error:' "$dir.log" | sort -u | head -5 | sed 's/^/      /'
        failed+=("$id")
    fi
done

if [ ${#failed[@]} -gt 0 ]; then
    echo "${#failed[@]} effect(s) don't compile from their listed files: ${failed[*]}" >&2
    exit 1
fi
echo "all ${#ids[@]} effects compile from their listed files"
