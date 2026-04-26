#!/usr/bin/env bash
#
# Regenerate appcast.xml from a directory of release zips using Sparkle's
# `generate_appcast`. The tool inspects every Insomnio-*.zip it finds, signs
# each with the Ed25519 private key in your keychain, extracts version/
# bundle-id metadata from the embedded Info.plist, and writes an appcast.xml
# alongside the zips.
#
# Usage:
#   scripts/generate_appcast.sh                # uses build/ as the input dir
#   scripts/generate_appcast.sh path/to/dir    # custom dir
#
# Optional env vars:
#   APPCAST_DOWNLOAD_PREFIX   base URL prepended to <enclosure url>; defaults
#                             to https://github.com/AlfredoHernandez/Insomnio/
#                             releases/latest/download/
#   APPCAST_FULL_RELEASE_NOTES_URL  link rendered as "Full release notes" in
#                                   the Sparkle update sheet.
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log() { printf "\033[1;34m▶\033[0m %s\n" "$*"; }
ok()  { printf "\033[1;32m✓\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m✘\033[0m %s\n" "$*" >&2; }

cd "$(dirname "$0")/.."

INPUT_DIR="${1:-build}"
DOWNLOAD_PREFIX="${APPCAST_DOWNLOAD_PREFIX:-https://github.com/AlfredoHernandez/Insomnio/releases/latest/download/}"

if [[ ! -d "$INPUT_DIR" ]]; then
    err "Input directory not found: $INPUT_DIR"
    exit 1
fi

# Locate Sparkle's generate_appcast.
GENERATE_APPCAST=$(find InsomnioKit/.build/artifacts -type f -name "generate_appcast" -path "*/Sparkle/bin/*" 2>/dev/null | head -1)
if [[ -z "$GENERATE_APPCAST" ]]; then
    err "Sparkle 'generate_appcast' tool not found. Run 'cd InsomnioKit && swift build --target AutoUpdate' once."
    exit 1
fi

# generate_appcast scans the directory, produces sparkle/<bundle>.xml in there
# with all releases it can read. Every Insomnio-*.zip will be ingested.
log "Generating appcast from ${INPUT_DIR}/"
"$GENERATE_APPCAST" \
    --download-url-prefix "$DOWNLOAD_PREFIX" \
    ${APPCAST_FULL_RELEASE_NOTES_URL:+--full-release-notes-url "$APPCAST_FULL_RELEASE_NOTES_URL"} \
    "$INPUT_DIR"

APPCAST_PATH="${INPUT_DIR}/appcast.xml"
if [[ ! -f "$APPCAST_PATH" ]]; then
    err "appcast.xml not produced at $APPCAST_PATH"
    exit 1
fi
ok "Appcast written to $APPCAST_PATH"
log "Upload it (and the matching zip) to the GitHub Release as assets named:"
log "  - Insomnio-<version>.zip"
log "  - appcast.xml"
