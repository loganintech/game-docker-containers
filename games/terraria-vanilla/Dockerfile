FROM debian:bookworm-slim

LABEL org.opencontainers.image.source="https://github.com/loganintech/game-docker-containers"
LABEL org.opencontainers.image.description="Terraria Vanilla Dedicated Server"
LABEL org.opencontainers.image.licenses="MIT"

# Install dependencies (no mono needed - Terraria 1.4.4+ has native Linux binary)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    libsdl2-2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Create server user and directories
RUN useradd -m -s /bin/bash terraria \
    && mkdir -p /server /home/terraria/.local/share/Terraria/Worlds /config \
    && chown -R terraria:terraria /server /home/terraria/.local/share/Terraria/Worlds /config

# Server configuration via environment variables
# TERRARIA_VERSION is required - e.g., "1.4.5.1"
ENV TERRARIA_VERSION=""
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

# Paths - use terraria user's home directory
ENV WORLD_PATH=/home/terraria/.local/share/Terraria/Worlds
ENV CONFIG_PATH=/config
ENV SERVER_PATH=/server

WORKDIR /server

# Copy scripts
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 download-server.sh /download-server.sh

# Expose game port
EXPOSE 7777

# Mount points
VOLUME ["/home/terraria/.local/share/Terraria/Worlds", "/config"]

# Run as terraria user (entrypoint handles download as needed)
USER terraria
ENTRYPOINT ["/entrypoint.sh"]
