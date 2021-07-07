# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG ALPINE_VERSION=

FROM alpine:"${ALPINE_VERSION:-latest}"

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"

ARG USER= \
    NO_DOCS=

ENV USER="${USER:-jessenich}" \
    ALPINE_VERSION="${ALPINE_VERSION}" \
    HOME="/home/${USER}" \
    NO_DOCS="${INCLUDE_DOCS:-true}" \
    TZ="America/NewYork" \
    RUNNING_IN_DOCKER="true"

RUN adduser -D "${USER}" && \
    mkdir -p /etc/sudoers.d && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USER}" && \
    chmod 0440 "/etc/sudoers.d/${USER}" && \
    apk --update --no-cache add \
        ca-certificates \
        nano \
        nano-syntax \
        rsync \
        curl \
        wget \
        jq \
        yq \
        sudo && \
    if [ "${NO_DOCS}" = "false" ]; then \
        apk --update --no-cache add \
            man-pages \
            man-db \
            man-db-doc \
            nano-doc \
            curl-doc \
            wget-doc \
            jq-doc \
            yq-doc \
            sudo-doc; \
    fi

USER ${USER}
WORKDIR ${HOME}
