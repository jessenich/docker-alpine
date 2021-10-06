# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG VARIANT=3.14

FROM alpine:"${VARIANT:-3.14}" as root-only

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"
LABEL org.opencontainers.image.source="https://github.com/jessenich/docker-alpine/blob/main/Dockerfile"

ENV ALPINE_VERSION="${VARIANT}" \
    HOME="/home/${NON_ROOT_ADMIN}" \
    TZ="${TZ:-America/New_York}" \
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

CMD "/bin/ash";

FROM root-only as sudo-user
ARG NON_ROOT_ADMIN="${NON_ROOT_ADMIN:-sysadm}"

ONBUILD ENV NON_ROOT_ADMIN="${NON_ROOT_ADMIN:-sysadm}" \
            HOME="/home/${NON_ROOT_ADMIN}" \
            ALPINE_VERSION="${VARIANT}"

RUN apk add --update --no-cache \
    shadow \
    bash \
    sudo;

RUN /bin/bash /usr/sbin/addsudouser.sh "$NON_ROOT_ADMIN"

USER "$NON_ROOT_ADMIN"
WORKDIR "/home/$NON_ROOT_ADMIN"
CMD "/bin/ash";

