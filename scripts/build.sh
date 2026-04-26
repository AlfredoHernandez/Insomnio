#!/usr/bin/env bash
#
# Build a signed Insomnio.app for local use (and optionally for distribution).
#
# Usage:
#   scripts/build.sh                              # signed for this Mac, leaves .app in build/export
#   scripts/build.sh --install                    # also copies to /Applications
#   scripts/build.sh --method developer-id        # sign with Developer ID (for distribution)
#   scripts/build.sh --method developer-id --notarize --sign-update
#
# Notarization requires the env vars:
#   APPLE_ID         your Apple ID email
#   APPLE_TEAM_ID    Developer Team ID (currently HS399QXLRD)
#   APPLE_PASSWORD   app-specific password from appleid.apple.com
# Or, alternatively, a notarytool keychain profile name in NOTARY_PROFILE.
#
# --sign-update produces a Sparkle EdDSA signature using the private key
# stored in your keychain by `generate_keys`. Prints the appcast `<enclosure>`
# attributes so you can paste them into appcast.xml — or run
# `scripts/generate_appcast.sh` afterwards to regenerate the feed.
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
SCHEME="Insomnio"
PROJECT="Insomnio.xcodeproj"
CONFIGURATION="Release"
EXPORT_METHOD="mac-application"   # mac-application | developer-id
NOTARIZE=false
SIGN_UPDATE=false
INSTALL=false
BUILD_DIR="build"
ARCHIVE_PATH="${BUILD_DIR}/Insomnio.xcarchive"
EXPORT_PATH="${BUILD_DIR}/export"
EXPORT_OPTIONS_PLIST="${BUILD_DIR}/ExportOptions.plist"

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --method)
            EXPORT_METHOD="$2"
            shift 2
            ;;
        --notarize)
            NOTARIZE=true
            shift
            ;;
        --sign-update)
            SIGN_UPDATE=true
            shift
            ;;
        --install)
            INSTALL=true
            shift
            ;;
        --help|-h)
            sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

if [[ "$EXPORT_METHOD" != "mac-application" && "$EXPORT_METHOD" != "developer-id" ]]; then
    echo "✘ --method must be 'mac-application' or 'developer-id' (got: $EXPORT_METHOD)" >&2
    exit 1
fi

if $NOTARIZE && [[ "$EXPORT_METHOD" != "developer-id" ]]; then
    echo "✘ --notarize requires --method developer-id" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log() { printf "\033[1;34m▶\033[0m %s\n" "$*"; }
ok()  { printf "\033[1;32m✓\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m✘\033[0m %s\n" "$*" >&2; }

# Move to repo root regardless of where the script was called from.
cd "$(dirname "$0")/.."

# Locate Sparkle's bundled tools (downloaded by SPM into .build artifacts).
sparkle_bin() {
    local tool="$1"
    local candidate
    candidate=$(find InsomnioKit/.build/artifacts -type f -name "$tool" -path "*/Sparkle/bin/$tool" 2>/dev/null | head -1)
    if [[ -z "$candidate" ]]; then
        err "Sparkle tool '$tool' not found. Run 'cd InsomnioKit && swift build --target AutoUpdate' once to populate the artifacts cache."
        exit 1
    fi
    printf "%s" "$candidate"
}

# ---------------------------------------------------------------------------
# 1. Clean build dir
# ---------------------------------------------------------------------------
log "Cleaning ${BUILD_DIR}/"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ---------------------------------------------------------------------------
# 2. Generate ExportOptions.plist
# ---------------------------------------------------------------------------
log "Generating ExportOptions.plist (method: ${EXPORT_METHOD})"
cat > "$EXPORT_OPTIONS_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>${EXPORT_METHOD}</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>teamID</key>
    <string>HS399QXLRD</string>
    <key>destination</key>
    <string>export</string>
EOF

