# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG ALPINE_VERSION=latest

FROM alpine:"${ALPINE_VERSION}"

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"

ARG USER=jessenich
ARG NO_DOCS=false

ENV USER=${USER:-jessenich} \
    ALPINE_VERSION=${ALPINE_VERSION} \
    HOME=/home/${USER} \
    NO_DOCS=${NO_DOCS} \
    TZ=America/NewYork \
    RUNNING_IN_DOCKER=1

RUN adduser -D ${USER} && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USER}" && \
    chmod 0440 "/etc/sudoers.d/${USER}" && \
    apk add \
        ca-certificates \
        nano \
        nano-syntax \
        rsync \
        curl \
        wget \
        jq \
        yq \
        sudo

RUN if [ "${NO_DOCS}" = "false" ]; \
    then \
        apk add \
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

RUN rm /var/cache/apk/*

USER ${USER}
WORKDIR ${HOME}
