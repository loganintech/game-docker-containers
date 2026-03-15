#!/bin/bash
set -e

echo "Downloading TShock version ${TSHOCK_VERSION} for Terraria ${TERRARIA_VERSION}..."

# Clean server directory to avoid stale files from cached layers
rm -rf /server/*

# TShock releases can be .zip or .tar files
# We'll try the GitHub releases API to find the right asset

GITHUB_API="https://api.github.com/repos/Pryaxis/TShock/releases"
DL_FILE="/tmp/tshock-download"

# Try to find release by tag
RELEASE_TAG="v${TSHOCK_VERSION}"
echo "Looking for release: ${RELEASE_TAG}"

# Get release info
RELEASE_INFO=$(curl -sL "${GITHUB_API}/tags/${RELEASE_TAG}" || echo "{}")

DL_URL=""
ASSET_NAME=""

if echo "${RELEASE_INFO}" | jq -e '.assets' > /dev/null 2>&1; then
    # Find the linux-x64 asset (prefer it) - use -c for compact single-line output
    ASSET_INFO=$(echo "${RELEASE_INFO}" | jq -c '.assets[] | select(.name | test("linux.*x64|linux-x64"; "i")) | {url: .browser_download_url, name: .name}' | head -1)

    if [ -n "${ASSET_INFO}" ] && [ "${ASSET_INFO}" != "null" ] && [ "${ASSET_INFO}" != "" ]; then
        DL_URL=$(echo "${ASSET_INFO}" | jq -r '.url')
        ASSET_NAME=$(echo "${ASSET_INFO}" | jq -r '.name')
    fi

    # Fallback: try any archive file
    if [ -z "${DL_URL}" ] || [ "${DL_URL}" = "null" ]; then
        ASSET_INFO=$(echo "${RELEASE_INFO}" | jq -c '.assets[] | select(.name | test("\\.(zip|tar|tar\\.gz|tgz)$"; "i")) | {url: .browser_download_url, name: .name}' | head -1)
        if [ -n "${ASSET_INFO}" ] && [ "${ASSET_INFO}" != "null" ] && [ "${ASSET_INFO}" != "" ]; then
            DL_URL=$(echo "${ASSET_INFO}" | jq -r '.url')
            ASSET_NAME=$(echo "${ASSET_INFO}" | jq -r '.name')
        fi
    fi
fi

# If we still don't have a URL, construct one manually
if [ -z "${DL_URL}" ] || [ "${DL_URL}" = "null" ]; then
    echo "Could not find release via API, trying direct URL..."
    DL_URL="https://github.com/Pryaxis/TShock/releases/download/${RELEASE_TAG}/TShock-${TSHOCK_VERSION}-for-Terraria-${TERRARIA_VERSION}-linux-x64-Release.zip"
    ASSET_NAME="TShock-${TSHOCK_VERSION}-linux-x64-Release.zip"
fi

echo "Download URL: ${DL_URL}"
echo "Asset name: ${ASSET_NAME}"
curl -L -o "${DL_FILE}" "${DL_URL}"

# Detect archive type and extract accordingly
if [[ "${ASSET_NAME}" == *.tar.gz ]] || [[ "${ASSET_NAME}" == *.tgz ]]; then
    echo "Extracting tar.gz archive..."
    tar -xzf "${DL_FILE}" -C /server
elif [[ "${ASSET_NAME}" == *.tar ]]; then
    echo "Extracting tar archive..."
    tar -xf "${DL_FILE}" -C /server
elif [[ "${ASSET_NAME}" == *.zip ]]; then
    echo "Extracting zip archive..."
    unzip -q "${DL_FILE}" -d /server
else
    # Try to detect by file content
    FILE_TYPE=$(file -b "${DL_FILE}" | head -1)
    echo "Detected file type: ${FILE_TYPE}"

    if echo "${FILE_TYPE}" | grep -qi "gzip"; then
        echo "Extracting gzip archive..."
        tar -xzf "${DL_FILE}" -C /server
    elif echo "${FILE_TYPE}" | grep -qi "tar"; then
        echo "Extracting tar archive..."
        tar -xf "${DL_FILE}" -C /server
    elif echo "${FILE_TYPE}" | grep -qi "zip"; then
        echo "Extracting zip archive..."
        unzip -q "${DL_FILE}" -d /server
    else
        echo "ERROR: Unknown archive format: ${FILE_TYPE}"
        exit 1
    fi
fi

# Handle nested tar files (some releases wrap the server in a tar inside the archive)
for nested_tar in /server/*.tar; do
    if [ -f "${nested_tar}" ]; then
        echo "Found nested tar: ${nested_tar}, extracting..."
        tar -xf "${nested_tar}" -C /server
        rm -f "${nested_tar}"
    fi
done

# TShock extracts with various structures, normalize it
# Find any subdirectory that contains the server executable and flatten it
for dir in /server/*/; do
    if [ -d "${dir}" ] && [ "${dir}" != "/server/ServerPlugins/" ]; then
        if [ -f "${dir}TShock.Server" ] || [ -f "${dir}TerrariaServer" ]; then
            echo "Flattening server directory: ${dir}"
            mv "${dir}"* /server/ 2>/dev/null || true
            rmdir "${dir}" 2>/dev/null || true
        fi
    fi
done

# Make executables runnable
chmod +x /server/TShock.Server 2>/dev/null || true
chmod +x /server/TerrariaServer 2>/dev/null || true
chmod +x /server/TerrariaServer.bin.x86_64 2>/dev/null || true

# Validate that we have a server executable
if ! [ -f /server/TShock.Server ] && ! [ -f /server/TerrariaServer ] && ! [ -f /server/TerrariaServer.exe ]; then
    echo "ERROR: No TShock executable found after extraction"
    echo "Contents of /server/:"
    ls -la /server/
    find /server -maxdepth 2 -name "TShock.Server" -o -name "TerrariaServer" -o -name "TerrariaServer.exe"
    exit 1
fi

# Create default plugin directory structure
mkdir -p /server/ServerPlugins

# Cleanup
rm -f "${DL_FILE}"

# Set ownership
chown -R terraria:terraria /server

echo "TShock ${TSHOCK_VERSION} downloaded successfully"
