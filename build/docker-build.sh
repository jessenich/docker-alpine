#!/bin/bash

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

# shellcheck disable=SC2034,SC2120

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
platforms="linux/amd64,linux/arm64/v8,linux/arm/v7"

# OCI Labels
oci_created= ;
oci_authors= ;
oci_url= ;
oci_documentation= ;
oci_source= ;
oci_version= ;
oci_revision= ;
oci_vendor= ;
oci_licenses= ;
oci_ref_name= ;
oci_title= ;
oci_description= ;

# Default to latest git tag
image_version= ;
latest=true

# Image Build Arguments
alpine_version="3.14";
username="sysadm";

post_passthru=false;

__docker_build_grep_semver() {
    local count="1";
    local postfix=true
    local value= ;

    while [ "$#" -gt 0 ]; do
        case "$1" in
            -c)
                count="$2";
                shift 2;;
            -p)
                postfix=true;
                shift;;
            *)
                value="$1";
                shift;;
        esac
    done

    semver_2_segment="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-((?:0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?"

    echo -n -e "${value}\c" | \
        sed 's/v//' | \
        grep -Eio "${semver_2_segment}"
}

__docker_build_derive_oci() {
    # org.opencontainers.image.created - date and time on which the image was built (string, date-time as defined by RFC 3339).
    # org.opencontainers.image.authors - Contact details of the people or organization responsible for the image (free-form string).
    # org.opencontainers.image.url - URL to find more information on the image (string).
    # org.opencontainers.image.documentation - URL to get documentation on the image (string).
    # org.opencontainers.image.source - URL to get source code for building the image (string).
    # org.opencontainers.image.version - Version of the packaged software.

    # The version MAY match a label or tag in the source code repository.
    # Version MAY be Semantic versioning-compatible.
    # org.opencontainers.image.revision - Source control revision identifier for the packaged software.
    # org.opencontainers.image.vendor - Name of the distributing entity, organization or individual.
    # org.opencontainers.image.licenses - License(s) under which contained software is distributed as an SPDX License Expression.
    # org.opencontainers.image.ref.name - Name of the reference for a target (string).
    # org.opencontainers.image.title - Human-readable title of the image (string).
    # org.opencontainers.image.description - Human-readable description of the software packaged in the image (string).

    if [ -z "$oci_version" ]; then oci_version="org.opencontainers.image.version=${image_version}"; fi
    if [ -z "$oci_source" ]; then oci_source="$(git remote get-url --push origin 2>/dev/null)"; fi

    local oci_version="org.opencontainers.image.version=${image_version}"
    local oci_source= ;
    oci_source="org.opencontainers.image.source=$(git remote get-url --push origin)"
}

