#!/usr/bin/env bash

# shellcheck disable=SC2034

# DockerHub Registry Settings
dockerhub_login_endpoint="https://docker.io";

dockerhub_registry="docker.io";
dockerhub_username="jessenich91";
dockerhub_password= ;
dockerhub_password_stdin=false;
dockerhub_library="jessenich91";
dockerhub_repository="alpine";

# GitHub Container Registry Settings
ghcr_login_endpoint="https://ghcr.io";
ghcr_registry="ghcr.io";
ghcr_username="jessenich";
ghcr_password= ;
ghcr_password_stdin=false;
ghcr_library="jessenich";
ghcr_repository="alpine";

# Buildx Builder Settings
builder_image="moby/buildkit:latest"
platforms="linux/amd64,linux/arm64/v8,linux/arm/v7,linux/arm/v6"

image_version= ;
latest="3.14"
versions=( "3.14" "3.13" )
run() {
    for alpine_version in "${versions[@]}"; do
        if [ "$alpine_version" = "$latest" ]; then
            ./build/docker-build.sh \
                -a "${alpine_version}" \
                -gL "$ghcr_login_endpoint" \
                -gu "$ghcr_username" \
                -gp "$ghcr_password" \
                -gl "$ghcr_library" \
                -gr "$ghcr_repository" \
                -dL "$dockerhub_login_endpoint" \
                -du "$dockerhub_username" \
                -dp "$dockerhub_password" \
                -dl "$dockerhub_library" \
                -dr "$dockerhub_repository" \
                -b "$builder_image" \
                -P "$platforms" \
                --latest \
                "${image_version}"
        else
            ./build/docker-build.sh \
                -a "${alpine_version}" \
                -gL "$ghcr_login_endpoint" \
                -gu "$ghcr_username" \
                -gp "$ghcr_password" \
                -gl "$ghcr_library" \
                -gr "$ghcr_repository" \
                -dL "$dockerhub_login_endpoint" \
                -du "$dockerhub_username" \
                -dp "$dockerhub_password" \
                -dl "$dockerhub_library" \
                -dr "$dockerhub_repository" \
                "${image_version}"
        fi
    done
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -a | --alpine-version)
                version+=( "$2" );
                shift 2;;

            -dL | --dockerhub-login-endpoint)
                dockerhub_login_endpoint="$2";
                shift 2;;

            -du | --dockerhub-username)
                dockerhub_username="$2";
                shift 2;;

            -dp | --dockerhub-password)
                dockerhub_password="$2";
                shift 2;;

            --dockerhub-password-stdin)
                dockerhub_password_stdin=true;
                shift;;

            -dl | --dockerhub-library)
                dockerhub_library="$2";
                shift 2;;

            -dr | --dockerhub-repository)
                dockerhub_repository="$2";
                shift 2;;

            -gL | --ghcr-login-endpoint)
                ghcr_login_endpoint="$2";
                shift 2;;

            -gu | --ghcr-username)
                ghcr_username="$2";
                shift 2;;

            -gp | --ghcr-password)
                ghcr_password="$2";
                shift 2;;

            --ghcr-password-stdin)
                ghcr_password_stdin=true;
                shift;;

            -gl | --ghcr-library)
                ghcr_library="$2";
                shift 2;;

            -gr | --ghcr-repository)
                ghcr_repository="$2";
                shift 2;;

            -b | --builder-image)
                builder_image="$2";
                shift 2;;

            -P | --platforms)
                platforms="$2"
                shift;;

            -l | --latest-version)
                latest="$2";
                shift;;

            *)
                image_version="$1"
                shift;;
        esac
    done
}

main "$@";

if [ -z "${image_version}" ]; then
    image_version="$(git describe --tags "$(git rev-list --tags --max-count=1)" | grep -Eo '([0-9]\.)+[0-9]+')"

    if [ -z "${image_version}" ]; then
        echo "Image version is required." 1>&2;
        __docker_build_show_usage
        exit 1;
    fi
fi

run

exit 0;
