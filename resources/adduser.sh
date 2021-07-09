#!/bin/sh

adduser -D "$1"
mkdir -p /etc/sudoers.d
echo "$1 ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$1"
chmod 0440 "/etc/sudoers.d/$1"

return 0;
