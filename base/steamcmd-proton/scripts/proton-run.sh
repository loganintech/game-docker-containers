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

# If TAIL_LOG_FILE is set, tail that file to stdout (useful for games that log to file instead of stdout)
if [ -n "${TAIL_LOG_FILE}" ]; then
    LOG_DIR=$(dirname "${TAIL_LOG_FILE}")
    mkdir -p "${LOG_DIR}"

    # Start log tailing in background (wait for file to exist)
    (
        while [ ! -f "${TAIL_LOG_FILE}" ]; do sleep 1; done
        exec tail -F "${TAIL_LOG_FILE}" 2>/dev/null
    ) &
    TAIL_PID=$!

    # Run via Proton (not exec, so we can cleanup)
    "${PROTON_EXEC}" run "${EXECUTABLE}" "$@"
    EXIT_CODE=$?

    # Cleanup tail process
    kill ${TAIL_PID} 2>/dev/null || true
    exit ${EXIT_CODE}
else
    # Run via Proton
    # The 'run' command tells Proton to execute the Windows binary
    exec "${PROTON_EXEC}" run "${EXECUTABLE}" "$@"
fi
