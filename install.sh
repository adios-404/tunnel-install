#!/bin/bash
set -e

REPO="adios-404/tunnel-install"
APP_NAME="Tunnel.app"
INSTALL_DIR="/Applications"

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║   Installing Tunnel VPN...       ║"
echo "  ╚══════════════════════════════════╝"
echo ""

echo "  → Finding latest version..."
RELEASE=$(curl -sf "https://api.github.com/repos/$REPO/releases/latest")

TAG=$(echo "$RELEASE" | grep '"tag_name"' | head -1 | sed 's/.*: "//;s/".*//')
DL_URL=$(echo "$RELEASE" | grep '"browser_download_url"' | head -1 | sed 's/.*: "//;s/".*//')

if [ -z "$DL_URL" ]; then
    echo "  ✗ Could not find release. Check your internet."
    exit 1
fi
echo "  → Downloading Tunnel $TAG..."

TMP_DIR=$(mktemp -d)
curl -sL "$DL_URL" -o "$TMP_DIR/Tunnel.zip"

echo "  → Extracting..."
cd "$TMP_DIR"
unzip -qo Tunnel.zip

if [ ! -d "$APP_NAME" ]; then
    echo "  ✗ Extraction failed."
    rm -rf "$TMP_DIR"
    exit 1
fi

pkill -f "Tunnel.app/Contents/MacOS/Tunnel" 2>/dev/null || true
sleep 0.5

echo "  → Installing to /Applications..."
rm -rf "$INSTALL_DIR/$APP_NAME"
mv "$APP_NAME" "$INSTALL_DIR/$APP_NAME"

xattr -cr "$INSTALL_DIR/$APP_NAME"

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
