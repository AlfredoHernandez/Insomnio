#!/usr/bin/env bash
#
# Build a signed Insomnio.app for local use (and optionally for distribution).
#
# Usage:
#   scripts/build.sh                              # signed for this Mac, leaves .app in build/export
#   scripts/build.sh --install                    # also copies to /Applications
#   scripts/build.sh --method developer-id        # sign with Developer ID (for distribution)
#   scripts/build.sh --method developer-id --notarize --install
#
# Notarization requires the env vars:
#   APPLE_ID         your Apple ID email
#   APPLE_TEAM_ID    Developer Team ID (currently HS399QXLRD)
#   APPLE_PASSWORD   app-specific password from appleid.apple.com
# Or, alternatively, a notarytool keychain profile name in NOTARY_PROFILE.
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
        --install)
            INSTALL=true
            shift
            ;;
        --help|-h)
            sed -n '3,18p' "$0" | sed 's/^# \{0,1\}//'
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
    -archivePath "$ARCHIVE_PATH" \
    | xcbeautify --quiet 2>/dev/null || \
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

# ---------------------------------------------------------------------------
# 5. Notarize (optional, developer-id only)
# ---------------------------------------------------------------------------
if $NOTARIZE; then
    log "Zipping for notarization"
    ZIP_PATH="${BUILD_DIR}/Insomnio-${VERSION}.zip"
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
# 6. Install to /Applications (optional)
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
