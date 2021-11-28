# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG VARIANT=3.15 \
    TZ=America/New_York \
    TAG \
    REVISION_SHORT

FROM alpine:"$VARIANT" as root



ENV DISTRO=alpine \
    VARIANT="$VARIANT" \
    TZ="$TZ" \
    RUNNING_IN_DOCKER=true \
    TAG="$TAG" \
    REVISION_SHORT="$REVISION_SHORT"

USER root

COPY ./rootfs /
RUN chmod ug+wrx /usr/sbin/addsudouser.sh && \
    chmod ug+wrx /usr/sbin/entrypoint.sh

RUN apk add --update --no-cache \
        ca-certificates \
        nano \
        nano-syntax \
        rsync \
        curl \
        wget \
        tzdata \
        jq \
        yq;

FROM root as sudo

ARG USER="sysadm" \
    GROUP=$USER \
    UID="1000" \
    GID="1001" \
    HOME="/home/$USER" \
    PASSWORD=$USER

ENV USER=$USER \
    GROUP=$GROUP \
    UID=$UID \
    GID=$GID \
    HOME=$HOME


RUN apk add --update --no-cache shadow sudo

CMD [ "/bin/ash", "/usr/sbin/addsudouser.sh", "-u", "$USER", "-g", "$GROUP", "--gid", "$GID", "--uid", "$UID", "-h", "$HOME", "-p", "$PASSWORD" ]
WORKDIR "/home/$USER"
USER "$USER"

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"
LABEL org.opencontainers.image.source=https://github.com/jessenich/docker-alpine/blob/main/Dockerfile
LABEL org.opencontainers.image.title="Kepler Development Base $TAG Alpine $VARIANT"
LABEL org.opencontainers.image.description="Base alpine images used in all Kepler Development alpine based images. Root only and rootless flavors."
LABEL org.opencontainers.image.version="$TAG"
LABEL org.opencontainers.image.authors="Jesse N. <jesse@keplerdev.com>"
LABEL org.opencontainers.image.created="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
LABEL org.opencontainers.image.build_date="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
LABEL org.opencontainers.image.vendor="Kepler Development LLC <https://keplerdev.com>"
LABEL org.opencontainers.image.license="MIT"
LABEL org.opencontainers.image.url="https://github.com/jessenich/docker-alpine/README.md"
LABEL org.opencontainers.image.documentation="https://github.com/jessenich/docker-alpine/README.md"
LABEL org.opencontainers.image.commit="$REVISION_SHORT"
LABEL org.opencontainers.image.revision="$REVISION_SHORT"

LABEL com.keplerdev.image.variant="$VARIANT"
LABEL com.keplerdev.image.tag="$TAG"
LABEL com.keplerdev.image.revision.short="$REVISION_SHORT"
LABEL com.keplerdev.image.policy="public"
LABEL com.keplerdev.image.license="MIT"
LABEL com.keplerdev.image.maintainer="Jesse N. <jesse@keplerdev.com>"
LABEL com.keplerdev.buildargs.user="$USER"
LABEL com.keplerdev.buildargs.group="$GROUP"
LABEL com.keplerdev.buildargs.uid="$UID"
LABEL com.keplerdev.buildargs.gid="$GID"
LABEL com.keplerdev.buildargs.home="$HOME"
LABEL com.keplerdev.buildargs.password="$PASSWORD"
LABEL com.keplerdev.buildargs.tz="$TZ"
LABEL com.keplerdev.buildargs.variant="$VARIANT"
LABEL com.keplerdev.buildargs.tag="$TAG"
LABEL com.keplerdev.buildargs.revision.short="$REVISION_SHORT"
LABEL com.keplerdev.cicd="github"
LABEL com.keplerdev.cicd.repo="jessenich/docker-alpine"
LABEL com.keplerdev.cicd.branch="main"
LABEL com.keplerdev.cicd.commit="$REVISION_SHORT"
LABEL com.keplerdev.cicd.build="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
LABEL com.keplerdev.registry.url.dockerhub="docker.io/jessenich91/alpine:$TAG"
LABEL com.keplerdev.registry.url.github="ghcr.io/jessenich/docker-alpine:$TAG"
LABEL com.keplerdev.registry.url.internal="kplr.io/v2/alpine:$TAG"
LABEL com.keplerdev.registry.url.gitlab=""
LABEL com.keplerdev.registry.url.bitbucket=""
LABEL com.keplerdev.registry.url.gcr=""
LABEL com.keplerdev.registry.url.quay=""
LABEL com.keplerdev.registry.url.azure=""


