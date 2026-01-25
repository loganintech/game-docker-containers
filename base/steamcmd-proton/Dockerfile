# Base image for Windows game servers running via Proton (GE-Proton)
# Includes SteamCMD for downloading games and GE-Proton for running Windows binaries
#
# Proton advantages over Wine:
# - DXVK for DirectX 9/10/11 to Vulkan translation
# - VKD3D-Proton for DirectX 12 to Vulkan
# - Game-specific patches and fixes
# - Better overall game compatibility
#
# Usage: FROM ghcr.io/loganintech/steamcmd-proton:latest

FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG GE_PROTON_VERSION=GE-Proton9-22

# Install core dependencies and Vulkan
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    ca-certificates \
    curl \
    wget \
    xz-utils \
    tar \
    # 32-bit support
    lib32gcc-s1 \
    lib32stdc++6 \
    # Locale
    locales \
    # X11/display (for some games that need a display)
    xvfb \
    x11-xserver-utils \
    # Vulkan drivers (Mesa for software rendering in containers)
    libvulkan1 \
    libvulkan1:i386 \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers:i386 \
    # Additional libraries commonly needed by games
    libfreetype6 \
    libfreetype6:i386 \
    libsdl2-2.0-0 \
    libsdl2-2.0-0:i386 \
    # Font rendering
    fonts-liberation \
    # Python for some Proton scripts
    python3 \
    # Process utilities (pgrep, etc.)
    procps \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install SteamCMD
RUN mkdir -p /opt/steamcmd && \
    cd /opt/steamcmd && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - && \
    chmod +x /opt/steamcmd/steamcmd.sh && \
    # Run steamcmd once to download internal binaries and set permissions
    /opt/steamcmd/steamcmd.sh +quit || true && \
    chmod -R 755 /opt/steamcmd

# Create steam user
RUN useradd -m -s /bin/bash steam && \
    mkdir -p /home/steam/server && \
    mkdir -p /home/steam/.steam/steam/compatibilitytools.d && \
    chown -R steam:steam /home/steam && \
    chown -R steam:steam /opt/steamcmd

# Download and install GE-Proton
RUN cd /tmp && \
    wget -q "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${GE_PROTON_VERSION}/${GE_PROTON_VERSION}.tar.gz" && \
    tar -xzf ${GE_PROTON_VERSION}.tar.gz -C /home/steam/.steam/steam/compatibilitytools.d/ && \
    rm ${GE_PROTON_VERSION}.tar.gz && \
    chown -R steam:steam /home/steam/.steam

# Set up environment
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH=/home/steam/.steam/steam
ENV STEAM_COMPAT_DATA_PATH=/home/steam/.proton
ENV PROTON_PATH=/home/steam/.steam/steam/compatibilitytools.d/${GE_PROTON_VERSION}
ENV PROTON_VERSION=${GE_PROTON_VERSION}

# Display for Xvfb
ENV DISPLAY=:99

# Disable quack/debugging output
ENV PROTON_LOG=0
ENV DXVK_LOG_LEVEL=none
ENV VKD3D_DEBUG=none
ENV WINE_LARGE_ADDRESS_AWARE=1

# Add steamcmd to path
ENV PATH="/opt/steamcmd:${PATH}"

# Copy common scripts
COPY --chmod=755 scripts/ /opt/scripts/

USER steam
WORKDIR /home/steam

# Initialize Proton prefix
RUN mkdir -p /home/steam/.proton/pfx

# Default to server directory
WORKDIR /home/steam/server

ENTRYPOINT ["/opt/scripts/entrypoint-base.sh"]
CMD ["bash"]
