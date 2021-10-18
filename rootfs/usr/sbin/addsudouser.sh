#!/bin/sh

# shellcheck shell=bash disable=SC2154,SC2002

mksudo_init_nopasswd_sudoers() {
    if ! cat /etc/group | grep -o sudo; then
        groupadd sudo
    fi

    chown :sudo /etc/shadow;
    chmod 0640 /etc/shadow;
    mkdir -p /etc/sudoers.d;

    cat /etc/sudoers | sed 's/# %sudo.*/%sudo   ALL=\(ALL\) NOPASSWD: ALL/g' | tee /etc/sudoers >/dev/null
    return 0;
}

mksudo_create_user() {
    user="$1";
    adduser -D --gecos '' "$user";
    usermod -aG sudo "$user";
    addgroup "$user" sudo;
    return 0;
}

mksudo_init_nopasswd_sudoers;
mksudo_create_users "$1";

exit 0;
