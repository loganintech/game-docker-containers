# Base image for Windows game servers running via Wine
# Includes SteamCMD for downloading games and Wine for running Windows binaries
#
# Usage: FROM ghcr.io/loganintech/steamcmd-wine:latest

FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

# Install core dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    lib32gcc-s1 \
    locales \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Add i386 architecture and install Wine
RUN dpkg --add-architecture i386 && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        winehq-stable \
        xvfb \
    && rm -rf /var/lib/apt/lists/*

# Install SteamCMD
RUN mkdir -p /opt/steamcmd && \
    cd /opt/steamcmd && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - && \
    chmod +x /opt/steamcmd/steamcmd.sh

# Create steam user
RUN useradd -m -s /bin/bash steam && \
    mkdir -p /home/steam/.wine && \
    mkdir -p /home/steam/server && \
    chown -R steam:steam /home/steam

# Set up Wine environment
ENV WINEARCH=win64
ENV WINEPREFIX=/home/steam/.wine
ENV WINEDEBUG=-all
ENV DISPLAY=:99

# Add steamcmd to path
ENV PATH="/opt/steamcmd:${PATH}"

# Copy common scripts
COPY --chmod=755 scripts/ /opt/scripts/

USER steam
WORKDIR /home/steam

# Initialize Wine prefix (run as steam user)
RUN wineboot --init && \
    wineserver --wait

# Default to server directory
WORKDIR /home/steam/server

ENTRYPOINT ["/opt/scripts/entrypoint-base.sh"]
CMD ["bash"]
