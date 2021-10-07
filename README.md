# Docker Alpine Base Image

[![GitHub last commit](https://img.shields.io/github/last-commit/jessenich/docker-alpine?style=for-the-badge)](https://github.com/jessenich/docker-alpine/commit/57d54b3ff6bf4d6a7b72358eaf05b47b72ffdc6b) [![GitHub](https://img.shields.io/github/license/jessenich/docker-alpine?style=for-the-badge)](https://github.com/jessenich/docker-alpine/blob/master/LICENSE)

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/jessenich/docker-alpine/Push%20Docker%20Image?label=Build%20%26%20Push%20Docker%20Image&style=for-the-badge)

[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/jessenich91/alpine?style=for-the-badge)](https://dockerhub.com/r/jessenich91/alpine) [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/jessenich91/alpine/latest?style=for-the-badge)](https://dockerhub.com/r/jessenich91/alpine) [![Docker Pulls](https://img.shields.io/docker/pulls/jessenich91/alpine?label=DOCKERHUB%20PULLS&style=for-the-badge)](https://dockerhub.com/r/jessenich91/alpine)

[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod&style=for-the-badge)](https://gitpod.io/#https://github.com/jessenich/docker-alpine)


[__GitHub Source__](https://github.com/jessenich/docker-alpine)

`docker pull jessenich91/alpine:latest`

[__DockerHub Registry__](https://dockerhub.com/r/jessenich91/alpine)

`docker pull ghcr.io/jessenich/alpine:latest`

## What is this image?


Baseline image used in all alpine based images with support for AMD64, armhf, and arm64 architectures.

### Image Meta

Based off Alpine 14 as of the latest release.

Provisions default non rooted user defaulted to 'sysadm' with no password. Built against both Alpine 3.14 and 3.13 for AMD64, AARCH64, and ARMHF architectures.

#### Installed Packages

- ca-certificates
- rsync
- nano
- curl
- wget
- tzdata
- jq
- yq
- sudo
- bash (upon first run)

## Running this Image

Run latest, standard variant.

`docker -rm -it ghcr.io/jessenich/alpine:latest`

To run a specific version:

`docker -rm -it ghcr.io/jessenich/alpine:v1.7.12.alpine.3.13`

## License

Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>. See [LICENSE](https://github.com/jessenich/docker-alpine-base/blob/master/LICENSE) for license information.

As with all Docker images, the built image likely also contains other software which may be under other licenses (such as software
from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant
licenses for all software contained within.
