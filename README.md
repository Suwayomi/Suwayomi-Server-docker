# Suwayomi-Server Docker Container

|                                                                                                                                                                                                                                                   Status                                                                                                                                                                                                                                                    |                                                                                                                             Stable                                                                                                                              |                                                                                                                             Preview                                                                                                                              |                                                                      Discord Support                                                                       |
|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------------------------------------------------------------------------------:|
| [![Build Docker Images](https://github.com/Suwayomi/Suwayomi-Server-docker/actions/workflows/build_container_images.yml/badge.svg)](https://github.com/Suwayomi/Suwayomi-Server-docker/actions/workflows/build_container_images.yml) [![Docker Pulls](https://img.shields.io/badge/dynamic/json?url=https://github.com/Suwayomi/Suwayomi-Server-docker/raw/main/scripts/tachidesk_version.json&label=docker_pulls&query=$.total_downloads&color=blue)](https://github.com/orgs/suwayomi/packages/container/package/tachidesk) | [![Latest](https://img.shields.io/badge/dynamic/json?url=https://github.com/Suwayomi/Suwayomi-Server-docker/raw/main/scripts/tachidesk_version.json&label=version&query=$.stable&color=blue)](https://github.com/orgs/suwayomi/packages/container/package/tachidesk/) | [![Preview](https://img.shields.io/badge/dynamic/json?url=https://github.com/Suwayomi/Suwayomi-Server-docker/raw/main/scripts/tachidesk_version.json&label=version&query=$.preview&color=blue)](https://github.com/orgs/suwayomi/packages/container/package/tachidesk) | [![Discord](https://img.shields.io/discord/801021177333940224.svg?label=discord&labelColor=7289da&color=2c2f33&style=flat)](https://discord.gg/DDZdqZWaHA) |

Run [Suwayomi-Server](https://github.com/Suwayomi/Suwayomi-Server) inside docker container as non-root user. The server will be running on http://localhost:4567 open this url in your browser.

Docker Releases - https://github.com/Suwayomi/Suwayomi-Server-docker/pkgs/container/tachidesk

Dockerfile - https://github.com/Suwayomi/Suwayomi-Server-docker

_**Suwayomi data location - /home/suwayomi/.local/share/Tachidesk**_

Docker images are mutli-arch (linux/amd64, linux/arm64/v8, linux/ppc64le, linux/s390x, linux/riscv64) and has small size based on Ubuntu linux.

Logs are sent to stdout and are not written to disk.

### Docker compose

Use the template [docker-compose.yml](./docker-compose.yml) in this repo for creating and starting tachidesk docker container.

# Environment Variables

> [!CAUTION]
> Providing an environment variable will <b>overwrite</b> the current setting value when starting the container.

> [!Tip]
> Most of the time you don't need to use environment variables, instead settings can be changed during runtime via the webUI. (which will be rendered useless when providing an environment variable)

> [!NOTE]
> See [server-reference.conf](https://github.com/Suwayomi/Suwayomi-Server/blob/master/server/src/main/resources/server-reference.conf) in the [Suwayomi-Server](https://github.com/Suwayomi/Suwayomi-Server) repository for the default values

There are a number of environment variables available to configure Suwayomi:

|               Variable               |     Server Default      |                                                                                              Description                                                                                              |
|:------------------------------------:|:-----------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|                **TZ**                |        `Etc/UTC`        |                                                                              What time zone the container thinks it is.                                                                               |
|             **BIND_IP**              |        `0.0.0.0`        |                                                        The interface to listen on, inside the container. You almost never want to change this.                                                        |
|            **BIND_PORT**             |         `4567`          |                                                                                  Which port Suwayomi will listen on                                                                                   |
|       **SOCKS_PROXY_ENABLED**        |         `false`         |                                                                         Whether Suwayomi will connect through a SOCKS5 proxy                                                                          |
|         **SOCKS_PROXY_HOST**         |           ` `           |                                                                                   The TCP host of the SOCKS5 proxy                                                                                    |
|         **SOCKS_PROXY_PORT**         |           ` `           |                                                                                     The port of the SOCKS5 proxy                                                                                      |
|         **DOWNLOAD_AS_CBZ**          |         `false`         |                                                                     Whether Suwayomi should save the manga to disk in CBZ format                                                                      |
|        **BASIC_AUTH_ENABLED**        |         `false`         |                                                                         Whether Suwayomi requires HTTP Basic Auth to get in.                                                                          |
|       **BASIC_AUTH_USERNAME**        |           ` `           |                                                                                  The username to log in to Suwayomi.                                                                                  |
|       **BASIC_AUTH_PASSWORD**        |           ` `           |                                                                                  The password to log in to Suwayomi.                                                                                  |
|              **DEBUG**               |         `false`         |                                                               If extra logging is enabled. Useful for development and troubleshooting.                                                                |
|          **WEB_UI_ENABLED**          |         `true`          |                                                                                  If the server should serve a webUI                                                                                   |
|          **WEB_UI_FLAVOR**           |         `WebUI`         |                                                                                          "WebUI" or "Custom"                                                                                          |
|          **WEB_UI_CHANNEL**          |        `stable`         |                                        "bundled" (the version bundled with the server release), "stable" or "preview" - the webUI version that should be used                                         |
|      **WEB_UI_UPDATE_INTERVAL**      |          `23`           |                                          Time in hours - 0 to disable auto update - range: 1 <= n < 24 - how often the server should check for webUI updates                                          |
|      **AUTO_DOWNLOAD_CHAPTERS**      |         `false`         |                                                             If new chapters that have been retrieved should get automatically downloaded                                                              |
|   **AUTO_DOWNLOAD_EXCLUDE_UNREAD**   |         `true`          |                                                                  Ignore automatic chapter downloads of entries with unread chapters                                                                   |
| **AUTO_DOWNLOAD_NEW_CHAPTERS_LIMIT** |           `0`           |                           0 to disable - how many unread downloaded chapters should be available - if the limit is reached, new chapters won't be downloaded automatically                            |
|  **AUTO_DOWNLOAD_IGNORE_REUPLOADS**  |         `false`         |                                                           Decides if re-uploads should be ignored during auto download of new chapters chapters                                                                   |
|         **EXTENSION_REPOS**          |          `[]`           |                       Any additional extension repos to use, the format is `["https://github.com/MY_ACCOUNT/MY_REPO/tree/repo", "https://github.com/MY_ACCOUNT_2/MY_REPO_2/"]`                        |
|     **MAX_SOURCES_IN_PARALLEL**      |           `6`           | Range: 1 <= n <= 20 - Sets how many sources can do requests (updates, downloads) in parallel. Updates/Downloads are grouped by source and all mangas of a source are updated/downloaded synchronously |
|      **UPDATE_EXCLUDE_UNREAD**       |         `true`          |                                                                            If unread manga should be excluded from updates                                                                            |
|      **UPDATE_EXCLUDE_STARTED**      |         `true`          |                                                                  If manga that haven't been started should be excluded from updates                                                                   |
|     **UPDATE_EXCLUDE_COMPLETED**     |         `true`          |                                                                          If completed manga should be excluded from updates                                                                           |
|         **UPDATE_INTERVAL**          |          `12`           |                 Time in hours - 0 to disable it - (doesn't have to be full hours e.g. 12.5) - range: 6 <= n < ∞ - Interval in which the global update will be automatically triggered                 |
|        **UPDATE_MANGA_INFO**         |         `false`         |                                                                        If manga info should be updated along with the chapters                                                                        |
|           **BACKUP_TIME**            |         `00:00`         |                                                    Range: hour: 0-23, minute: 0-59 - Time of day at which the automated backup should be triggered                                                    |
|         **BACKUP_INTERVAL**          |           `1`           |                                         Time in days - 0 to disable it - range: 1 <= n < ∞ - Interval in which the server will automatically create a backup                                          |
|            **BACKUP_TTL**            |          `14`           |                                         Time in days - 0 to disable it - range: 1 <= n < ∞ - How long backup files will be kept before they will get deleted                                          |
|       **FLARESOLVERR_ENABLED**       |         `false`         |                                                                         Whether FlareSolverr is enabled and available to use                                                                          |
|         **FLARESOLVERR_URL**         | `http://localhost:8191` |                                                                                 The URL of the FlareSolverr instance                                                                                  |
|       **FLARESOLVERR_TIMEOUT**       |          `60`           |                                                              Time in seconds for FlareSolverr to timeout if the challenge is not solved                                                               |
|    **FLARESOLVERR_SESSION_NAME**     |       `suwayomi`        |                                                                   The name of the session that Suwayomi will use with FlareSolverr                                                                    |
|     **FLARESOLVERR_SESSION_TTL**     |          `15`           |                                                                             The time to live for the FlareSolverr session                                                                             |

### Downloads Folder
We do not allow configuration of the downloads folder, since Docker Volumes can handle that instead, here is an example of a docker-compose.yaml that has downloads volume configuration:
```yaml
  tachidesk:
    image: ghcr.io/suwayomi/suwayomi-server:stable
    container_name: tachidesk
    volumes: # The order matters! Make sure the downloads is first in the volume list or it will not work!
      - /example/tachidesk/downloads:/home/suwayomi/.local/share/Tachidesk/downloads
      - /example/tachidesk/files:/home/suwayomi/.local/share/Tachidesk
    ports:
      - 4568:4567
    restart: unless-stopped
```

# Docker tags

## Latest

`ghcr.io/suwayomi/suwayomi-server:latest` 

The latest stable release of the server. Also tagged as `:stable`.

> [!CAUTION]
> Currently the `ghcr.io/suwayomi/suwayomi-server` image does not contain the stable release, please use `ghcr.io/suwayomi/tachidesk` for now instead.

## Preview

`ghcr.io/suwayomi/suwayomi-server:preview`

The latest preview release of the server. Can be buggy!

# Credit

[Suwayomi-Server](https://github.com/Suwayomi/Suwayomi-Server) is licensed under `MPL v. 2.0`.

# License

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
