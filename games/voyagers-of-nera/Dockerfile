# Voyagers of Nera Dedicated Server
# Steam App ID: 3937860
# Uses the steamcmd-wine base image for running the Windows server binary
#
# Build args:
#   BASE_REGISTRY - Container registry for base image (default: ghcr.io/loganintech)

ARG BASE_REGISTRY=ghcr.io/loganintech
FROM ${BASE_REGISTRY}/steamcmd-wine:latest

# Game-specific metadata
LABEL org.opencontainers.image.title="Voyagers of Nera Dedicated Server"
LABEL org.opencontainers.image.description="Dedicated server for Voyagers of Nera multiplayer game"
LABEL org.opencontainers.image.source="https://github.com/loganintech/game-docker-containers"

# Steam App ID for the dedicated server
ENV STEAM_APP_ID=3937860

# Server configuration defaults
ENV SERVER_PORT=7777
ENV UPDATE_ON_START=true
ENV VALIDATE_ON_START=false
ENV ENABLE_LOGGING=true
ENV ADDITIONAL_ARGS=""

# Host server settings (CustomHostServerUserSettings.ini)
ENV HOST_SERVER_DISPLAY_NAME="Voyagers Server"
ENV HOST_SERVER_PASSWORD=""
ENV MAX_PLAYERS=10
ENV AUTOSAVE_TIMER_SECONDS=300

# Game settings (CustomGameUserSettings.ini)
ENV GATHERING_RATE_MULTIPLIER=1.0
ENV ENEMY_DAMAGE_MULTIPLIER=1.0
ENV PLAYER_DAMAGE_MULTIPLIER=1.0
ENV DISABLE_EQUIPMENT_DURABILITY=false
ENV DISABLE_DROP_ITEMS_ON_DEATH=false

# Epic Online Services IP override (leave empty to use auto-detected IP)
ENV EOS_OVERRIDE_HOST_IP=""

# Copy game-specific entrypoint
COPY --chmod=755 entrypoint.sh /opt/scripts/entrypoint.sh

# Server ports (7777 game, 7778 secondary)
EXPOSE 7777/udp 7777/tcp 7778/udp 7778/tcp

# Volume for server data and saves
VOLUME ["/home/steam/server"]

ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
