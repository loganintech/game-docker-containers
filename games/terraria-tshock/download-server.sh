#!/bin/bash
set -e

echo "Downloading TShock version ${TSHOCK_VERSION} for Terraria ${TERRARIA_VERSION}..."

# TShock releases follow format: TShock-5.2.0-for-Terraria-1.4.4.9-linux-x64-Release.zip
# or: TShock_5.2_Terraria_1.4.4.9.zip (older format)
# We'll try the GitHub releases API to find the right asset

GITHUB_API="https://api.github.com/repos/Pryaxis/TShock/releases"
DL_FILE="/tmp/tshock.zip"

# Try to find release by tag
RELEASE_TAG="v${TSHOCK_VERSION}"
echo "Looking for release: ${RELEASE_TAG}"

# Get release info
RELEASE_INFO=$(curl -sL "${GITHUB_API}/tags/${RELEASE_TAG}" || echo "{}")

if echo "${RELEASE_INFO}" | jq -e '.assets' > /dev/null 2>&1; then
    # Find the linux-x64 asset
    DL_URL=$(echo "${RELEASE_INFO}" | jq -r '.assets[] | select(.name | test("linux.*x64|linux-x64"; "i")) | .browser_download_url' | head -1)

    if [ -z "${DL_URL}" ] || [ "${DL_URL}" = "null" ]; then
        # Fallback: try any zip file
        DL_URL=$(echo "${RELEASE_INFO}" | jq -r '.assets[] | select(.name | endswith(".zip")) | .browser_download_url' | head -1)
    fi
fi

# If we still don't have a URL, construct one manually
if [ -z "${DL_URL}" ] || [ "${DL_URL}" = "null" ]; then
    echo "Could not find release via API, trying direct URL..."
    # Try common naming patterns
    DL_URL="https://github.com/Pryaxis/TShock/releases/download/${RELEASE_TAG}/TShock-${TSHOCK_VERSION}-for-Terraria-${TERRARIA_VERSION}-linux-x64-Release.zip"
fi

echo "Download URL: ${DL_URL}"
curl -L -o "${DL_FILE}" "${DL_URL}"

# Extract to server directory
unzip -q "${DL_FILE}" -d /server

# TShock extracts with various structures, normalize it
if [ -d "/server/TShock-Release" ]; then
    mv /server/TShock-Release/* /server/ 2>/dev/null || true
    rmdir /server/TShock-Release 2>/dev/null || true
fi

# Make executables runnable
chmod +x /server/TShock.Server 2>/dev/null || true
chmod +x /server/TerrariaServer 2>/dev/null || true
chmod +x /server/TerrariaServer.bin.x86_64 2>/dev/null || true

# Create default plugin directory structure
mkdir -p /server/ServerPlugins

# Cleanup
rm -f "${DL_FILE}"

# Set ownership
chown -R terraria:terraria /server

echo "TShock ${TSHOCK_VERSION} downloaded successfully"
