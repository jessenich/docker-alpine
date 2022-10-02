#!/usr/bin/env sh
# shellcheck shell=bash disable=S
C2154,SC2002

mksudo_create_user() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u | --user)
                local user="$2"
                shift 2;;
            -g | --group)
                local group="$2"
                shift 2;;
            --uid)
                local uid="$2"
                shift 2;;
            --gid)
                local gid="$2"
                shift 2;;
            -h | --home)
                local home="$2"
                shift 2;;
            -s | --shell)
                local shell="$2"
                shift 2;;
            -p | --password)
                local password="$2"
                shift 2;;
            *)
                echo "Unknown option: $1"
                return 1;;
        esac
    done


    user=${user:-${USER:=sysadm}}
    group=${group:-${GROUP:=$user}}
    uid=${uid:-${UID:=1000}};
    gid=${gid:-${GID:=1001}};
    home=${home:-${HOME:=/home/$user}};
    shell=${shell:-${SHELL:=/bin/ash}};
    password=${password:-${PASSWORD:=$(pwgen -s -1)}};


    if [ "$user" = "root" ]; then
        echo "User root is not allowed"
        return 1
    fi

    if ! grep -o sudo /etc/group >/dev/null; then
        groupadd -sfg "$gid" sudo
    else
        groupmod -g "$gid" sudo;
    fi

    chown :sudo /etc/shadow;
    chmod 0640 /etc/shadow;
    mkdir -p /etc/sudoers.d;

    echo '%sudo   ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers >/dev/null

    adduser -D --gecos '' "$user";
    usermod -aG sudo "$user"
    usermod -aG wheel "$user"
    cat > /usr/local/share/userinfo <<EOF
USER="$user"
GROUP="$group"
UID="$uid"
GID="$gid"
HOME="$home"
SHELL="$shell"
PASSWORD="$password"
EOF

    chown "$user":"$group" /usr/local/share/userinfo;
    chmod 777 /usr/local/share/userinfo;

    ln -s /usr/local/share/userinfo /etc/userinfo;
    chown "$user":"$group" /etc/userinfo;
    chmod 777 /etc/userinfo;
}

mksudo_create_users "$@";
