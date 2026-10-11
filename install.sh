#!/bin/sh
# Image Frame installation script.
# Installs the Plasma widget to user directories only. Does not use sudo.
set -e

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "kpackagetool6 not found. Install the Plasma 6 development tools."
    exit 1
fi

echo "Installing the Plasma widget..."
kpackagetool6 -t Plasma/Applet -i "$REPO_DIR/plasmoid/bsums.xyz.image-frame" 2>/dev/null \
    || kpackagetool6 -t Plasma/Applet -u "$REPO_DIR/plasmoid/bsums.xyz.image-frame"

echo
echo "Installation complete. Next steps:"
echo "1. Restart Plasma: systemctl --user restart plasma-plasmashell.service"
echo "2. Add the widget \"Image Frame\" to the desktop."
