#!/usr/bin/env bash
# Compiles MotionLibrary and MotionGallery for macOS without Xcode (previews
# stripped, see stage-package.sh). Prints only diagnostics; exits non-zero on
# errors.
#
#   Scripts/check-build.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG="$("$ROOT/Scripts/stage-package.sh" "$@")"
status=0
out="$(swift build --package-path "$PKG" 2>&1)" || status=$?
echo "$out" | sed "s|$PKG/Sources/|Sources/|g" | grep -E "error:|warning:" | sort -u || true
[ "$status" -eq 0 ] && echo "build ok" || { echo "build failed"; exit 1; }
