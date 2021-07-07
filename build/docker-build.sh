#!/bin/sh

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

image_version= ;

username="jessenich";
no_docs="false";
alpine_version="latest";
registry="jessenich91";
repository="base-alpine";å

show_usage() {
    echo  "Usage: $0 -i [--image-version] x.x.x [FLAGS]" && \
    echo "Flags: " && \
    echo "    -i | --image-version          - Semantic version compliant string to tag built image with." && \
    echo "    -u | --username               - Username to use for non-root default user" && \
    echo "    -a | --alpine-version         - Semantic version compliant string that coincides with underlying base Alpine image. See dockerhub.com/alpine for values. 'latest' is considered valid." && \
    echo "    [ --no-docs ]                 - Flag indicating whether to include accompanying documentation packages. Including docs will increase image size significantly." && \
    echo "    [ --registry ]                - Registry which the image will be pushed upon successful build. If not using dockerhub, the full FQDN must be specified. This assumes the default docker daemon is already authenticated with the registry specified. If dockerhub is used, just the username is required. Default value: jessenich91." && \
    echo "    [ --repository ]              - Repository which the image will be pushed upon successful build. Default value: 'base-alpine'"
}

build() {
    tag1="latest"
    tag2="${image_version}"
    repository_root="."

    if [ "${no_docs}" = "true" ];
    then
        tag1="${tag1}-no-docs"
        tag2="${tag2}-no-docs"
    fi

    docker buildx build \
        -f "${repository_root}/Dockerfile" \
        -t "${registry}/${repository}:${tag1}" \
        -t "${registry}/${repository}:${tag2}" \
        --build-arg "ALPINE_VERSION=${alpine_version}" \
        --build-arg "USER=${username}" \
        --build-arg "NO_DOCS=${no_docs}" \
        --platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
        --push \
        "${repository_root}"
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h | --help)
                show_usage;
                exit 1;
            ;;

            -i | --image-version)
                image_version="$2";
            ;;

            -a | --alpine-version)
                alpine_version="$2"
            ;;

            -u | --username)
                username="$2";
            ;;

            --no-docs)
                no_docs="true";
            ;;

            --registry)
                registry="$2";
            ;;

            --repository)
                repository="$2";
            ;;
        esac
        shift
    done
}

main "$@"

## If we've reached this point without a valid --image-version, show usage info and exit with error code.
if [ -z "${image_version}" ]; then
    show_usage;
    exit 1;
fi

build

exit 0;