__docker_build_login() {
    local __registry="$1";
    local __username="$2";
    local __password="$3";
    local __password_stdin= ;

    __registry="$(echo "${__registry}" | grep -Eio '^([[:alnum:]]+([\.]){1})+.+$')";
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

__docker_build_create_builder() {
    docker buildx create \
        --name builder \
        --driver docker-container \
        --driver-opt image="${builder_image}" \
        --platform "${platforms}" \
        --use
}

__docker_build_build() {
    part2semver="$(__docker_build_grep_semver -c 2 -p "${image_version}")"
    part3semver="$(__docker_build_grep_semver -c 3 -p "${image_version}")"
    tag1="${part2semver}.alpine.${alpine_version}"
    tag2="${part3semver}.alpine.${alpine_version}"
   # tag3="${image_version}.alpine.${alpine_version}"
    repository_root="."

    tags=(
        "-t ${dockerhub_library}/${dockerhub_repository}:${tag1}"
        "-t ${ghcr_registry}/${ghcr_library}/${ghcr_repository}:${tag1}"
    )

    if "${latest}"; then
        tags+=( "${dockerhub_library}/${dockerhub_repository}:latest" )
        tags+=( "${ghcr_registry}/${ghcr_library}/${ghcr_repository}:latest" )
    fi

    if [ "${latest}" = true ]; then
        docker buildx build \
            -f "${repository_root}/Dockerfile" \
            -t "${dockerhub_library}/${dockerhub_repository}:${tag1}" \
            -t "${ghcr_registry}/${ghcr_library}/${ghcr_repository}:${tag1}" \
            -t "${dockerhub_library}/${dockerhub_repository}:${tag2}" \
            -t "${ghcr_registry}/${ghcr_library}/${ghcr_repository}:${tag2}" \
            -t "${dockerhub_library}/${dockerhub_repository}:latest" \
            -t "${ghcr_registry}/${ghcr_library}/${ghcr_repository}:latest" \
            --build-arg "ALPINE_VERSION=${alpine_version}" \
            --build-arg "USER=${username}" \
            --platform "${platforms}" \
            --push \
            "${repository_root}"
    else
        docker buildx build \
            -f "${repository_root}/Dockerfile" \
            -t "${dockerhub_library}/${dockerhub_repository}:${tag1}" \
            -t "${ghcr_registry}/${ghcr_library}/${ghcr_repository}:${tag1}" \
            -t "${dockerhub_library}/${dockerhub_repository}:${tag2}" \
            -t "${ghcr_registry}/${ghcr_library}/${ghcr_repository}:${tag2}" \
            --build-arg "ALPINE_VERSION=${alpine_version}" \
            --build-arg "USER=${username}" \
            --platform "${platforms}" \
            --push \
            "${repository_root}"
    fi
}

__docker_build_show_usage() {
    cat << EOF
Usage: $0 [Script Options] [Builder Options] [[DockerHub Login Options] &|[GitHub Login Options]] [Namespace Args] [Build Args] ImageVersion -- [Passthru Build Switches]

    Script Parameters
        -h | --help                          - Show this help screen.
        -v | --verbose                       - Print verbose information to stdout.
        -f | --version-format                 - Method in which script detects the version to use. Valid options include
                                                 "default": Use latest git tag if image version not already specified. This is the default value.
                                                 "git-tag": Ignore specified image version argument and use latest git tag
                                                 "explicit": Use only the value passed with -i | --image-version. Errors if no value is supplied.

    Builder Options
        -b | --builder-image                 - Name, and tag if not latest, to use with BuildKit
        -P | --platforms                     - Platform string to pass to buildkit. Defaults to 'linux/amd64,linux/arm64/v8,linux/arm/v7'

    DockerHub Login Options
        -dL | --dockerhub-login-endpoint     - Defaults to null, or docker.io. Only specify in special circumstances.
        -du | --dockerhub-username           - Username to login to the DockerHub Container Registry. This is not part of the image namespace even though both values may be the same.
        -dp | --dockerhub-password           - Password to login to the GitHub Container Registry. This can be a password or PAT, though a PAT is recommended.
        --dockerhub-password-stdin           - Read DockerHub registry password from stdin stream. This can be a password or PAT, though a PAT is recommended.

    GitHub Login Options
        -gL | --ghcr-login-endpoint          - Relative endpoint URI to post login credentials to. This is only required for GitHub Enterprise registries.
        -gu | --ghcr-username                - Username to login to the GitHub Container Registry.
        -gp | --ghcr-password                - Password to login to the GitHub Container Registry. This can be a password or PAT, though a PAT is recommended.
        --ghcr-password-stdin                - Read GitHub Container Registry password from stdin stream. This can be a password or PAT, though a PAT is recommended.

    Namespacing Args
        -dl | --dockerhub-library            - The library segment of the DockerHub images namespace.
        -dr | --dockerhub-repository         - The repository segment of the DockerHub images namespace.
        -gl | --ghcr-library                 - The library segment of the GitHub images namespace.
        -gr | --ghcr-repository              - The repository segment of the GitHub images namespace.

    OpenContainer Args
        -oci | --oci | --oci-label        - Label(s) as described by the OCI in the format of "key=value". Note: Version is automatically added based on the image-version argument.
                                               If a remote origin can be found and is not explicitly specified, it will be added.
                                                 --opencontainers-label "created=01/01/2021"
                                                 --opencontainers-label "source=https://github.com/user/repository"

    Build Args
        -a | --alpine-version                - Semantic version compliant string that coincides with underlying base Alpine image. See dockerhub.com/alpine for values. 'latest' is considered valid.
        -u | --username                      - Username to use for non-root default user.
        --latest                             - Include additional "latest" tag

    Passthru Build Options
        Any arguments supplied following "--" are given to BuildKit as is.
EOF
}

__docker_build_parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h | help | --help)
                __docker_build_show_usage;
                exit 1;;

            -v | --verbose)
                verbose=true;
                shift;;

            -f | --version-format)
                case "$2" in
                    "default" | "git-tag" | "explicit")
                        version_format="$2";;

                    *)
                        echo "Invalid value specified for --version-format."
                        __docker_build_show_usage
                        exit 2;;
                esac
                shift 2;;

            -a | --alpine-version)
                alpine_version="$2";
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
                shift 2;;

            -oci | --oci | --oci-label | --opencontainers-label)
                oci_labels+=( "$2" );
                shift 2;;

            --latest)
                latest=true;
                shift;;

            --)
                post_passthru=true;
                declare -a passthru;
                shift;;

             *)
                test "$verbose" && echo "$image_version"

                # shellcheck disable=SC2128
                if [ "${post_passthru}" = true ]; then
                    passthru+=( "$1" );
                elif [ -z "${image_version}" ]; then
                    image_version="$1"
                else
                    echo "Invalid option supplied '$1'";
                    __docker_build_show_usage;
                    exit 1;
                fi
                shift;;
        esac
    done
}

__docker_build_parse_args "$@"

test "${verbose}" && echo "${passthru[@]}"

## If we've reached this point without a valid --image-version, show usage info and exit with error code.
if [ -z "${image_version}" ]; then
    image_version="$(git describe --tags "$(git rev-list --tags --max-count=1)" | grep -Eo '([0-9]\.)+[0-9]+')"

    if [ -z "${image_version}" ]; then
        echo "Image version is required." 1>&2;
        __docker_build_show_usage
        exit 1;
    fi
fi

__docker_build_login "$dockerhub_login_endpoint" "$dockerhub_username" "$dockerhub_password"
__docker_build_login "$ghcr_login_endpoint" "$ghcr_username" "$ghcr_password"
__docker_build_create_builder
__docker_build_build

exit 0;
