#!/usr/bin/env bash
# Compiles MotionLibrary and MotionGallery for macOS without Xcode (previews
# stripped, see stage-package.sh). Prints only diagnostics; exits non-zero on
# errors.
#
#   Scripts/check-build.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Prefer a full Xcode when one is installed: its toolchain can compile the
# Metal shaders in MotionShaders (the Command Line Tools can't).
if [ -z "${DEVELOPER_DIR:-}" ] && [ -d /Applications/Xcode.app ] \
    && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun metal -v >/dev/null 2>&1; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi
PKG="$("$ROOT/Scripts/stage-package.sh" "$@")"
status=0
out="$(swift build --package-path "$PKG" 2>&1)" || status=$?
echo "$out" | sed "s|$PKG/Sources/|Sources/|g" | grep -E "error:|warning:" | grep -v "missing creator for mutated node" | sort -u || true
[ "$status" -eq 0 ] && echo "build ok" || { echo "build failed"; exit 1; }
