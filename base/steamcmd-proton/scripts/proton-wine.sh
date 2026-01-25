#!/bin/bash
# Helper script for running Wine commands through Proton's Wine
# Useful for winetricks, regedit, etc.
# Usage: proton-wine.sh <wine-command> [args...]
#
# Examples:
#   proton-wine.sh wineboot --init
#   proton-wine.sh regedit

set -e

WINE_CMD="${1:?Wine command required}"
shift

# Ensure Xvfb is running
if ! pgrep -x "Xvfb" > /dev/null; then
    Xvfb :99 -screen 0 1024x768x24 &
    sleep 2
fi

export DISPLAY=:99

# Ensure Proton prefix directory exists
mkdir -p "${STEAM_COMPAT_DATA_PATH}/pfx"

# Set up Wine environment to use Proton's Wine
export WINEPREFIX="${STEAM_COMPAT_DATA_PATH}/pfx"
export WINE="${PROTON_PATH}/files/bin/wine64"
export WINESERVER="${PROTON_PATH}/files/bin/wineserver"

# Add Proton's bin to PATH
export PATH="${PROTON_PATH}/files/bin:${PATH}"

# Run the Wine command
exec "${WINE}" "${WINE_CMD}" "$@"
