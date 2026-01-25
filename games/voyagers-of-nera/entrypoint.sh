#!/bin/bash
set -e

# Source base scripts
source /opt/scripts/entrypoint-base.sh &>/dev/null || true

INSTALL_DIR="/home/steam/server"
SERVER_EXE="${INSTALL_DIR}/BoatGame/Binaries/Win64/BoatGameServer-Win64-Shipping.exe"

echo "=========================================="
echo "Voyagers of Nera Dedicated Server"
echo "=========================================="
echo "Server Port: ${SERVER_PORT}"
echo "Max Players: ${MAX_PLAYERS}"
echo "Server Name: ${HOST_SERVER_DISPLAY_NAME}"
echo "=========================================="

# Ensure Xvfb is running for Wine
if ! pgrep -x "Xvfb" > /dev/null; then
    Xvfb :99 -screen 0 1024x768x16 &
    sleep 1
fi
export DISPLAY=:99

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
CONFIG_DIR="${INSTALL_DIR}/BoatGame/Saved/PersistedData/CustomConfig"
mkdir -p "${CONFIG_DIR}"

# Write CustomHostServerUserSettings.ini
HOST_CONFIG_FILE="${CONFIG_DIR}/CustomHostServerUserSettings.ini"
echo "Writing host server configuration to ${HOST_CONFIG_FILE}..."
cat > "${HOST_CONFIG_FILE}" << EOF
[/Script/BoatGame.BGCustomHostServerSettings]
HostServerDisplayName=${HOST_SERVER_DISPLAY_NAME}
HostServerPassword=${HOST_SERVER_PASSWORD}
MaxPlayers=${MAX_PLAYERS}
AutosaveTimerSeconds=${AUTOSAVE_TIMER_SECONDS}
EOF

# Write CustomGameUserSettings.ini
GAME_CONFIG_FILE="${CONFIG_DIR}/CustomGameUserSettings.ini"
echo "Writing game settings configuration to ${GAME_CONFIG_FILE}..."
cat > "${GAME_CONFIG_FILE}" << EOF
[/Script/BoatGame.BGCustomGameSettings]
GatheringRateMultiplier=${GATHERING_RATE_MULTIPLIER}
EnemyDamageMultiplier=${ENEMY_DAMAGE_MULTIPLIER}
PlayerDamageMultiplier=${PLAYER_DAMAGE_MULTIPLIER}
DisableEquipmentDurability=${DISABLE_EQUIPMENT_DURABILITY}
DisableDropItemsOnDeath=${DISABLE_DROP_ITEMS_ON_DEATH}
EOF

# Build server arguments
SERVER_ARGS=""

if [ "${SERVER_PORT}" != "7777" ]; then
    SERVER_ARGS="${SERVER_ARGS} -port=${SERVER_PORT}"
fi

if [ "${ENABLE_LOGGING}" = "true" ]; then
    SERVER_ARGS="${SERVER_ARGS} -log -LoggingInShippingEnabled=true"
fi

if [ -n "${ADDITIONAL_ARGS}" ]; then
    SERVER_ARGS="${SERVER_ARGS} ${ADDITIONAL_ARGS}"
fi

# Set EOS_OVERRIDE_HOST_IP if specified
if [ -n "${EOS_OVERRIDE_HOST_IP}" ]; then
    echo "Setting EOS_OVERRIDE_HOST_IP to ${EOS_OVERRIDE_HOST_IP}"
    export EOS_OVERRIDE_HOST_IP
fi

echo "Starting Voyagers of Nera server..."
echo "Executable: ${SERVER_EXE}"
echo "Arguments: ${SERVER_ARGS}"

# Start the server with Wine
cd "${INSTALL_DIR}"
exec wine64 "${SERVER_EXE}" ${SERVER_ARGS}
