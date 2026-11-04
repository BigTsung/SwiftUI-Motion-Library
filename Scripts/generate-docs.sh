#!/usr/bin/env bash
# Regenerates every file derived from MotionCatalog: the README effects grid,
# llms.txt, llms-full.txt, Docs/motion-catalog.json, the Agent Skill and the
# Cursor rule. Run it after adding or changing an effect.
#
#   Scripts/generate-docs.sh          # write the files
#   Scripts/generate-docs.sh --check  # exit 1 if any file is out of date
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Prefer a full Xcode when one is installed, like check-build.sh, so the
# staged build is shared instead of rebuilt for each toolchain.
if [ -z "${DEVELOPER_DIR:-}" ] && [ -d /Applications/Xcode.app ] \
    && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun metal -v >/dev/null 2>&1; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi
PKG="$("$ROOT/Scripts/stage-package.sh" DocsGenerator=Scripts/DocsGenerator)"
status=0
out="$(swift build --package-path "$PKG" --product DocsGenerator 2>&1)" || status=$?
[ "$status" -eq 0 ] || { echo "$out" | grep -E "error:" | sort -u; echo "build failed"; exit 1; }
"$PKG/.build/debug/DocsGenerator" "$ROOT" "$@"
