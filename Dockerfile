# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG VARIANT=3.14

FROM alpine:"${VARIANT:-3.14}"

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"
LABEL org.opencontainers.image.source="https://github.com/jessenich/docker-alpine/blob/main/Dockerfile"

ARG NON_ROOT_ADMIN=sysadm \
    TZ=UTC

ENV NON_ROOT_ADMIN="${NON_ROOT_ADMIN:-sysadm}" \
    ALPINE_VERSION="${ALPINE_VERSION:-3.14}" \
    HOME="/home/${NON_ROOT_ADMIN}" \
    TZ="${TZ:-UTC}" \
    RUNNING_IN_DOCKER=true

USER root

COPY ./lxfs /
RUN apk update && \
    apk upgrade && \
        apk add \
        ca-certificates \
        nano \
        nano-syntax \
        rsync \
        curl \
        wget \
        tzdata \
        jq \
        yq \
        shadow \
        sudo && \
        rm /var/cache/apk/*;

RUN chmod 0640 /etc/shadow && \
    mkdir -p "${HOME}" && \
    mkdir -p /etc/sudoers.d && \
    echo "${NON_ROOT_ADMIN} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${NON_ROOT_ADMIN}" && \
    chmod 0440 "/etc/sudoers.d/${NON_ROOT_ADMIN}" && \
    adduser -D -h "${HOME}" -s /bin/ash "${NON_ROOT_ADMIN}";

USER "${NON_ROOT_ADMIN}"
WORKDIR "${HOME}"
CMD "/bin/ash"
