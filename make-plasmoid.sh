#!/bin/sh
# Build the .plasmoid package for the KDE Store.
# Output: dist/image-frame-<version>.plasmoid
set -e

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC="$REPO_DIR/plasmoid/bsums.xyz.image-frame"
VERSION=$(grep -o '"Version": "[^"]*"' "$SRC/metadata.json" | cut -d'"' -f4)
OUT="$REPO_DIR/dist/image-frame-$VERSION.plasmoid"

mkdir -p "$REPO_DIR/dist"
rm -f "$OUT"
# The KDE Store expects metadata.json at the root of the archive.
(cd "$SRC" && zip -qr "$OUT" metadata.json contents)
echo "Built: $OUT"
