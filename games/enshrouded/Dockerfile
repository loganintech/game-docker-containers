ARG BASE_REGISTRY=ghcr.io/loganintech
FROM ${BASE_REGISTRY}/steamcmd-proton:latest

LABEL org.opencontainers.image.source="https://github.com/loganintech/game-docker-containers"
LABEL org.opencontainers.image.description="Enshrouded Dedicated Server running under Proton"
LABEL org.opencontainers.image.licenses="MIT"

# Enshrouded Dedicated Server App ID
ENV STEAM_APP_ID=2278520

# Server configuration
ENV SERVER_NAME="Enshrouded Server"
ENV SERVER_PASSWORD=""
ENV SERVER_IP="0.0.0.0"
ENV GAME_PORT=15636
ENV QUERY_PORT=15637
ENV MAX_PLAYERS=16
ENV SLOT_COUNT=16

# Update settings
ENV UPDATE_ON_START=true
ENV VALIDATE_ON_START=false

# Server directory
ENV SERVER_DIR=/home/steam/enshrouded
WORKDIR ${SERVER_DIR}

# Expose ports (game + query)
EXPOSE ${GAME_PORT}/udp
EXPOSE ${QUERY_PORT}/udp

# Copy startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER steam
ENTRYPOINT ["/entrypoint.sh"]
