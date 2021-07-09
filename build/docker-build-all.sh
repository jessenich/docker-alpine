#!/bin/sh

image_version=

username=jessenich
alpine_version=latest
registry=jessenich91
repository=base-alpine

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

run() {
    script_prefix=$(dirname "$0");
    /bin/sh "${script_prefix}/docker-build.sh" -i "$image_version" -u "${username}" -a "${alpine_version}" --registry "${registry}" --repository "${repository}" && \
    /bin/sh "${script_prefix}/docker-build.sh" -i "$image_version" --no-docs --registry "${registry}" --repository "${repository}";
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
                shift;
            ;;

            --registry)
                registry="$2";
                shift;
            ;;

            --repository)
                repository="$2";
                shift;
            ;;
        esac
    done
}

main "$@"
run
