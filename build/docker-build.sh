#!/bin/bash

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

# shellcheck disable=SC2034,SC2120

# Default to latest git tag
image_version="$(git describe --tags "$(git rev-list --tags --max-count=1)" | grep -Eo '([0-9]\.)+[0-9]+')";
registry="docker.io";
registry_username=jessenich91;
registry_password= ;
registry_password_stdin=false;
ghcr_registry="ghcr.io";
ghcr_library="jessenich";
ghcr_repository="alpine";
ghcr_username="jessenich";
ghcr_password= ;
ghcr_password_stdin=false;
alpine_version="latest";
builder_image="moby/buildkit:latest"
platforms="linux/amd64,linux/arm64/v8,linux/arm/v7,linux/arm/v6"
username="sysadm";
library="jessenich91";
repository="alpine";
passthru= ;

show_usage() {
    cat << EOF
Usage: $0 -i [--image-version] x.x.x [FLAGS]
    Flags:
        -h | --help                    - Show this help screen.
        -i | --image-version           - Semantic version compliant string to tag built image with.
        -u | --username                - Username to use for non-root default user
        -a | --alpine-version          - Semantic version compliant string that coincides with underlying base Alpine image. See dockerhub.com/alpine for values. 'latest' is considered valid.
        -R | --registry                - Registry that contains the library and repository. Defaults to DockerHub. If either -R or -U are specified, a docker login command will be issued prior to build.
        -U | --registry-username       - Username to login to the specified registry. If either -R or -U are specified, a docker login command will be issued prior to build.
        -P | --registry-password       - Password to login to the specified registry. If either -R or -U are specified, a docker login command will be issued.
        -S | --registry-password-stdin - Read registry password from the stdin.
        -l | --library                 - The library that contains the repository to push to.
        -r | --repository              - Repository which the image will be pushed upon successful build. Default value: 'base-alpine'.
        -v | --verbose                 - Print verbose information to stdout.
EOF
}

login() {
    local __registry="$1";
    local __username="$2";
    local __password="$3";
    local __password_stdin= ;

    # Handle DockerHubs lack of URL qurikiness. If regsitry matches the regex of a domain, assume not DockerHub, otherwise assume docker.io
    # first ordinal position was actually the library/username, second was password or stdin switch
    __registry="$(echo "${__registry}" | grep -Eo '^([[:alnum:]]+([\.]){1})+.+$')";
    if [ -z "${__registry}" ] && [ -n "$1" ]; then
        __registry="docker.io";
        __username="${__registry}";
        __password="$2";
    fi

    # If neither a password or stdin option supplied, error out.
    if [ -z "${__password}" ] && [ -z "${__password-stdin}" ]; then
        echo "ERR: Password is required to login to docker registry '${__registry}'." 1>&2;
        echo "";
        show_usage
        exit 1;
    # Password is defaulted to the 3rd ordinal parameter - check if this was actually a switch for stdin input
    elif [[ "${__password}" = *"password-stdin"* ]]; then
        unset __password;
        __password_stdin=true;
    fi



    if [ -n "${registry}" ] || [ -n "${registry_username}" ]; then
        login_result=false;

        if [ -z "${registry_password}" ] && [ "${registry_password_stdin}" = false ];
        then
            echo "ERR: Password required to login to registry '${registry}'" 1>&2;
            show_usage
            exit 2;

        elif [ -n "${registry_password}" ];
        then
            login_result="$(docker login "${__registry}" --username "${__username}" --password "${__password}")" 1>/dev/null 2>&1;

        elif [ "${registry_password_stdin}" ];
        then
            login_result="$(docker login "${__registry}" --username "${__username}" --password-stdin)" 1>/dev/null 2>&1;

        elif [[ "${registry}" = *"acr.azure.com"* ]];
        then
            login_result="$(docker login azure)" 1>/dev/null 2>&1;
        fi

        if [ "${login_result}" != true ] && [ "${login_result}" != 0 ]; then
            echo "ERR: Login to registry '${registry}' failed." 1>&2;
            echo "stdout: ${login_result}" 1>&2;
            show_usage
            exit 1;
        fi
    fi
}

create_builder() {
    docker buildx create --name builder --driver docker-container --driver-opt image="${builder_image}" --platform "${platforms}" --use
}

build() {
    tag1="latest"
    tag2="${image_version}"
    repository_root="."

    docker buildx build \
        -f "${repository_root}/Dockerfile" \
        -t "${library}/${repository}:${tag1}" \
        -t "${library}/${repository}:${tag2}" \
        -t "${ghcr_registry}/${ghcr_library}/${ghcr_repository}:${tag1}" \
        -t "${ghcr_registry}/${ghcr_library}/${ghcr_repository}:${tag2}" \
        --build-arg "ALPINE_VERSION=${alpine_version}" \
        --build-arg "USER=${username}" \
        --platform "${platforms}" \
        --push \
        "${repository_root}"
}

run() {
    login
    build
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h | ? | help | --help)
                show_usage;
                exit 1;
            ;;

            -v | --verbose)
                verbose=true;
                shift;
            ;;

            -i | --image-version)
                image_version="$2";
                shift;
            ;;

            -a | --alpine-version)
                alpine_version="$2";
                shift;
            ;;

            -du | --dockerhub-username)
                registry_username="$2";
                shift;
            ;;

            -dp | --dockerhub-password)
                registry_password="$2";
                shift;
            ;;

            -dl | --dockerhub-library)
                registry="$2";
                shift;
            ;;

            -dr | --dockerhub-repository)
                repository="$2";
                shift;
            ;;

            --dockerhub-password-stdin)
                registry_password_stdin=true;
                shift;
            ;;

            -gR | --ghcr-registry)
                ghcr_registry="$2";
                shift 2;
            ;;

            -gu | --ghcr-username)
                ghcr_username="$2";
                shift 2;
            ;;

            -gp | --ghcr-password)
                ghcr_password="$2";
                shift;
            ;;

            --ghcr-password-stdin)
                ghcr_password_stdin=true;
                shift;
            ;;

            -gl | --ghcr-library)
                ghcr_library="$2";
                shift 2;
            ;;

            -gr | --ghcr-repository)
                ghcr_repository="$2";
                shift 2;
            ;;

            -b | --builder-image)
                builder_image="$2";
                shift;
            ;;

            -P | --platforms)
                platforms="$2"
                shift;
            ;;

            --)
                passthru+=( "$@" );
                shift "$#";
            ;;

             *)
                unbound_arg="$1"
                if [ "${unbound_arg:0:1}" = "v" ]; then
                    # Assume argument is the image version if it beigns with a lowercase v
                    image_version="$1";
                    image_version="$(echo "${image_version}" | grep -Eo '([0-9]\.)+[0-9]+')"
                else
                    echo "Invalid option supplied '$1'";
                    show_usage;
                    exit 1;
                fi
                shift
            ;;
        esac
    done
}

main "$@"

## If we've reached this point without a valid --image-version, show usage info and exit with error code.
if [ -z "${image_version}" ]; then
    image_version="$(git describe --tags "$(git rev-list --tags --max-count=1)" | grep -Eo '([0-9]\.)+[0-9]+')"
    exit 1;
fi

build

exit 0;
