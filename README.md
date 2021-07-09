[![Push Latest Docker Image](https://github.com/jessenich/docker-alpine-base/actions/workflows/push-docker-release.yml/badge.svg)](https://github.com/jessenich/docker-alpine-base/actions/workflows/push-docker-release.yml)

[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod)](https://gitpod.io/#https://github.com/jessenich/docker-alpine-base)

# Docker Alpine Base Image

*GitHub Source* https://github.com/jessenich/docker-alpine-base

*DockerHub Registry* https://dockerhub.com/r/jessenich91/base-alpine

`docker pull jessenich91/base-alpine:latest`

## Contents

Baseline image used in all alpine based images built for multiarch with a non-rooted user and the following installed & pre-configured:

- ca-certificates
- rsync
- nano
- curl
- wget
- jq
- yq
- sudo
- man-docs (Optional)*

## Run

Run latest, standard variant. Includes man-docs and glibc:

`docker -rm -it jessenich91/base-alpine:latest`

Run latest, no-doc variant. Includes glibc:

`docker -rm -it jessenich91/base-alpine:latest-no-docs`

To run a specific version of any variant specify the semver in place of latest, e.g.:

`docker -rm -it jessenich91/base-alpine:1.2.0-no-docs`

## License

Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>. See [LICENSE](https://github.com/jessenich/docker-alpine-base/blob/master/LICENSE) for license information.

As with all Docker images, the built image likely also contains other software which may be under other licenses (such as software from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
