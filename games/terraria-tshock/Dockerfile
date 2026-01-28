FROM debian:bookworm-slim

LABEL org.opencontainers.image.source="https://github.com/loganintech/game-docker-containers"
LABEL org.opencontainers.image.description="Terraria TShock Dedicated Server"
LABEL org.opencontainers.image.licenses="MIT"

# TShock version - check https://github.com/Pryaxis/TShock/releases
ARG TSHOCK_VERSION=5.2.0
ARG TERRARIA_VERSION=1.4.4.9
ENV TSHOCK_VERSION=${TSHOCK_VERSION}
ENV TERRARIA_VERSION=${TERRARIA_VERSION}

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    tar \
    file \
    jq \
    mono-complete \
    && rm -rf /var/lib/apt/lists/*

# Create server user and directories
RUN useradd -m -s /bin/bash terraria \
    && mkdir -p /server /root/.local/share/Terraria/Worlds /config /tshock/ServerPlugins /tshock/logs \
    && chown -R terraria:terraria /server /root/.local/share/Terraria/Worlds /config /tshock

# Server configuration via environment variables
ENV WORLD_NAME="world"
ENV WORLD_SIZE="large"
ENV DIFFICULTY="master"
ENV MAX_PLAYERS=16
ENV PORT=7777
ENV SERVER_NAME="TShock Server"
ENV MOTD="Welcome to the server!"

# TShock-specific settings
ENV AUTO_SAVE=true
ENV SPAWN_PROTECTION=false
ENV SPAWN_PROTECTION_RADIUS=10
ENV ENABLE_WHITELIST=false
ENV REQUIRE_LOGIN=false
ENV REST_API_ENABLED=false
ENV REST_API_PORT=7878

# Paths - match helm chart mount paths
ENV WORLD_PATH=/root/.local/share/Terraria/Worlds
ENV CONFIG_PATH=/config
ENV PLUGIN_PATH=/tshock/ServerPlugins
ENV LOG_PATH=/tshock/logs
ENV SERVER_PATH=/server

WORKDIR /server

# Copy scripts
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 download-server.sh /download-server.sh

# Download TShock at build time
RUN /download-server.sh

# Expose ports (game + REST API)
EXPOSE 7777 7878

# Mount points - match helm chart paths
VOLUME ["/root/.local/share/Terraria/Worlds", "/config", "/tshock/ServerPlugins", "/tshock/logs"]

USER terraria
ENTRYPOINT ["/entrypoint.sh"]
