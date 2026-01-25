#!/bin/bash
set -e

echo "=========================================="
echo "Enshrouded Dedicated Server"
echo "=========================================="

# Update/install server if requested
if [ "${UPDATE_ON_START}" = "true" ]; then
    echo "Updating server files..."
    VALIDATE_FLAG=""
    if [ "${VALIDATE_ON_START}" = "true" ]; then
        VALIDATE_FLAG="validate"
    fi

    ${STEAMCMD_DIR}/steamcmd.sh +@sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${STEAM_APP_ID} ${VALIDATE_FLAG} \
        +quit
fi

# Create server config directory
mkdir -p "${SERVER_DIR}/enshrouded_server"

# Generate server config (enshrouded_server.json)
CONFIG_FILE="${SERVER_DIR}/enshrouded_server.json"
cat > "${CONFIG_FILE}" << EOF
{
    "name": "${SERVER_NAME}",
    "password": "${SERVER_PASSWORD}",
    "saveDirectory": "./savegame",
    "logDirectory": "./logs",
    "ip": "${SERVER_IP}",
    "gamePort": ${GAME_PORT},
    "queryPort": ${QUERY_PORT},
    "slotCount": ${SLOT_COUNT}
}
EOF

echo "Server configuration:"
cat "${CONFIG_FILE}"

# Find the server executable
SERVER_EXE="${SERVER_DIR}/enshrouded_server.exe"
if [ ! -f "${SERVER_EXE}" ]; then
    echo "ERROR: Server executable not found at ${SERVER_EXE}"
    exit 1
fi

echo "Starting Enshrouded dedicated server via Proton..."
echo "Game Port: ${GAME_PORT}/udp"
echo "Query Port: ${QUERY_PORT}/udp"

# Initialize Proton prefix if needed
if [ ! -d "${STEAM_COMPAT_DATA_PATH}/pfx" ]; then
    echo "Initializing Proton prefix..."
    ${PROTON_PATH}/proton waitforexitandrun echo "Prefix initialized" || true
fi

# Run the server with Proton
cd "${SERVER_DIR}"
exec ${PROTON_PATH}/proton run "${SERVER_EXE}"
