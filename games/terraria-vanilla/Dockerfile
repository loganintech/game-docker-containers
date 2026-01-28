FROM debian:bookworm-slim

LABEL org.opencontainers.image.source="https://github.com/loganintech/game-docker-containers"
LABEL org.opencontainers.image.description="Terraria Vanilla Dedicated Server"
LABEL org.opencontainers.image.licenses="MIT"

# Version can be overridden at build time
# Format: 1.4.4.9 -> 1449 (remove dots)
ARG TERRARIA_VERSION=1.4.5
ENV TERRARIA_VERSION=${TERRARIA_VERSION}

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    mono-complete \
    && rm -rf /var/lib/apt/lists/*

# Create server user and directories
RUN useradd -m -s /bin/bash terraria \
    && mkdir -p /server /worlds /config \
    && chown -R terraria:terraria /server /worlds /config

# Server configuration via environment variables
ENV WORLD_NAME="world"
ENV WORLD_SIZE="large"
ENV DIFFICULTY="master"
ENV MAX_PLAYERS=16
ENV PORT=7777
ENV PASSWORD=""
ENV MOTD=""
ENV SECURE=1
ENV LANGUAGE="en-US"
ENV UPNP=0
ENV PRIORITY=1

# Paths
ENV WORLD_PATH=/worlds
ENV CONFIG_PATH=/config
ENV SERVER_PATH=/server

WORKDIR /server

# Copy scripts
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 download-server.sh /download-server.sh

# Download server at build time for the specified version
RUN /download-server.sh

# Expose game port
EXPOSE 7777

# Mount points
VOLUME ["/worlds", "/config"]

USER terraria
ENTRYPOINT ["/entrypoint.sh"]
