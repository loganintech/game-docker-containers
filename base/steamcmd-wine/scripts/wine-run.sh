#!/bin/bash
# Helper script for running Windows executables via Wine
# Usage: wine-run.sh <executable> [args...]
#
# Ensures Xvfb is running and DISPLAY is set before executing

set -e

EXECUTABLE="${1:?Executable path required}"
shift

# Ensure Xvfb is running
if ! pgrep -x "Xvfb" > /dev/null; then
    Xvfb :99 -screen 0 1024x768x16 &
    sleep 1
fi

export DISPLAY=:99

echo "=== Running via Wine ==="
echo "Executable: ${EXECUTABLE}"
echo "Arguments: $*"
echo "========================"

exec wine64 "${EXECUTABLE}" "$@"
