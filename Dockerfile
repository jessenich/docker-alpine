# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG ALPINE_VERSION=latest

FROM alpine:"${ALPINE_VERSION}"

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"
LABEL org.opencontainers.image.source="https://github.com/jessenich/docker-alpine-base/blob/main/Dockerfile"

ARG ADMIN=sysadm \
    TZ=America/NewYork

ENV ADMIN=$ADMIN \
    ALPINE_VERSION=$ALPINE_VERSION \
    HOME="/home/$ADMIN" \
    TZ=$TZ \
    RUNNING_IN_DOCKER=true

USER root

COPY ./lxfs /
RUN chmod +x /usr/sbin/adduser.sh && \
    apk update && \
    apk upgrade && \
        apk add \
        ca-certificates \
        nano \
        nano-syntax \
        rsync \
        curl \
        wget \
        jq \
        yq \
        shadow \
        sudo && \
    rm /var/cache/apk/* && \
    chmod 0640 /etc/shadow && \
    mkdir -p "${HOME}" && \
    mkdir -p /etc/sudoers.d && \
    echo "${ADMIN} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${ADMIN}" && \
    chmod 0440 "/etc/sudoers.d/${ADMIN}" && \
    adduser -D -h "${HOME}" -s /bin/ash "${ADMIN}";

USER ${ADMIN}
WORKDIR ${HOME}
CMD /bin/ash
