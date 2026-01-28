#!/bin/bash
set -e

echo "=========================================="
echo "TShock Server v${TSHOCK_VERSION}"
echo "for Terraria v${TERRARIA_VERSION}"
echo "=========================================="

# Map friendly names to Terraria's expected values
map_world_size() {
    case "${1,,}" in
        small|1)  echo "1" ;;
        medium|2) echo "2" ;;
        large|3)  echo "3" ;;
        *)        echo "3" ;;
    esac
}

map_difficulty() {
    case "${1,,}" in
        classic|normal|0) echo "0" ;;
        expert|1)         echo "1" ;;
        master|2)         echo "2" ;;
        journey|3)        echo "3" ;;
        *)                echo "2" ;;
    esac
}

bool_to_json() {
    case "${1,,}" in
        true|1|yes) echo "true" ;;
        *)          echo "false" ;;
    esac
}

WORLD_SIZE_NUM=$(map_world_size "${WORLD_SIZE}")
DIFFICULTY_NUM=$(map_difficulty "${DIFFICULTY}")

# Generate server config (vanilla settings)
SERVER_CONFIG="${CONFIG_PATH}/serverconfig.txt"
echo "Generating server configuration..."

cat > "${SERVER_CONFIG}" << EOF
world=${WORLD_PATH}/${WORLD_NAME}.wld
worldpath=${WORLD_PATH}
worldname=${WORLD_NAME}
autocreate=${WORLD_SIZE_NUM}
difficulty=${DIFFICULTY_NUM}
maxplayers=${MAX_PLAYERS}
port=${PORT}
EOF

# Generate TShock config
TSHOCK_CONFIG="${CONFIG_PATH}/config.json"

# Only generate TShock config if it doesn't exist (preserve user customizations)
if [ ! -f "${TSHOCK_CONFIG}" ]; then
    echo "Generating TShock configuration..."
    cat > "${TSHOCK_CONFIG}" << EOF
{
  "Settings": {
    "ServerPort": ${PORT},
    "MaxSlots": ${MAX_PLAYERS},
    "ServerName": "${SERVER_NAME}",
    "UseServerName": true,
    "LogPath": "${LOG_PATH}",
    "AutoSave": $(bool_to_json "${AUTO_SAVE}"),
    "SpawnProtection": $(bool_to_json "${SPAWN_PROTECTION}"),
    "SpawnProtectionRadius": ${SPAWN_PROTECTION_RADIUS},
    "EnableWhitelist": $(bool_to_json "${ENABLE_WHITELIST}"),
    "RequireLogin": $(bool_to_json "${REQUIRE_LOGIN}"),
    "RestApiEnabled": $(bool_to_json "${REST_API_ENABLED}"),
    "RestApiPort": ${REST_API_PORT},
    "DisableSpewLogs": true,
    "StorageType": "sqlite"
  }
}
EOF
else
    echo "Using existing TShock configuration"
fi

# Link plugins directory
if [ -d "${PLUGIN_PATH}" ] && [ "$(ls -A ${PLUGIN_PATH} 2>/dev/null)" ]; then
    echo "Linking plugins from ${PLUGIN_PATH}..."
    mkdir -p /server/ServerPlugins
    for plugin in ${PLUGIN_PATH}/*.dll; do
        if [ -f "$plugin" ]; then
            ln -sf "$plugin" /server/ServerPlugins/ 2>/dev/null || cp "$plugin" /server/ServerPlugins/
        fi
    done
fi

echo ""
echo "Server Configuration:"
echo "  World: ${WORLD_NAME}"
echo "  Size: ${WORLD_SIZE} (${WORLD_SIZE_NUM})"
echo "  Difficulty: ${DIFFICULTY} (${DIFFICULTY_NUM})"
echo "  Max Players: ${MAX_PLAYERS}"
echo "  Port: ${PORT}"
echo "  Server Name: ${SERVER_NAME}"
echo ""

# Check if world exists
if [ -f "${WORLD_PATH}/${WORLD_NAME}.wld" ]; then
    echo "Loading existing world: ${WORLD_NAME}"
else
    echo "World not found, will create new world: ${WORLD_NAME}"
fi

echo "Starting TShock server..."
echo "=========================================="

# Find the correct executable
cd /server
if [ -f "TShock.Server" ]; then
    exec mono TShock.Server -configpath "${CONFIG_PATH}" -worldpath "${WORLD_PATH}" -logpath "${LOG_PATH}" -config "${SERVER_CONFIG}" "$@"
elif [ -f "TerrariaServer.exe" ]; then
    exec mono TerrariaServer.exe -configpath "${CONFIG_PATH}" -worldpath "${WORLD_PATH}" -logpath "${LOG_PATH}" -config "${SERVER_CONFIG}" "$@"
else
    echo "ERROR: Could not find TShock server executable"
    ls -la /server/
    exit 1
fi
