#!/bin/bash
set -e

INSTALL_DIR="/home/steam/server"
SERVER_EXE="${INSTALL_DIR}/StarRuptureServerEOS.exe"

echo "=========================================="
echo "StarRupture Dedicated Server (Proton)"
echo "=========================================="
echo "Proton Version: ${PROTON_VERSION}"
echo "Server Port: ${SERVER_PORT}"
echo "Query Port: ${QUERY_PORT}"
echo "Session Name: ${SESSION_NAME:-<not set>}"
echo "=========================================="

# Ensure Xvfb is running for Proton
if ! pgrep -x "Xvfb" > /dev/null; then
    Xvfb :99 -screen 0 1024x768x24 &
    sleep 2
fi
export DISPLAY=:99

# Ensure Proton prefix exists
mkdir -p "${STEAM_COMPAT_DATA_PATH}/pfx"

# Update server files if requested
if [ "${UPDATE_ON_START}" = "true" ]; then
    echo "Updating server files via SteamCMD..."

    VALIDATE_ARG=""
    if [ "${VALIDATE_ON_START}" = "true" ]; then
        VALIDATE_ARG="validate"
    fi

    /opt/scripts/steamcmd-update.sh "${STEAM_APP_ID}" "${INSTALL_DIR}" "${VALIDATE_ARG}" "windows" || {
        echo "SteamCMD update failed, continuing anyway..."
    }
fi

# Check if server is installed
if [ ! -f "${SERVER_EXE}" ]; then
    echo "ERROR: Server executable not found at ${SERVER_EXE}"
    echo "Attempting initial installation..."
    /opt/scripts/steamcmd-update.sh "${STEAM_APP_ID}" "${INSTALL_DIR}" "validate" "windows"

    if [ ! -f "${SERVER_EXE}" ]; then
        echo "ERROR: Installation failed. Server executable still not found."
        exit 1
    fi
fi

# Create config directories
CONFIG_DIR="${INSTALL_DIR}/StarRupture/Saved/Config/WindowsServer"
mkdir -p "${CONFIG_DIR}"
mkdir -p "${INSTALL_DIR}/StarRupture/Saved/SaveGames"

# Generate DSSettings.txt if SESSION_NAME is set
# This allows the server to auto-start without using the in-game Server Manager
if [ -n "${SESSION_NAME}" ]; then
    DSSETTINGS_FILE="${INSTALL_DIR}/DSSettings.txt"
    echo "Generating DSSettings.txt for auto-start..."

    cat > "${DSSETTINGS_FILE}" << EOF
[ServerSettings]
SessionName=${SESSION_NAME}
SaveGameName=${SAVE_GAME_NAME:-${SESSION_NAME}}
SaveInterval=${SAVE_GAME_INTERVAL}
EOF

    if [ "${START_NEW_GAME}" = "true" ]; then
        echo "StartNewGame=true" >> "${DSSETTINGS_FILE}"
    elif [ "${LOAD_SAVED_GAME}" = "true" ]; then
        echo "LoadSavedGame=true" >> "${DSSETTINGS_FILE}"
    fi

    echo "DSSettings.txt contents:"
    cat "${DSSETTINGS_FILE}"
fi

# Build server arguments
# StarRupture requires specific command-line arguments
SERVER_ARGS="-Log"
SERVER_ARGS="${SERVER_ARGS} -MULTIHOME=${MULTIHOME}"
SERVER_ARGS="${SERVER_ARGS} -Port=${SERVER_PORT}"
SERVER_ARGS="${SERVER_ARGS} -QueryPort=${QUERY_PORT}"

if [ -n "${SESSION_NAME}" ]; then
    SERVER_ARGS="${SERVER_ARGS} -ServerName=\"${SESSION_NAME}\""
fi

if [ -n "${ADDITIONAL_ARGS}" ]; then
    SERVER_ARGS="${SERVER_ARGS} ${ADDITIONAL_ARGS}"
fi

echo ""
echo "Starting StarRupture server via Proton..."
echo "Executable: ${SERVER_EXE}"
echo "Arguments: ${SERVER_ARGS}"
echo ""
echo "NOTE: StarRupture server may take a few minutes to fully initialize."
echo "The server is ready when you see 'Session created successfully' in the logs."
echo ""

# Start the server with Proton
cd "${INSTALL_DIR}"
exec /opt/scripts/proton-run.sh "${SERVER_EXE}" ${SERVER_ARGS}
