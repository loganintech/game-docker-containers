#!/bin/bash
set -e

# Convert version format: 1.4.5 -> 145, 1.4.4.9 -> 1449
VERSION_NUM=$(echo "${TERRARIA_VERSION}" | tr -d '.')

echo "Downloading Terraria server version ${TERRARIA_VERSION} (${VERSION_NUM})..."

# Download URL format from terraria.org
DL_URL="https://terraria.org/api/download/pc-dedicated-server/terraria-server-${VERSION_NUM}.zip"
DL_FILE="/tmp/terraria-server.zip"

echo "Download URL: ${DL_URL}"

curl -L -o "${DL_FILE}" "${DL_URL}"

# Extract server files
unzip -q "${DL_FILE}" -d /tmp/terraria

# Move Linux server files to /server
mv /tmp/terraria/${VERSION_NUM}/Linux/* /server/

# Copy default config from Windows folder (Linux folder doesn't include it)
if [ -f "/tmp/terraria/${VERSION_NUM}/Windows/serverconfig.txt" ]; then
    cp /tmp/terraria/${VERSION_NUM}/Windows/serverconfig.txt /server/serverconfig-default.txt
fi

# Make executables runnable
chmod +x /server/TerrariaServer
chmod +x /server/TerrariaServer.bin.x86_64 2>/dev/null || true

# Cleanup
rm -rf /tmp/terraria "${DL_FILE}"

echo "Terraria server ${TERRARIA_VERSION} downloaded successfully"
