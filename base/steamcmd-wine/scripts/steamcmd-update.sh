#!/bin/bash
# Helper script for updating game servers via SteamCMD
# Usage: steamcmd-update.sh <app_id> <install_dir> [validate] [platform]
#
# Arguments:
#   app_id      - Steam App ID to download
#   install_dir - Directory to install the game
#   validate    - Optional: "validate" to verify files (default: no validation)
#   platform    - Optional: "windows" or "linux" (default: windows)

set -e

APP_ID="${1:?App ID required}"
INSTALL_DIR="${2:?Install directory required}"
VALIDATE="${3:-}"
PLATFORM="${4:-windows}"

echo "=== SteamCMD Update ==="
echo "App ID: ${APP_ID}"
echo "Install Dir: ${INSTALL_DIR}"
echo "Platform: ${PLATFORM}"
echo "Validate: ${VALIDATE:-no}"
echo "======================="

STEAMCMD_ARGS="+force_install_dir ${INSTALL_DIR} +login anonymous"

if [ "${PLATFORM}" = "windows" ]; then
    STEAMCMD_ARGS="+@sSteamCmdForcePlatformType windows ${STEAMCMD_ARGS}"
fi

STEAMCMD_ARGS="${STEAMCMD_ARGS} +app_update ${APP_ID}"

if [ "${VALIDATE}" = "validate" ]; then
    STEAMCMD_ARGS="${STEAMCMD_ARGS} validate"
fi

STEAMCMD_ARGS="${STEAMCMD_ARGS} +quit"

echo "Running: steamcmd.sh ${STEAMCMD_ARGS}"
/opt/steamcmd/steamcmd.sh ${STEAMCMD_ARGS}

echo "=== Update Complete ==="
