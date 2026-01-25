#!/bin/bash
# Base entrypoint script for Proton-based game servers
# This script handles common setup tasks and then executes the game-specific command

set -e

# Start Xvfb for headless display if not already running
if ! pgrep -x "Xvfb" > /dev/null; then
    echo "Starting Xvfb virtual display..."
    Xvfb :99 -screen 0 1024x768x24 &
    sleep 2
fi

export DISPLAY=:99

# Ensure Proton prefix exists
mkdir -p "${STEAM_COMPAT_DATA_PATH}/pfx"

# Execute the command passed to the container
exec "$@"
