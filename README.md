<!-- omit from toc -->
# Abiotic Factor Linux Docker

> [!CAUTION]
> THIS REPO IS NOT COMPATIBLE WITH THE ORIGINAL REPO.<br>
> You cannot do in-place upgrade from the original repo to this.<br>
> The original server was running as `root` while this is running as `steam`<br>
> This means that files previously creadted will have wrong permissions leading to container startup failure.

For operating a dedicated Abiotic Factor server in Docker.<br>
The container uses [Wine](https://www.winehq.org/) to run the, Windows only, server under Linux.

The base image for the server is based on <https://github.com/CM2Walki/steamcmd> latest variant.<br>
For security reasons the server runs as the `steam` user without root or sudo privileges.

Because the container has to bundle Wine, image size is quite large.<br>
Current latest image can be expected to be above 2GiB.

<!-- omit from toc -->
## Table of Contents

- [Setup](#setup)
  - [Docker Compose](#docker-compose)
  - [Docker Run](#docker-run)
- [Update](#update)
  - [Updating the container](#updating-the-container)
- [Configuration](#configuration)
- [Credits](#credits)

## Setup

> [!NOTE]
> Some fo the default variables are duplicated in the [entrypoint script](entrypoint.sh).<br>
> Not setting a value in the compose file does not automatically unset it in the container.<br>
> The values can still be overwritten via the environment variables.

### Docker Compose

Run the compose with `docker compose up -d` or use your preferred method.

The server can be uninstalled with `docker compose down` or `docker compose down --volumes`.

It's possible to download the latest image beforing starting the server with `docker compose pull`.

> [!CAUTION]
> Appeding the `--volumes` flag will delete all data stored in the `gamefiles` and `data` volumes.<br>
> This includes save files and the server configuration.

```yaml
---

services:
  abiotic-server:
    image: "ghcr.io/iamsaeve/abiotic-factor-linux-docker:latest"
    container_name: abiotic-server
    hostname: abiotic-server
    restart: always
    user: "1000:1000" # UID and GID for the "steam" user from the base image
    volumes:
      - "gamefiles:/server"
      - "data:/server/AbioticFactor/Saved"
    environment:
      - MaxServerPlayers=${MaxServerPlayers:-6}
      - Port=${Port:-7777}
      - QueryPort=${QueryPort:-27015}
      - ServerPassword=${ServerPassword:-ChangeThisPasswordPlease}
      - SteamServerName=${SteamServerName:-"Linux Server"}
      - WorldSaveName=${WorldSaveName:-MyWorldSave}
      - UsePerfThreads=true
      - NoAsyncLoadingThread=true
      # - AutoUpdate=true
      # - AdditionalArgs=-SandboxIniPath=Config/WindowsServer/Server1Sandbox.ini
    ports:
      - "7777:7777/udp"
      - "27015:27015/udp"

volumes:
  gamefiles: {}
  data: {}

```

### Docker Run

In addition to starting the server via the docker-compose file, it is also possible to start the server via `docker run`.

The following command start the server with the default settings:

```shell
docker run --name abiotic-server \
   -h abiotic-server \
   --restart always \
   -u 1000:1000 \
   -v gamefiles:/server \
   -v data:/server/AbioticFactor/Saved \
   -e UsePerfThreads=true \
   -e NoAsyncLoadingThread=true \
   -p 7777:7777/udp \
   -p 27015:27015/udp \
   ghcr.io/iamsaeve/abiotic-factor-linux-docker:latest
```

The following command start the server with the same settings as the compose file:

```shell
docker run --name abiotic-server \
   -h abiotic-server \
   --restart always \
   -u 1000:1000 \
   -v gamefiles:/server \
   -v data:/server/AbioticFactor/Saved \
   -e MaxServerPlayers=:6 \
   -e Port=7777 \
   -e QueryPort=27015 \
   -e ServerPassword=ChangeThisPasswordPlease \
   -e SteamServerName=LinuxServer \
   -e UsePerfThreads=true \
   -e NoAsyncLoadingThread=true \
   -e WorldSaveName=MyWorldSave \
   -p 7777:7777/udp \
   -p 27015:27015/udp \
   ghcr.io/iamsaeve/abiotic-factor-linux-docker:latest
```

> [!IMPORTANT]
> It is not advised to change the `UsePerfThreads` and `NoAsyncLoadingThread` settings.<br>
> Only do this if you know what your doing and have a specific usecase that requires this.

## Update

There are two ways to update the game server:

1. By setting the `AutoUpdate` environment variable to `true`. This checks for updates every time the container is started.
2. By deleting the `gamefiles` directory while the server is turned off.

### Updating the container

1. Check for changes to the [Docker Compose section](#docker-compose) to align with your local install
2. Run `docker compose pull`, or pull directly `docker pull ghcr.io/iamsaeve/abiotic-factor-linux-docker:latest` to download an updated version of the container image
3. Stop the server `docker compose down` or `docker stop abiotic-server`
4. Start the server using the methid you chose to install with, eg. `docker compose up -d`

## Configuration

An example configuration for docker-compose can be found in the [Docker Compose section](#docker-compose)<br>
In addition to the default settings, which can be set via the environment variables, further arguments can be specified via the `AdditionalArgs` environment variable.

Possible launch parameters and further information on the dedicated servers for Abiotic Factor can be found [In the docs](https://github.com/DFJacob/AbioticFactorDedicatedServer/wiki/Technical-%E2%80%90-Launch-Parameters).

## Credits

Huge shoutout to the original creator: <https://github.com/Pleut> :fire:

Thanks to @sirwillis92 for finding a solution to the startup problem with the `LogOnline: Warning: OSS: Async task 'FOnlineAsyncTaskSteamCreateServer bWasSuccessful: 0' failed in 15` message.
