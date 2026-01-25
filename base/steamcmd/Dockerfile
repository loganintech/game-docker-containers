# Base image for native Linux game servers
# Includes SteamCMD for downloading games
#
# Usage: FROM ghcr.io/loganintech/steamcmd:latest

FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

# Install core dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    lib32gcc-s1 \
    lib32stdc++6 \
    locales \
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
    chmod +x /opt/steamcmd/steamcmd.sh

# Create steam user
RUN useradd -m -s /bin/bash steam && \
    mkdir -p /home/steam/server && \
    chown -R steam:steam /home/steam

# Add steamcmd to path
ENV PATH="/opt/steamcmd:${PATH}"

# Copy common scripts
COPY --chmod=755 scripts/ /opt/scripts/

USER steam
WORKDIR /home/steam/server

ENTRYPOINT ["/opt/scripts/entrypoint-base.sh"]
CMD ["bash"]
