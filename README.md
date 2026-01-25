# Game Docker Containers

Docker containers for dedicated game servers, designed for Kubernetes deployment.

## Structure

```
.
├── base/                    # Base images
│   ├── steamcmd/           # Native Linux game servers
│   └── steamcmd-wine/      # Windows game servers via Wine
├── games/                   # Game-specific containers
│   └── voyagers-of-nera/   # Voyagers of Nera dedicated server
└── .github/workflows/       # CI/CD pipelines
```

## Base Images

### steamcmd

Base image for native Linux game servers. Includes:
- Debian Bookworm slim
- SteamCMD
- Helper scripts for server updates

**Pull:** `ghcr.io/loganintech/steamcmd:latest`

### steamcmd-wine

Base image for Windows game servers running via Wine. Includes:
- Debian Bookworm slim
- SteamCMD
- Wine (stable)
- Xvfb for headless operation
- Helper scripts for server updates and Wine execution

**Pull:** `ghcr.io/loganintech/steamcmd-wine:latest`

## Game Servers

### Voyagers of Nera

Dedicated server for the Voyagers of Nera multiplayer exploration game.

**Pull:** `ghcr.io/loganintech/voyagers-of-nera:latest`

**Ports:**
- 7777/tcp, 7777/udp - Main game port
- 7778/tcp, 7778/udp - Secondary game port

**Environment Variables:**

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_PORT` | 7777 | Game server port |
| `UPDATE_ON_START` | true | Update server files on startup |
| `VALIDATE_ON_START` | false | Validate all files (slower) |
| `HOST_SERVER_DISPLAY_NAME` | "Voyagers Server" | Server name in browser |
| `HOST_SERVER_PASSWORD` | "" | Server password (empty = no password) |
| `MAX_PLAYERS` | 10 | Maximum players |
| `AUTOSAVE_TIMER_SECONDS` | 300 | Autosave interval |
| `GATHERING_RATE_MULTIPLIER` | 1.0 | Resource gathering rate |
| `ENEMY_DAMAGE_MULTIPLIER` | 1.0 | Enemy damage multiplier |
| `PLAYER_DAMAGE_MULTIPLIER` | 1.0 | Player damage multiplier |
| `DISABLE_EQUIPMENT_DURABILITY` | false | Disable equipment durability |
| `DISABLE_DROP_ITEMS_ON_DEATH` | false | Keep items on death |
| `EOS_OVERRIDE_HOST_IP` | "" | Override public IP for EOS |

**Volume:** `/home/steam/server` - Server files and save data

## Adding a New Game

1. Create a new directory under `games/`:
   ```bash
   mkdir -p games/my-game
   ```

2. Create a Dockerfile that uses the appropriate base:
   ```dockerfile
   ARG BASE_REGISTRY=ghcr.io/loganintech
   FROM ${BASE_REGISTRY}/steamcmd-wine:latest  # or steamcmd:latest for Linux

   ENV STEAM_APP_ID=123456
   # ... game-specific configuration

   COPY --chmod=755 entrypoint.sh /opt/scripts/entrypoint.sh
   ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
   ```

3. Create an `entrypoint.sh` script that:
   - Updates the game via SteamCMD (use `/opt/scripts/steamcmd-update.sh`)
   - Configures the server
   - Starts the server executable

4. The GitHub workflow will automatically build and push the image on merge to main.

## Local Development

Build a base image:
```bash
docker build -t steamcmd-wine:local base/steamcmd-wine/
```

Build a game image:
```bash
docker build -t voyagers-of-nera:local \
  --build-arg BASE_REGISTRY=local \
  games/voyagers-of-nera/
```

Run locally:
```bash
docker run -it --rm \
  -p 7777:7777/udp -p 7777:7777/tcp \
  -p 7778:7778/udp -p 7778:7778/tcp \
  -v $(pwd)/server-data:/home/steam/server \
  -e HOST_SERVER_DISPLAY_NAME="My Test Server" \
  voyagers-of-nera:local
```

## CI/CD

- **Base images** are built when files in `base/` change
- **Game images** are built when files in `games/` change
- All images are pushed to GHCR with tags:
  - `latest` (main branch)
  - `sha-<commit>` (all commits)
  - Branch/PR names