if [[ "$EXPORT_METHOD" == "developer-id" ]]; then
    cat >> "$EXPORT_OPTIONS_PLIST" <<EOF
    <key>uploadSymbols</key>
    <true/>
EOF
fi

cat >> "$EXPORT_OPTIONS_PLIST" <<EOF
</dict>
</plist>
EOF

# ---------------------------------------------------------------------------
# 3. Archive
# ---------------------------------------------------------------------------
log "Archiving (${CONFIGURATION})"
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=macOS" \
    -archivePath "$ARCHIVE_PATH"

ok "Archive created at $ARCHIVE_PATH"

# ---------------------------------------------------------------------------
# 4. Export signed .app
# ---------------------------------------------------------------------------
log "Exporting signed .app"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"

APP_PATH="${EXPORT_PATH}/Insomnio.app"
if [[ ! -d "$APP_PATH" ]]; then
    err "Expected app not found at $APP_PATH"
    exit 1
fi
ok "Exported $APP_PATH"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${APP_PATH}/Contents/Info.plist")
BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${APP_PATH}/Contents/Info.plist")
log "Built Insomnio ${VERSION} (${BUILD})"

ZIP_PATH="${BUILD_DIR}/Insomnio-${VERSION}.zip"

# ---------------------------------------------------------------------------
# 5. Notarize (optional, developer-id only)
# ---------------------------------------------------------------------------
if $NOTARIZE; then
    log "Zipping for notarization"
    /usr/bin/ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

    log "Submitting to Apple notary service (this can take several minutes)"
    if [[ -n "${NOTARY_PROFILE:-}" ]]; then
        xcrun notarytool submit "$ZIP_PATH" \
            --keychain-profile "$NOTARY_PROFILE" \
            --wait
    else
        : "${APPLE_ID:?APPLE_ID env var required for notarization}"
        : "${APPLE_TEAM_ID:?APPLE_TEAM_ID env var required for notarization}"
        : "${APPLE_PASSWORD:?APPLE_PASSWORD env var required for notarization (app-specific password)}"
        xcrun notarytool submit "$ZIP_PATH" \
            --apple-id "$APPLE_ID" \
            --team-id "$APPLE_TEAM_ID" \
            --password "$APPLE_PASSWORD" \
            --wait
    fi

    log "Stapling notarization ticket"
    xcrun stapler staple "$APP_PATH"
    xcrun stapler validate "$APP_PATH"

    log "Re-zipping with stapled ticket"
    rm -f "$ZIP_PATH"
    /usr/bin/ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
    ok "Notarized + stapled. Distributable zip: $ZIP_PATH"
fi

# ---------------------------------------------------------------------------
# 6. Sign update for Sparkle (optional)
# ---------------------------------------------------------------------------
if $SIGN_UPDATE; then
    if [[ ! -f "$ZIP_PATH" ]]; then
        log "Zipping app for Sparkle signature"
        /usr/bin/ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
    fi

    log "Signing update with Sparkle EdDSA key (from keychain)"
    SIGN_UPDATE_BIN=$(sparkle_bin sign_update)
    SIGN_LINE=$("$SIGN_UPDATE_BIN" "$ZIP_PATH")
    ok "Sparkle signature line:"
    printf "    %s\n" "$SIGN_LINE"
    log "Use scripts/generate_appcast.sh to regenerate appcast.xml from build/"
fi

# ---------------------------------------------------------------------------
# 7. Install to /Applications (optional)
# ---------------------------------------------------------------------------
if $INSTALL; then
    log "Installing to /Applications/"
    if [[ -d "/Applications/Insomnio.app" ]]; then
        log "Removing previous /Applications/Insomnio.app"
        rm -rf "/Applications/Insomnio.app"
    fi
    /usr/bin/ditto "$APP_PATH" "/Applications/Insomnio.app"
    ok "Installed at /Applications/Insomnio.app"
    log "Launch with: open /Applications/Insomnio.app"
fi

ok "Done."
