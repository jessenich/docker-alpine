#!/bin/sh

# shellcheck shell=bash disable=SC2154,SC2002

mksudo_init_nopasswd_sudoers() {
    groupadd sudo
    addgroup root sudo
    chown :sudo /etc/shadow;
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
