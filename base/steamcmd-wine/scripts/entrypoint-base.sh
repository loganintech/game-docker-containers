#!/bin/bash
# Base entrypoint script for Wine-based game servers
# This script handles common setup tasks and then executes the game-specific command

set -e

# Start Xvfb for headless Wine if not already running
if ! pgrep -x "Xvfb" > /dev/null; then
    Xvfb :99 -screen 0 1024x768x16 &
    sleep 1
fi

export DISPLAY=:99

# Execute the command passed to the container
exec "$@"
