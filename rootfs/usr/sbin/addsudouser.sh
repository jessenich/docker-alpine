#!/usr/bin/env bash

# shellcheck shell=bash disable=SC2154,SC2002

declare -a sudo_users;

mksudo_parse_args() {
    if [ "$#" -le 1 ]; then
        echo "At least one user argument is required." >&2;
    fi

    while [ "$#" -gt 0 ]; do
        sudo_users+=( "$(echo "$1" | tr -d ' ')" );
        shift;
    done
}

mksudo_init_nopasswd_sudoers() {
    chmod 0640 /etc/shadow;
    mkdir -p /etc/sudoers.d;

    # I'm unsure why this fuckery is required, but I'm not screwing with it anymore.
    # 1. Modify file stream, make sudo group passwordless
    # 2. Write modified stream to temporary .mod file
    # 3. Force rm /etc/sudoers.
    # 4. Rename our .mod to the original name.
    # 5. Genius fuckery that works.
    cat /etc/sudoers | sed 's/# %sudo.*/%sudo ALL=\(ALL\) NOPASSWD: ALL/g' >> /etc/sudoers.mod
    rm -f /etc/sudoers;
    mv /etc/sudoers.mod /etc/sudoers
    return 0;
}

mksudo_create_users() {
    for user in "${sudo_users[@]}"; do
        adduser -D --gecos '' "$user";
        usermod -aG sudo "$user";
        chsh -s /bin/bash "$user";
    done
    return 0;
}

mksudo_parse_args "$@";
mksudo_init_nopasswd_sudoers;
mksudo_create_users

exit 0;
