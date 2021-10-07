# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG VARIANT=3.14 \
    TZ=America/New_York

FROM alpine:"$VARIANT" as root

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"
LABEL org.opencontainers.image.source="https://github.com/jessenich/docker-alpine/blob/main/Dockerfile"

ENV VARIANT="$VARIANT" \
    HOME="/home/$NON_ROOT_ADMIN" \
    TZ="$TZ" \
    RUNNING_IN_DOCKER=true

USER root

COPY ./rootfs /
RUN apk update 2>/dev/null && \
        apk --no-cache add \
        ca-certificates \
        nano \
        nano-syntax \
        rsync \
        curl \
        wget \
        tzdata \
        jq \
        yq;

FROM root-only as sudo
ARG USER="sysadm"

ONBUILD ENV NON_ROOT_ADMIN="$USER" \
            HOME="/home/$USER" \
            ALPINE_VERSION="$VARIANT"

RUN apk add --update --no-cache \
    shadow \
    sudo;

RUN /bin/sh /usr/sbin/create-users.sh "$USER"

USER "$USER"
WORKDIR "/home/$USER"

