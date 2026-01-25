#!/bin/bash
# Helper script for running Windows executables via Proton
# Usage: proton-run.sh <executable> [args...]
#
# Environment variables:
#   STEAM_COMPAT_DATA_PATH - Path to Proton prefix (default: /home/steam/.proton)
#   PROTON_PATH - Path to Proton installation
#   PROTON_LOG - Set to 1 to enable Proton logging

set -e

EXECUTABLE="${1:?Executable path required}"
shift

# Ensure Xvfb is running
if ! pgrep -x "Xvfb" > /dev/null; then
    Xvfb :99 -screen 0 1024x768x24 &
    sleep 2
fi

export DISPLAY=:99

# Ensure Proton prefix directory exists
mkdir -p "${STEAM_COMPAT_DATA_PATH}/pfx"

# Find Proton executable
PROTON_EXEC="${PROTON_PATH}/proton"

if [ ! -f "${PROTON_EXEC}" ]; then
    echo "ERROR: Proton not found at ${PROTON_EXEC}"
    exit 1
fi

echo "=== Running via Proton ==="
echo "Proton: ${PROTON_PATH}"
echo "Prefix: ${STEAM_COMPAT_DATA_PATH}"
echo "Executable: ${EXECUTABLE}"
echo "Arguments: $*"
echo "=========================="

# Run via Proton
# The 'run' command tells Proton to execute the Windows binary
exec "${PROTON_EXEC}" run "${EXECUTABLE}" "$@"
