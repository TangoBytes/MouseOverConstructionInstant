#!/usr/bin/env bash
set -e

MOD_NAME="MouseOverConstructionInstant"
VERSION=$(jq -r '.version' info.json)

OUTDIR="dist"
PKG_DIR="${OUTDIR}/${MOD_NAME}_${VERSION}"
ZIP="${OUTDIR}/${MOD_NAME}_${VERSION}.zip"

mkdir -p "$OUTDIR"
rm -f "$ZIP"
rm -rf "$PKG_DIR"

# Copy your mod sources into the versioned folder
rsync -a --delete \
  --exclude ".git" \
  --exclude "dist" \
  --exclude "resources" \
  --exclude "*.psd" --exclude "*.xcf" \
  ./ "$PKG_DIR/"

# Zip it (top-level folder name must match "<name>_<version>")
( cd "$OUTDIR" && zip -r -q "$(basename "$ZIP")" "$(basename "$PKG_DIR")" )

echo "✅ Built: $ZIP"
