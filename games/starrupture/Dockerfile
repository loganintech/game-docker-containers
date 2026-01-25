# StarRupture Dedicated Server
# Steam App ID: 3809400
# Uses the steamcmd-proton base image for running the Windows server binary
#
# Note: StarRupture is very RAM hungry - can use ~22GB RAM
# Recommended: 16GB+ RAM allocation
#
# Build args:
#   BASE_REGISTRY - Container registry for base image (default: ghcr.io/loganintech)

ARG BASE_REGISTRY=ghcr.io/loganintech
FROM ${BASE_REGISTRY}/steamcmd-proton:latest

# Game-specific metadata
LABEL org.opencontainers.image.title="StarRupture Dedicated Server"
LABEL org.opencontainers.image.description="Dedicated server for StarRupture multiplayer game"
LABEL org.opencontainers.image.source="https://github.com/loganintech/game-docker-containers"

# Steam App ID for the dedicated server
ENV STEAM_APP_ID=3809400

# Server configuration defaults
ENV SERVER_PORT=7777
ENV QUERY_PORT=27015
ENV MULTIHOME=0.0.0.0
ENV UPDATE_ON_START=true
ENV VALIDATE_ON_START=false
ENV ADDITIONAL_ARGS=""

# DSSettings.txt configuration for auto-start
# If SESSION_NAME is set, DSSettings.txt will be generated
ENV SESSION_NAME=""
ENV SAVE_GAME_NAME=""
ENV SAVE_GAME_INTERVAL=300
ENV START_NEW_GAME=false
ENV LOAD_SAVED_GAME=false

# Server admin password (required for server management)
ENV ADMIN_PASSWORD=""

# Copy game-specific entrypoint
COPY --chmod=755 entrypoint.sh /opt/scripts/entrypoint.sh

# Server ports
# 7777 - Game port (TCP/UDP)
# 27015 - Query port (UDP)
EXPOSE 7777/udp 7777/tcp 27015/udp

# Volume for server data and saves
# Saves are stored in: /home/steam/server/StarRupture/Saved/
VOLUME ["/home/steam/server"]

ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
